# Decision 0004: Submitted reports are immutable with input snapshot

**Status:**      Accepted
**Date:**        2026-07-12

## Context

A declaration is compliance evidence. After submission to a PRO, source
data simply keeps changing (corrections, subsequent volumes, new
linkages). Without measures, a submitted report can no longer be
reconstructed later, and Decision 0003 only covers rule versions — not
the tenant data at that moment.

## Decision

A generated report freezes all inputs (volumes, configurations, rule
versions, mappings) as a snapshot; the report itself thereafter is
append-only history, corrections are a new report that references the
old one.

## Considerations

**Pro:** re-rendering from snapshot is bit-identical (F-14) — the
strongest possible audit position; discussions with PROs or auditors
become verifiable; aligns with Colophon-style supersession mechanics
that have already proven themselves.
**Con:** storage grows with each report (acceptable: aggregates are
small); users must learn that "adjust report" doesn't exist — UX must
explicitly offer correction flow.

Rejected: report as view on live data (unreconstructable); only save
PDF (not recalculable, no machine-readable evidence).

## Consequences

- `Report` entity with status (draft → final) and JSONB snapshot of all
  inputs
- Correction report references predecessor via `supersedes`
- UI: making final = explicit, irreversible action

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*