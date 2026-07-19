# Decision 0007: Closed source until after the deadline wave

**Status:**      Superseded by [Decision 0008](./0008-agpl-open-source-from-launch.md)
**Date:**        2026-07-11

## Context

CCS evaluates open source per product. For PakketRadar, client and
adapters go open in stages because the moat sits in the B2B data
pipeline. For DoosDossier the moat is exactly the reverse: the value
lies in the reporting logic and the maintained PRO formats — tedious
maintenance that competitors (Ecosistant, Staxxer) could directly take
over, right in the commercial peak around 12 Aug 2026.

## Decision

DoosDossier remains fully closed source through the 2026 deadline wave;
re-evaluation (e.g., SKU register open, report generation paid) is
planned after the first annual declaration cycle.

## Considerations

**Pro:** protects the moat at the moment of maximum demand; no
community support burden during a 3–4-week solo sprint; no free copy
path for consultancy competitors who already have distribution.
**Con:** no credibility/Tweakers effect like PakketRadar; no external
contributions to format maintenance — that remains fully own burden
(N-08).

Rejected: open core now (open/closed boundary cuts across the reporting
logic — precisely the valuable part); AGPL fully open (license doesn't
sufficiently deter SaaS clones for a product that's mainly data/formats).

## Consequences

- Private repo in the monorepo; no public references to internal format
  knowledge
- Schedule re-evaluation: Q1 2027, after the first annual declaration
  cycle (new Decision)
- Marketing leans on the free scan (F-12), not on open source

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*