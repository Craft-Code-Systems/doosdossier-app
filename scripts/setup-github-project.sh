#!/usr/bin/env bash
set -uo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# DoosDossier — GitHub Projects (v2) board setup
#
# Creates (or reuses) a Projects v2 board for the repo, adds a "Sprint" and a
# "Priority" single-select field, adds every open issue to the board, and sets
# each issue's Sprint (from its milestone) and Priority (from its priority:*
# label). If a native *Iteration* field exists on the board, each card's
# iteration is set too (see "Planned sprints" at the bottom).
#
# Why a script instead of it being done for you?
#   The GitHub Projects v2 API is not reachable from the agent environment that
#   scaffolded this repo, so board creation is delegated to you to run once with
#   your own credentials. Everything the script sets is derived from data that
#   already lives on the issues (milestones + priority labels).
#
# Requirements
#   - gh CLI >= 2.55         https://cli.github.com
#   - jq
#   - gh auth with project scope:
#         gh auth refresh -s project,read:project
#
# Usage
#   ./scripts/setup-github-project.sh
#
# Resilient + idempotent: every GitHub call is retried with backoff on
# transient network errors, an existing board of the same title is reused,
# existing fields/options are skipped, and `gh project item-add` returns the
# existing card if an issue is already on the board — so it is always safe to
# re-run (e.g. after a dropped connection or when new issues are added).
# ─────────────────────────────────────────────────────────────────────────────

ORG="Craft-Code-Systems"
REPO="doosdossier-app"
PROJECT_TITLE="DoosDossier Delivery"

# Sprint options mirror the repo milestones (M0–M3), so mapping is 1:1.
SPRINTS=("M0: Free Scan Live" "M1: Golden Files Verified" "M2: MVP Core" "M3: Connectors + BE/FR")
PRIORITIES=("P0" "P1" "P2")

need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' is required but not installed." >&2; exit 1; }; }
need gh
need jq

# Retry any command up to 5 times with exponential backoff (2s,4s,8s,16s).
# stdout of the successful attempt passes through so it can be captured.
gh_retry() {
  local n=1 max=5 delay=2 rc
  while :; do
    "$@" && return 0
    rc=$?
    if (( n >= max )); then
      echo "  ! failed after ${max} attempts: $*" >&2
      return "$rc"
    fi
    echo "  … transient error — retry ${n}/$((max-1)) in ${delay}s" >&2
    sleep "$delay"; delay=$((delay * 2)); ((n++))
  done
}

# ── ensure the board exists (reuse by title; never duplicate) ───────────────
echo "▶ Ensuring project '${PROJECT_TITLE}' exists for @${ORG}…"
PROJECTS_JSON="$(gh_retry gh project list --owner "$ORG" --format json)" \
  || { echo "ERROR: could not list projects (check network / 'gh auth status')." >&2; exit 1; }
PROJECT_NUMBER="$(echo "$PROJECTS_JSON" | jq -r --arg t "$PROJECT_TITLE" '.projects[] | select(.title==$t) | .number' | head -n1)"

if [[ -z "${PROJECT_NUMBER}" ]]; then
  PROJECT_NUMBER="$(gh_retry gh project create --owner "$ORG" --title "$PROJECT_TITLE" --format json | jq -r '.number')" \
    || { echo "ERROR: could not create project." >&2; exit 1; }
  echo "  created project #${PROJECT_NUMBER}"
else
  echo "  reusing existing project #${PROJECT_NUMBER}"
fi

PROJECT_ID="$(gh_retry gh project view "$PROJECT_NUMBER" --owner "$ORG" --format json | jq -r '.id')" \
  || { echo "ERROR: could not read project id." >&2; exit 1; }

# ── create single-select fields if missing ──────────────────────────────────
ensure_single_select_field() {
  local name="$1"; shift
  local existing
  existing="$(gh_retry gh project field-list "$PROJECT_NUMBER" --owner "$ORG" --format json \
    | jq -r --arg n "$name" '.fields[] | select(.name==$n) | .id' | head -n1)"
  if [[ -z "${existing}" ]]; then
    local opts; opts="$(IFS=,; echo "$*")"
    echo "▶ Creating field '${name}'  →  ${opts}"
    gh_retry gh project field-create "$PROJECT_NUMBER" --owner "$ORG" \
      --name "$name" --data-type SINGLE_SELECT --single-select-options "$opts" >/dev/null
  else
    echo "▶ Field '${name}' already exists — skipping."
  fi
}

ensure_single_select_field "Sprint" "${SPRINTS[@]}"
ensure_single_select_field "Priority" "${PRIORITIES[@]}"

# refresh field metadata (field ids + option ids) after creation
FIELDS_JSON="$(gh_retry gh project field-list "$PROJECT_NUMBER" --owner "$ORG" --format json)" \
  || { echo "ERROR: could not read fields." >&2; exit 1; }
