# Decision 0006: Only aggregated volumes, no order or customer data

**Status:**      Accepted
**Date:**        2026-07-12

## Context

For declarations, only one thing is needed: how many units of which SKU
to which country in which period. Platform connectors can however fetch
full orders with customer PII. Storing that would unnecessarily enlarge
the GDPR surface (processor role towards webshop end customers) and the
data breach blast radius.

## Decision

DoosDossier stores only `VolumeRecord` aggregates
(SKU × destination country × period × quantity); order and customer data
are never persisted, not even temporarily.

## Considerations

**Pro:** minimal GDPR surface — no end-customer PII means a simple
processor agreement and a small data breach blast radius; smaller
storage; privacy as a selling point alongside EU hosting.
**Con:** no drill-down to order level when doubting figures —
verification must happen in the source platform; corrections run via
idempotent re-import of an entire period (F-05).

Rejected: store orders and aggregate at reporting time (maximum
flexibility, but exactly the risk we want to avoid); hash order IDs
(still traceable, sham solution).

## Consequences

- Connectors aggregate in-memory during sync; only aggregates hit the
  database
- Re-import of a period fully replaces aggregates for that period
- Privacy statement and processor agreement can be short and clear

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*