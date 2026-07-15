# Decision 0009: FastAPI-backend (Python), SvelteKit uitsluitend frontend

**Status:**      Accepted
**Date:**        2026-07-13
**Supersedes:**  [Decision 0001](./0001-modulaire-monoliet-in-ccs-monorepo.md)

## Context

Decision 0001 koos TypeScript end-to-end (SvelteKit full-stack) en
verwierp een aparte FastAPI-backend. Heroverweging: WeasyPrint (PDF)
is Python-native, Pydantic past exact op koepel-validatie, hypothesis
geeft property-based tests op de engine, en PakketRadar-services
gebruiken al het FastAPI-idioom — één backend-taal over de
CCS-producten.

## Decision

Backend wordt FastAPI (`services/doosdossier-api`) met engine,
SchemeAdapters en connectoren als Python-packages; SvelteKit
(`apps/doosdossier-web`) is puur frontend; de modulith- en
monorepo-principes uit 0001 blijven onverkort gelden.

## Considerations

**Pro:** sterkste tooling voor precies de kritieke lagen (validatie,
PDF, property-based tests); taal-consistentie met
PakketRadar-services; O-13 (PDF-lib) lost hiermee vanzelf op.
**Con:** twee talen in één product — gemitigeerd door OpenAPI →
gegenereerde TS-types als énige contractbron; frontend mag nooit
domeinlogica dupliceren.

Verworpen: TS end-to-end handhaven (verliest WeasyPrint/Pydantic/
hypothesis); Node-PDF via Puppeteer (zware runtime, fragiele
rendering voor aangifte-documenten).

## Consequences

- Packages: `dd_core`, `dd_schemes`, `dd_connectors` (Python);
  UI-packages blijven TypeScript
- CI: pytest + golden files als poortwachter; OpenAPI-typegeneratie
  in de buildpijplijn
- In-process modulith binnen de API; netwerk alleen browser ↔ API

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*
