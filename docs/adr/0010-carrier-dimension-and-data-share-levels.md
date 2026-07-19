# Decision 0010: Carrier dimension now, tracking data sharing later as opt-in

**Status:**      Accepted
**Date:**        2026-07-13

## Context

DoosDossier data can feed PakketRadar's B2B data layer. With a public
AGPL repo (0008), hidden collection is by definition visible in the code
and fatal for both brands. Decision 0006 (aggregates only, no PII)
remains the framework.

## Decision

Level 1 (MVP): VolumeRecord gets an optional carrier dimension
(carrier × country × period × quantity), explicitly named in the
privacy statement. Level 2 (post-MVP): sharing tracking events becomes
an explicit opt-in module with processor agreements and incentives — a
separate legal and pipeline track, not in the MVP sprint.

## Considerations

**Pro:** level 1 is legally light (no PII, falls within 0006), delivers
immediate carrier-mix market intel and carries the peer benchmark
(F-19/F-20); level 2 becomes sender-side exactly the "Strava Metro"
dataset, but at own pace and with clean consent.
**Con:** level 1 alone says nothing about delivery performance; benchmark
needs k-anonymity (O-17) before anything may be shown.

Rejected: tracking data directly in MVP (legal track + pipeline don't
fit in 3–4 weeks); collect nothing at all (wastes the natural synergy
with PakketRadar).

## Consequences

- Data model: `carrier` as optional field on VolumeRecord (F-20)
- Privacy statement explicitly names the carrier aggregation
- Level 2 gets its own Decision + DPIA check in due course

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*