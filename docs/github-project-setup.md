# GitHub project setup — issues, priorities & sprints

This repo's planning is tracked entirely on GitHub. This note explains how the
pieces fit together and how to stand up the visual **Projects (v2) board**.

## What already exists

Created directly on the repo (no action needed):

- **35 issues** (`#4`–`#38`) with stable IDs in the title —
  `RESEARCH-*`, `GOLDEN-*`, `INFRA-*`, `ENGINE-*`, `SCHEMES-*`, `API-*`,
  `WEB-*`, `CONN-*`, `DOCS-*` — tracing back to the `F-NN` / `N-NN`
  requirements in [`docs/spec.md`](./spec.md).
- **Labels**: `type:{feature,task,research,docs}`, `area:{api,web,db,engine,schemes,connectors,infra,docs}`,
  `priority:{P0,P1,P2}`, `phase:{0,1,2,3}`.
- **Sprints = milestones**, with every issue already assigned to exactly one:

  | Sprint (milestone)            | Due date   | Issues |
  |-------------------------------|------------|--------|
  | `M0: Free Scan Live`          | 2026-07-25 | 7      |
  | `M1: Golden Files Verified`   | 2026-08-08 | 8      |
  | `M2: MVP Core`                | 2026-08-22 | 16     |
  | `M3: Connectors + BE/FR`      | 2026-09-19 | 4      |

  Because milestones carry a due date and a burndown, they *are* the sprint
  mechanism here. No issue is left un-sprinted.

## Priorities

Two independent priority signals:

- `priority:P0/P1/P2` **labels** — the source of truth, already on every issue.
- The org-level **Priority** field (Urgent/High/Medium/Low) — currently unset.
  The board script below sets a board-scoped `Priority` field from the labels;
  populating the org field is optional and can be done later if wanted.

## Standing up the Projects (v2) board

The board is the one piece that must be created with your own credentials —
the GitHub Projects v2 API is not reachable from the automation environment
that scaffolded this repo, so it's delegated to a script.

```bash
# one-time: give gh the project scope
gh auth refresh -s project,read:project

# create the board, add fields, add all issues, set Sprint + Priority
./scripts/setup-github-project.sh
```

The script ([`scripts/setup-github-project.sh`](../scripts/setup-github-project.sh)):

1. Creates (or reuses) an org board titled **DoosDossier Delivery**.
2. Adds a **Sprint** single-select (options mirror `M0`–`M3`) and a
   **Priority** single-select (`P0`/`P1`/`P2`).
3. Adds every open issue to the board.
4. Sets each card's **Sprint** from its milestone and **Priority** from its
   `priority:*` label.

Every GitHub call is retried with backoff on transient network errors, and the
whole script is idempotent — safe to re-run after a dropped connection or when
new issues are added. Any issues that still fail after retries are listed at the
end so you know a re-run is needed.

### After running

One-click, in the board UI:

- Group a board/table view by **Sprint** (or the built-in **Milestone** field)
  to get sprint columns.
- For GitHub's **Current / Planned** sprint view and burndown, add a date-based
  **Iteration** field — this is the one thing that can only be created in the
  board UI, not via the API/CLI: **⋯ → Settings → Fields → ＋ New field →
  type _Iteration_**. Name the iterations `M0…`, `M1…`, `M2…`, `M3…`, then
  **re-run the script** — it detects the Iteration field and assigns each issue
  to its matching iteration automatically.
