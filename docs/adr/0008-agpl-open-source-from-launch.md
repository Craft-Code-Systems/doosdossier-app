# Decision 0008: AGPL-3.0 open source from launch

**Status:**      Accepted
**Date:**        2026-07-13
**Supersedes:**  [Decision 0007](./0007-closed-source-until-after-deadline-wave.md)

## Context

Decision 0007 kept DoosDossier closed to protect the moat (canopy formats,
report logic). New insight: open source as an acquisition channel ("free if
you self-host") and community signal weighs heavier, provided the fork risk
is legally covered and the framing is transparent — the OSS audience
punishes sneaky fine print.

## Decision

The entire application goes public under AGPL-3.0 at launch; free =
self-host, paid = hosted + annually maintained canopy formats, hosted
platform connectors (our OAuth apps), defaults library data, and (later)
multi-tenant.

## Considerations

**Pro:** AGPL forces SaaS forks to full openness — that removes the core
objection from 0007; credibility/Tweakers effect like PakketRadar;
self-hosters become ambassadors toward the paid tier.
**Con:** community support burden during the sprint (mitigation: explicit
no-SLA); format knowledge becomes readable to competitors — but maintaining
it remains the actual moat.

Rejected: closed (0007 — loses momentum and community); MIT/Apache (SaaS
clones free rein); open core (boundary runs straight through report logic).

## Consequences

- LICENSE = AGPL-3.0; trademark/trade name registration before publication
  (O-16)
- Pricing page communicates self-host option explicitly, not hidden
- Re-evaluation moment from 0007 lapses

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*