# Decision 0005: Postgres as datastore (no D1/edge)

**Status:**      Accepted
**Date:**        2026-07-12

## Context

PakketRadar runs on Cloudflare Pages + D1; reusing that stack was
obvious. DoosDossier is however relationally heavy (effective-dated
joins across SKUs, configurations, mappings, snapshots), needs JSONB for
extensible attributes and snapshots, and has no edge-latency need — it's
a B2B dashboard with Q1 peaks.

## Decision

Postgres is the sole datastore, running on the homelab Swarm and
migrated to Hetzner at traction.

## Considerations

**Pro:** mature JSONB + constraints + window functions fit effective
dating (0003) and snapshots (0004) exactly; one database for everything;
trivial to run and test locally; migration path to managed Postgres is a
dump.
**Con:** no Cloudflare-free-tier like D1 — hosting responsibility
(backups!) lies with us; deviation from the PakketRadar stack means two
database flavors in the monorepo.

Rejected: D1/SQLite (limited JSONB/constraints, edge benefit unused);
MySQL (no advantage over existing Postgres experience); separate
document store for snapshots (second system without necessity).

## Consequences

- Postgres service in the Swarm with daily offsite backup
  (restore test in runbook)
- Migrations via one tool from day 1
- EU data location guaranteed (N-03): homelab → Hetzner

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*