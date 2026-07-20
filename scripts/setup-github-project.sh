#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# DoosDossier — GitHub Projects (v2) board setup
#
# Creates (or reuses) a Projects v2 board for the repo, adds a "Sprint" and a
# "Priority" single-select field, adds every open issue to the board, and sets
# each issue's Sprint (from its milestone) and Priority (from its priority:*
# label).
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
# The script is idempotent: re-running reuses an existing board of the same
# title and skips fields/options that already exist. `gh project item-add`
# returns the existing card if an issue is already on the board.
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

echo "▶ Ensuring project '${PROJECT_TITLE}' exists for @${ORG}…"
PROJECT_NUMBER="$(gh project list --owner "$ORG" --format json \
  | jq -r --arg t "$PROJECT_TITLE" '.projects[] | select(.title==$t) | .number' | head -n1)"

if [[ -z "${PROJECT_NUMBER}" ]]; then
  PROJECT_NUMBER="$(gh project create --owner "$ORG" --title "$PROJECT_TITLE" --format json | jq -r '.number')"
  echo "  created project #${PROJECT_NUMBER}"
else
  echo "  reusing existing project #${PROJECT_NUMBER}"
fi

PROJECT_ID="$(gh project view "$PROJECT_NUMBER" --owner "$ORG" --format json | jq -r '.id')"

# ── create single-select fields if missing ──────────────────────────────────
ensure_single_select_field() {
  local name="$1"; shift
  local existing
  existing="$(gh project field-list "$PROJECT_NUMBER" --owner "$ORG" --format json \
    | jq -r --arg n "$name" '.fields[] | select(.name==$n) | .id' | head -n1)"
  if [[ -z "${existing}" ]]; then
    local opts; opts="$(IFS=,; echo "$*")"
    echo "▶ Creating field '${name}'  →  ${opts}"
    gh project field-create "$PROJECT_NUMBER" --owner "$ORG" \
      --name "$name" --data-type SINGLE_SELECT --single-select-options "$opts" >/dev/null
  else
    echo "▶ Field '${name}' already exists — skipping."
  fi
}

ensure_single_select_field "Sprint" "${SPRINTS[@]}"
ensure_single_select_field "Priority" "${PRIORITIES[@]}"

# refresh field metadata (field ids + option ids) after creation
FIELDS_JSON="$(gh project field-list "$PROJECT_NUMBER" --owner "$ORG" --format json)"
SPRINT_FIELD_ID="$(echo "$FIELDS_JSON"   | jq -r '.fields[] | select(.name=="Sprint")   | .id')"
PRIORITY_FIELD_ID="$(echo "$FIELDS_JSON" | jq -r '.fields[] | select(.name=="Priority") | .id')"

option_id() { # $1=field name  $2=option name
  echo "$FIELDS_JSON" | jq -r --arg f "$1" --arg v "$2" \
    '.fields[] | select(.name==$f) | .options[] | select(.name==$v) | .id'
}

# ── add every open issue and set Sprint / Priority ──────────────────────────
echo "▶ Loading open issues from ${ORG}/${REPO}…"
ISSUES_JSON="$(gh issue list --repo "$ORG/$REPO" --state open --limit 200 \
  --json number,url,title,milestone,labels)"
echo "  found $(echo "$ISSUES_JSON" | jq 'length') open issues"

echo "$ISSUES_JSON" | jq -c '.[]' | while read -r issue; do
  num="$(echo "$issue"       | jq -r '.number')"
  url="$(echo "$issue"       | jq -r '.url')"
  milestone="$(echo "$issue" | jq -r '.milestone.title // empty')"
  prio="$(echo "$issue"      | jq -r '[.labels[].name | select(startswith("priority:"))][0] // empty' | sed 's/priority://')"

  echo "  • #${num}  sprint='${milestone:-none}'  priority='${prio:-none}'"

  item_id="$(gh project item-add "$PROJECT_NUMBER" --owner "$ORG" --url "$url" --format json | jq -r '.id')"

  if [[ -n "${milestone}" ]]; then
    opt="$(option_id "Sprint" "$milestone")"
    [[ -n "${opt}" ]] && gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
      --field-id "$SPRINT_FIELD_ID" --single-select-option-id "$opt" >/dev/null
  fi
  if [[ -n "${prio}" ]]; then
    opt="$(option_id "Priority" "$prio")"
    [[ -n "${opt}" ]] && gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
      --field-id "$PRIORITY_FIELD_ID" --single-select-option-id "$opt" >/dev/null
  fi
done

echo
echo "✓ Board ready. Open it at:"
echo "    https://github.com/orgs/${ORG}/projects"
echo
echo "Next (optional, one click each in the board UI):"
echo "  • Group the board or a table view by 'Sprint' (or by the built-in 'Milestone')."
echo "  • Add a real date-based *Iteration* field for burndown charts — iteration"
echo "    fields cannot be created via the API/CLI, only in the board UI."
