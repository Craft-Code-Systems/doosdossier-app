# Decision 0002: Two adapter families — PlatformConnector and SchemeAdapter

**Status:**      Accepted
**Date:**        2026-07-12

## Context

DoosDossier has two variable external boundaries: input (shop platforms:
WooCommerce, Shopify, Lightspeed, Bol, CSV) and output (PROs:
Verpact, LUCID, Fost Plus, CITEO). Both change independently of the
core and grow in number. PakketRadar proved the CarrierAdapter contract
pattern for exactly this problem.

## Decision

All input goes through a `PlatformConnector` contract and all output
through a `SchemeAdapter` contract (validate → transform → render); the
domain core knows neither and operates exclusively on the internal
model.

## Considerations

**Pro:** new PRO or new platform = one new adapter + golden files, zero
core changes (N-08); per adapter isolated testability; the moat
(maintaining formats) gets a fixed, cheap form.
**Con:** indirection layer that would be overkill at n=1 — but we
already start with 4 PROs and 5 input forms.

Rejected: per-PRO logic in the engine (rounding and categories would
leak into calculation); one generic export format with templates-only
(PROs also differ in validation rules, not just formatting).

## Consequences

- Contracts in `packages/dd-core`, implementations in
  `packages/dd-schemes` and `packages/dd-connectors`
- Golden-file test set per SchemeAdapter per reporting year (N-01)
- Rounding and category mapping live exclusively in SchemeAdapters
  (N-05)

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*