SPRINT_FIELD_ID="$(echo "$FIELDS_JSON"   | jq -r '.fields[] | select(.name=="Sprint")   | .id')"
PRIORITY_FIELD_ID="$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name=="Priority") | .id')"

option_id() { # $1=field name  $2=option name
  echo "$FIELDS_JSON" | jq -r --arg f "$1" --arg v "$2" \
    '.fields[] | select(.name==$f) | .options[] | select(.name==$v) | .id'
}

# ── optional: detect a native Iteration field and prepare mapping ───────────
ITER_FIELD_JSON="$(echo "$FIELDS_JSON" | jq -c '[.fields[] | select(.type=="ProjectV2IterationField")][0] // empty')"
ITER_FIELD_ID=""
if [[ -n "${ITER_FIELD_JSON}" ]]; then
  ITER_FIELD_ID="$(echo "$ITER_FIELD_JSON" | jq -r '.id')"
  echo "▶ Found Iteration field '$(echo "$ITER_FIELD_JSON" | jq -r '.name')' — will map milestones → iterations by name (M0/M1/M2/M3)."
fi
iteration_id_for() { # $1 = "M2: MVP Core" -> iteration whose title starts with "M2"
  local prefix="${1%%:*}"
  echo "$ITER_FIELD_JSON" | jq -r --arg p "$prefix" '
    [ (.configuration.iterations // [])[], (.configuration.completedIterations // [])[] ]
    | map(select((.title // "") | ascii_downcase | startswith(($p | ascii_downcase))))
    | (.[0].id // empty)'
}

# ── add every open issue and set Sprint / Priority / Iteration ──────────────
echo "▶ Loading open issues from ${ORG}/${REPO}…"
ISSUES_JSON="$(gh_retry gh issue list --repo "$ORG/$REPO" --state open --limit 200 \
  --json number,url,title,milestone,labels)" \
  || { echo "ERROR: could not list issues." >&2; exit 1; }
echo "  found $(echo "$ISSUES_JSON" | jq 'length') open issues"

FAILED=()
while read -r issue; do
  num="$(echo "$issue"       | jq -r '.number')"
  url="$(echo "$issue"       | jq -r '.url')"
  milestone="$(echo "$issue" | jq -r '.milestone.title // empty')"
  prio="$(echo "$issue"      | jq -r '[.labels[].name | select(startswith("priority:"))][0] // empty' | sed 's/priority://')"

  echo "  • #${num}  sprint='${milestone:-none}'  priority='${prio:-none}'"

  add_out="$(gh_retry gh project item-add "$PROJECT_NUMBER" --owner "$ORG" --url "$url" --format json)"
  if [[ $? -ne 0 ]]; then FAILED+=("#$num"); continue; fi
  item_id="$(echo "$add_out" | jq -r '.id')"
  if [[ -z "$item_id" || "$item_id" == "null" ]]; then FAILED+=("#$num"); continue; fi

  ok=1
  if [[ -n "${milestone}" ]]; then
    opt="$(option_id "Sprint" "$milestone")"
    [[ -n "${opt}" ]] && { gh_retry gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
      --field-id "$SPRINT_FIELD_ID" --single-select-option-id "$opt" >/dev/null || ok=0; }
  fi
  if [[ -n "${prio}" ]]; then
    opt="$(option_id "Priority" "$prio")"
    [[ -n "${opt}" ]] && { gh_retry gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
      --field-id "$PRIORITY_FIELD_ID" --single-select-option-id "$opt" >/dev/null || ok=0; }
  fi
  if [[ -n "${ITER_FIELD_ID}" && -n "${milestone}" ]]; then
    iid="$(iteration_id_for "$milestone")"
    [[ -n "${iid}" ]] && { gh_retry gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
      --field-id "$ITER_FIELD_ID" --iteration-id "$iid" >/dev/null || ok=0; }
  fi
  (( ok == 0 )) && FAILED+=("#$num")
done < <(echo "$ISSUES_JSON" | jq -c '.[]')

echo
if (( ${#FAILED[@]} == 0 )); then
  echo "✓ All issues added and configured."
else
  echo "⚠ Finished, but these issues need a re-run: ${FAILED[*]}"
  echo "  Just run the script again — it resumes safely."
fi
echo
echo "Board:  https://github.com/orgs/${ORG}/projects"
echo
echo "── Planned sprints (one-time, in the board UI) ────────────────────────────"
echo "  A date-based *Iteration* field (the source of GitHub's 'Current/Planned'"
echo "  sprint view + burndown) can't be created via API/CLI. Add it once:"
echo "    board → ⋯ → Settings → Fields → ＋ New field → type 'Iteration'."
echo "  Name the iterations 'M0…', 'M1…', 'M2…', 'M3…', then re-run this script"
echo "  and it will assign each issue to its iteration automatically."
