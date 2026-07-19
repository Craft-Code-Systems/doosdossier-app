# Golden-harness — PRO exports as gatekeeper

This is the test structure from Decision 0011 / N-01: **you** fill golden
files from official PRO specs, the **agent** builds SchemeAdapters until
everything is byte-exact green. This folder moves 1-to-1 to
`services/doosdossier-api/` at repo bootstrap.

## Structure

```
dd_schemes/            SchemeAdapter contract + registry (+ _example)
tests/test_golden.py   discovers and runs all cases
golden/<scheme>/<year>/case_*/
  meta.json            source, version, status: todo|verified, verified_by
  input.json           SchemeInput fixture (grams as integer, N-05)
  expected/            expected output files, byte-exact
```

## Workflow per research hour (so your hours land directly)

1. Open the worksheet in `docs/schemes/<pro>-2026.md` and fill in source,
   version, categories, units, and rounding.
2. Create/update a case: `input.json` + manually(!) composed
   `expected/` files per the official spec.
3. Set `meta.json` to `"status": "verified"` with source + date + who.
4. `pytest` → red. Agent implements adapter → green → merge.

## Rules

- `expected/` is **never** generated or "fixed" by the agent.
- Every verified case has full provenance (enforced by
  `test_verified_cases_have_provenance`).
- Rounding/mapping only in adapters, never in the engine (N-05).

## Running

```bash
pytest golden-harness/tests -q
```