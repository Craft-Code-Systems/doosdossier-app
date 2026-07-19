# DoosDossier

> SKU packaging register and per-country EPR reporting for Dutch
> cross-border webshops.

License: **AGPL-3.0** — free when self-hosted; a hosted, maintained
version with the PRO-format connectors is offered as a paid service.

## Why

The PPWR applies from 12 August 2026. Every NL webshop selling to
DE/BE/FR is a "producer" per country, each with its own registration and
reporting obligations — while the underlying packaging data is scattered
across supplier emails and spreadsheets. Today the available help is
consultancy; self-service software for SMBs is missing. DoosDossier turns
packaging data into a register and generates the per-PRO declarations
from it.

## Scope

**In scope (v1):** open source (AGPL-3.0) from launch; packaging catalog
at component level; SKU linkage (effective-dated); imports via CSV and
shop platforms; volume calculation in kg per material per country per
period (with an optional carrier dimension); exports for Verpact (NL),
LUCID/VerpackG (DE), Fost Plus (BE) and CITEO (FR); an overview
dashboard; and an obligations matrix, with a public free scan.

**Not in scope:** legal advice (this is a data tool; output is "for
review"); direct submission to PROs (export produces a file); DoC
generator and technical dossier; multi-tenant for fulfillment centers;
labelling and recyclability grades (awaiting the delegated acts);
countries outside NL/DE/BE/FR.

## Capabilities

- Packaging catalog at component level (box, filling, tape, label, seal)
  with material, weight, recycled content %, PFAS flag, reusable y/n,
  and a source reference
- Defaults library: standard packaging (FEFCO boxes, films, envelopes)
  with typical weights
- SKU ↔ packaging configuration, effective-dated, classified as
  primary / secondary / tertiary / shipping packaging
- Import of SKUs and order volumes per destination country: CSV first,
  then WooCommerce, Shopify, Lightspeed, Bol
- Calculation of kg per material per country per reporting period, with
  an optional carrier dimension
- Export in PRO format: Verpact, LUCID/VerpackG, Fost Plus, CITEO
- Packaging dashboard: kg per material/country over time, recycled-%,
  top SKUs, year-over-year
- Obligations matrix (country × role → obligation + deadline + status);
  a light public version is available as a free scan
- Audit trail on all compliance-relevant mutations
- Submitted reports frozen together with their input snapshot

Detailed requirements live in [`docs/spec.md`](./docs/spec.md) and,
thereafter, in the issue tracker.

## Design principles

- **Correctness:** deterministic, pure calculations, guarded by a
  golden-file test set per PRO per reporting year
- **Reproducibility:** rules, fees, and mappings are versioned with a
  validity period, so a past report stays bit-exact reproducible in
  later years
- **Privacy:** only aggregated volumes are stored — no order or customer
  data; EU hosting; strict tenant isolation

## Stack

- **Backend:** FastAPI (Python) — engine, SchemeAdapters and connectors
  as Python packages
- **Frontend:** SvelteKit; contract via OpenAPI → generated TS types
- **Data store:** Postgres
- **PDF:** WeasyPrint
- **Free scan:** static site + function on Cloudflare Pages + D1

## Getting started

> **Status:** the full application (FastAPI engine + SvelteKit
> frontend) is being built and does not live in this repository yet.
> Two self-contained pieces run today.

### Free PPWR scan (`scan/`)

A static Cloudflare Pages site plus one Pages Function that stores leads
in D1. Run it locally with [Wrangler](https://developers.cloudflare.com/workers/wrangler/):

```bash
cd scan
wrangler pages dev
```

Deployment and lead-export steps are in [`scan/README.md`](./scan/README.md).

### Golden-file harness (`golden-harness/`)

The test set that gates the PRO exports: hand-verified expected files
per PRO per year, with adapters built until every case is byte-exact
green. Requires Python and `pytest`:

```bash
pip install pytest
pytest golden-harness/tests -q
```

See [`golden-harness/README.md`](./golden-harness/README.md) for the
per-case structure and the workflow.

## Contributing & support

This is a public repository — issues and pull requests are welcome.
Support is best-effort: please use the issue tracker rather than direct
messages, and note there is no support SLA.

## Disclaimer

DoosDossier is a data tool, not a source of legal advice. Its exports
are intended **for review** before you submit anything to a PRO or
authority. You remain responsible for the correctness and completeness
of your declarations.

## More

- [Decisions](./docs/adr/) — why the design choices were made
- [Research log](./docs/research-log.md) — exploration notes
- [Spec](./docs/spec.md) — detailed requirements
- [Changelog](./CHANGELOG.md)
- [License](./LICENSE) — AGPL-3.0

---

<sub>This project uses [Colophon](https://usecolophon.dev) for its
documentation. The full internal brief (goals, milestones, risks) lives
in [`brief.md`](./brief.md).</sub>
