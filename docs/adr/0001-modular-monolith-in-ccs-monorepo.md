# Decision 0001: Modular monolith within the CCS monorepo

**Status:**      Superseded by [Decision 0009](./0009-python-backend-sveltekit-frontend.md)
**Date:**        2026-07-11

## Context

DoosDossier originates alongside PakketRadar and future CCS tools. The
goal was modularity: reuse shared functionality across tools. Options:
runtime plugin system, microservices per module, or compile-time
modularity in a monorepo. Solo development and the existing monorepo
decision (apps/ + packages/ + services/) set the boundaries.

## Decision

DoosDossier becomes a modular monolith: a single SvelteKit full-stack
app (`apps/doosdossier`) with domain core and adapters as internal
packages; modules communicate in-process, never over the network within
the product.

## Considerations

**Pro:** 90% of modularity value at 10% of the cost; shared packages
(ui, auth, billing) with PakketRadar; single deploy unit fits solo +
Swarm; no distributed-monolith risk.
**Con:** no independent scalability per module — irrelevant for this
usage profile (no realtime, Q1 peaks).

Rejected: runtime plugins (months of plumbing, zero product);
microservices (latency/versioning/auth overhead without benefits);
separate FastAPI backend (second language without need — no heavy
compute, so TypeScript end-to-end suffices).

## Consequences

- `apps/doosdossier` (SvelteKit) + `packages/dd-core`,
  `packages/dd-schemes`, `packages/dd-connectors`
- Reuse existing shared packages where sensible
- Network crossing only at the outer edge (browser ↔ app)

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*