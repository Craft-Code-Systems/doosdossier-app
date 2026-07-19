# Decision 0003: Effective dating and versioned rules as core principle

**Status:**      Accepted
**Date:**        2026-07-12

## Context

Everything in this domain changes over time: PRO formats and fees change
per year, delegated acts add fields, SKU packagings change continuously.
A 2026 declaration must be exactly reproducible in 2028 with the 2026
rules — for audits and for correction declarations.

## Decision

Every rule, every fee, every material→PRO-category mapping, and every
SKU↔configuration linkage gets a validity period; calculations always
run against an explicit rule version.

## Considerations

**Pro:** reproducibility becomes a property of the data model instead of
a discipline concern; year transitions and mid-year changes (F-03) fall
out of the same mechanism; delegated-act changes become a new rule
version, not a migration drama.
**Con:** every query and every form becomes time-aware — noticeably more
complex than a flat CRUD model; discipline required to never mutate
"just in-place."

Rejected: mutable rules + database backups as history (unusable for
recalculation); full event sourcing (overkill; effective dating + audit
trail covers the need).

## Consequences

- Core entities (Material, mapping tables, SKU linkage) get
  `valid_from`/`valid_to`
- Engine API requires explicit rule-set version as parameter
- Golden files exist per PRO per reporting year

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*