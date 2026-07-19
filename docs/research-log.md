# Log

Append-only, dated notes from exploration. Rough by design.
When something here crystallises into a real design choice, promote
it to a Decision. Do not rewrite older entries.

---

## 2026-07-03 — Market ranking e-commerce/logistics tools

Four opportunities researched and ranked: PPWR/EPR compliance (→ this
product), PeppolBrug, BezorgWacht, GroeneKilo. PPWR won on urgency
(deadline 12-08-2026) × small software offering × domain fit from
InstantPack. Competition (Ecosistant, Staxxer, 24hour-AR) is
consultancy/service; software-first self-service for SMB = gap.
Price indication €29–199 /mo on SKU-count + countries. Sequencing
framework: max 3–4 week MVP sprint alongside PakketRadar-BF, otherwise
skip.

## 2026-07-03 — Media gap around PPWR

Verification of the observation that e-commerce trade press is quiet:
correct. Content is dominated by law firms, consultants, and packaging
suppliers (SEO/leadgen); Twinkle one magazine article, Emerce virtually
nothing operational. Consequence: demand is latent — the panic wave
4–8 weeks before the deadline is THE visibility window.
GTM conclusion: create urgency yourself via free scan + LinkedIn +
borrowed audiences (fulfillment, accountants), not via compliance search
traffic.

## 2026-07-12 — Design session: modules, requirements, open questions

Module breakdown established (catalog, SKU register, connectors, engine,
scheme exports, obligations matrix, audit trail) and translated to
Brief + Spec (F-01…F-18, N-01…N-08). Core principles promoted to
Decisions 0001–0007. Biggest UX risk identified: data entry, not
reporting → defaults library (F-02) as must-have. Open regulatory
questions O-01…O-09 are the next research block (M1); field specs per
PRO determine the golden files.

## 2026-07-13 — Strategy pivot and build approach

Five course corrections processed: (1) open source directly under
AGPL-3.0, transparent "free = self-host" (Decision 0008, supersedes
0007); (2) hosted pricing confirmed: €0 self-host / €29 / €79 / €199,
annual plan with 2 months discount, no pay-per-declaration; (3) backend
to FastAPI/Python, SvelteKit frontend only (Decision 0009, supersedes
0001) — O-13 answered: WeasyPrint; (4) data collection for PakketRadar
in two levels: carrier dimension in aggregates now, opt-in tracking
module later (Decision 0010); (5) packaging dashboard as attraction
layer (F-19), shareable sustainability overview and peer benchmark in
wave 2. Build approach established: agentic (~80% code mass) with human
ownership of golden files and core review (Decision 0011) — hour budget
36–72 hrs until 12 Aug. Scan pulled out as week-1 deliverable (M0);
scaffold for golden/verpact and golden/lucid set up so research hours
land directly in spec-notes and cases.