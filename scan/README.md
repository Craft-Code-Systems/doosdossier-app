# DoosDossier — free PPWR scan (M0)

Static Cloudflare Pages project: `public/index.html` (zero deps, no
trackers, system fonts) + one Pages Function (`/api/lead`) storing
leads in D1. Same playbook as the mijnpakketradar.nl waitlist.

## Deploy (±10 min)

```bash
wrangler d1 create doosdossier-leads          # note database_id
# → fill database_id in wrangler.toml
wrangler d1 execute doosdossier-leads --remote --file=schema.sql
wrangler pages deploy                          # from this directory
# then: connect custom domain (e.g., scan.doosdossier.nl or doosdossier.nl)
```

## Export leads

```bash
wrangler d1 execute doosdossier-leads --remote \
  --command "SELECT email, statuses, created_at FROM leads ORDER BY created_at DESC" --json
```

## Before launch (blocking)

See the checklist in the header of `public/index.html`:
verify PRO claims (Spec O-01/O-02) and record trademark (O-16). The
scan deliberately names NO thresholds and gives NO legal advice — keep
it that way until O-02 is answered.

## What we measure (intentionally minimal)

Only: email + given answers + status per country. No IPs, no
user-agents, no cookies, no analytics.