# DoosDossier

> SKU packaging register and per-country EPR reporting for Dutch
> cross-border webshops.

— License: AGPL-3.0 (Decision 0008) · free when self-hosted, paid for
hosted + maintained PRO formats

## Why

The PPWR applies from 12 August 2026. Every NL webshop selling to
DE/BE/FR is a "producer" per country with registration and reporting
obligations; packaging data is now scattered across supplier emails and
spreadsheets. The existing offering is consultancy (Ecosistant, Staxxer,
law firms) — self-service software for SMBs is missing. DoosDossier
turns packaging data into a register and generates the declarations per
PRO from it.

## Scope

**In scope (v1):** open source (AGPL-3.0) from launch; packaging catalog
at component level; SKU linkage (effective-dated); imports via CSV and
shop platforms; volume calculation kg per material per country per
period (with carrier dimension); exports for Verpact (NL), LUCID/VerpackG
(DE), Fost Plus (BE) and CITEO (FR); overview dashboard; obligations
matrix with public free scan as lead magnet.

**Not in scope:** legal advice (data tool, output "for review"); direct
submission to PROs (export = file); DoC generator and technical dossier
(wave 2); multi-tenant for fulfillment centers (wave 2); labelling and
recyclability grades (waiting for delegated acts); opt-in tracking data
module for PakketRadar (level 2, wave 2); countries outside NL/DE/BE/FR.

## Success criteria

- [ ] Free scan live in week of 13 July — catches the panic wave
- [ ] A webshop goes from empty account to complete Verpact annual
      declaration within 1 hour (defaults library as accelerator)
- [ ] All PRO exports validate with 0 deviations against the golden-file
      test set
- [ ] A 2026 report is bit-exact reproducible in 2027+
- [ ] ≥ 10 paying customers within 60 days of launch
- [ ] Free scan converts ≥ 25% of visitors to email address

## Capabilities

- Packaging catalog at component level (box, filling, tape, label, seal)
  with material, weight, recycled content %, PFAS flag, reusable y/n,
  and source reference
- Defaults library: standard packaging (FEFCO boxes, films, envelopes)
  with typical weights
- SKU ↔ packaging configuration, effective-dated, with classification
  primary / secondary / tertiary / shipping packaging
- Import of SKUs and order volumes per destination country: CSV first,
  then WooCommerce, Shopify, Lightspeed, Bol
- Calculation kg per material per country per reporting period, with
  optional carrier dimension (Decision 0010)
- Export in PRO format: Verpact, LUCID/VerpackG, Fost Plus, CITEO
- Packaging dashboard: kg per material/country over time, recycled-%,
  top-SKUs, year-over-year
- Obligations matrix country × role → obligation + deadline + status;
  public light version = free scan
- Audit trail on all compliance-relevant mutations
- Submitted reports frozen with input snapshot
- Accounts and subscriptions: Community €0 (self-host) · €29 · €79 · €199

Detail lives in [`docs/spec.md`](./docs/spec.md) (F-NN / N-NN) and
thereafter in the issue tracker.

## Non-functional baseline

- **Correctness:** deterministic pure calculations; golden-file test set
  per PRO per reporting year
- **Reproducibility:** all rules, fees, and mappings versioned with
  validity period (Decision 0003)
- **Privacy:** only aggregated volumes, no order/customer data
  (Decision 0006); EU hosting; strict tenant isolation
- **Availability:** 99.5%; peak load around declaration deadlines (Q1)
- **Performance:** no realtime requirements; export generation < 30 s

## Stakeholders & roles

- **Product owner / tech lead / maintainer:** Elwin Hammer (CCS) — solo
- **Community:** public repo, issues and PRs welcome; no support SLA
  during the build sprint (explicit in repo README)
- **Domain validation:** 10–15 webshops and fulfillment contacts from
  validation interviews
- **Distribution partners (wave 2):** fulfillment centers and
  e-commerce accountants via multi-tenant

## Risks

- **Risk:** delegated acts move (recyclability, labelling).
  **Mitigation:** extensible data model — core relational, material
  properties as versioned JSONB attributes.
- **Risk:** maintenance burden of PRO formats (annual changes).
  **Mitigation:** golden files + recurring maintenance block per quarter.
- **Risk:** competitors fork the public repo.
  **Mitigation:** AGPL-3.0 enforces openness; hosted connectors,
  defaults data, and format maintenance remain the paid story.
- **Risk:** community support burden during the 3–4-week sprint.
  **Mitigation:** explicit no-SLA expectation; issues > DMs.
- **Risk:** liability for incorrect declarations.
  **Mitigation:** positioning as data tool, output "for review",
  disclaimers in terms.
- **Risk:** timebox conflict with PakketRadar Black Friday launch.
  **Mitigation:** MVP sprint max 3–4 weeks; wave 2 only after BF; build
  largely agentic (Decision 0011).

## Stack

- **Language / framework:** FastAPI (Python) backend — engine,
  SchemeAdapters and connectors as Python packages; SvelteKit
  exclusively as frontend (Decision 0009); contract via OpenAPI →
  generated TS types
- **Data store:** Postgres (Decision 0005)
- **PDF:** WeasyPrint (follows from Python choice; O-13 closed)
- **Infrastructure:** homelab Docker Swarm; migration to Hetzner at
  traction
- **Deploy target:** doosdossier.nl (domain yet to register); free scan
  on Cloudflare Pages + D1 (reuse waitlist pattern)

## Status & milestones

*13 July 2026 — docs v2 (Decisions 0001–0011), scan building block and
golden-file scaffold ready; validation interviews running, monorepo code
follows.*

- **M0 (this week):** free scan live + name/trademark recording (O-16)
- **M1 (mid July):** Verpact + LUCID field specs in `golden/` spec-notes,
  first verified golden files, willingness to pay confirmed
- **M2 (before 12 Aug):** MVP live — catalog, SKU linkage, CSV import,
  Verpact + LUCID export, dashboard overview
- **M3 (Aug–Sep):** platform connectors, Fost Plus + CITEO
- **Wave 2 (after PakketRadar BF):** DoC generator, multi-tenant,
  benchmark + shareable sustainability overview, data module level 2

## Getting started

**Today (this repo):** two self-contained building blocks run standalone:

```
# Free PPWR scan (Cloudflare Pages + D1) — see scan/README.md
cd scan && wrangler pages dev

# Golden-file harness (PRO export gatekeeper) — see golden-harness/README.md
pip install pytest && pytest golden-harness/tests -q
```

**Intended (after bootstrap):** the app moves into the CCS monorepo,
where `golden-harness/` becomes `services/doosdossier-api/` and a
SvelteKit `doosdossier-web` is added. Target developer setup:

```
git clone git@github.com:Craft-Code-Systems/<monorepo>.git
cd <monorepo>
pnpm install && uv sync
pnpm --filter doosdossier-web dev
uv run fastapi dev services/doosdossier-api
```

## More

- [Runbook](./docs/runbook.md) — run, deploy, unbreak *(follows at bootstrap)*
- [Decisions](./docs/adr/) — why design choices were made
- [Log](./docs/research-log.md) — exploration notes
- [Spec](./docs/spec.md) — detailed requirements
- [Changelog](./CHANGELOG.md)

---

<sub>This project uses [Colophon](https://usecolophon.dev) for its
documentation. *Brief* (this file), *Decisions*, *Log*, *Runbook*, and
*Changelog* — plus an optional *Spec* if needed.</sub>