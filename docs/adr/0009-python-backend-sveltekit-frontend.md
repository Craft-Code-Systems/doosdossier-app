# Decision 0009: FastAPI backend (Python), SvelteKit frontend only

**Status:**      Accepted
**Date:**        2026-07-13
**Supersedes:**  [Decision 0001](./0001-modular-monolith-in-ccs-monorepo.md)

## Context

Decision 0001 chose TypeScript end-to-end (SvelteKit full-stack) and
rejected a separate FastAPI backend. Reconsideration: WeasyPrint (PDF) is
Python-native, Pydantic fits canopy validation exactly, hypothesis gives
property-based tests on the engine, and PakketRadar services already use
the FastAPI idiom — one backend language across CCS products.

## Decision

Backend becomes FastAPI (`services/doosdossier-api`) with engine,
SchemeAdapters, and connectors as Python packages; SvelteKit
(`apps/doosdossier-web`) is purely frontend; the modulith and monorepo
principles from 0001 remain fully intact.

## Considerations

**Pro:** strongest tooling for exactly the critical layers (validation,
PDF, property-based tests); language consistency with PakketRadar services;
O-13 (PDF-lib) resolves itself.
**Con:** two languages in one product — mitigated by OpenAPI → generated
TS types as the single contract source; frontend must never duplicate
domain logic.

Rejected: keep TS end-to-end (loses WeasyPrint/Pydantic/hypothesis);
Node-PDF via Puppeteer (heavy runtime, fragile rendering for tax
documents).

## Consequences

- Packages: `dd_core`, `dd_schemes`, `dd_connectors` (Python);
  UI packages remain TypeScript
- CI: pytest + golden files as gate; OpenAPI type generation in the build
  pipeline
- In-process modulith inside the API; network only browser ↔ API

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*