"""Golden-file gatekeeper (N-01, Decision 0011).

Each case = golden/<scheme>/<year>/case_*/ with:
  meta.json   — source, version, status ("todo" | "verified"), verified_by
  input.json  — SchemeInput fixture
  expected/   — expected output files, byte-exact

Rules:
- status != "verified"  → test skipped with source reference
- verified cases        → render() must byte-exact match
- golden files are ONLY filled by a human from official PRO specs —
  never by the agent (Decision 0011).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from dd_schemes import REGISTRY, SchemeInput  # noqa: E402

CASES = sorted(p for p in ROOT.glob("golden/*/*/case_*") if p.is_dir())


def _case_id(p: Path) -> str:
    return "/".join(p.parts[-3:])


@pytest.mark.parametrize("case_dir", CASES, ids=_case_id)
def test_golden(case_dir: Path):
    meta = json.loads((case_dir / "meta.json").read_text(encoding="utf-8"))
    if meta.get("status") != "verified":
        pytest.skip(f"waiting for verified spec — source: {meta.get('source', 'unknown')}")

    scheme = case_dir.parts[-3]
    assert scheme in REGISTRY, f"no SchemeAdapter registered for '{scheme}'"
    adapter = REGISTRY[scheme]

    data = SchemeInput.from_json(case_dir / "input.json")
    errors = adapter.validate(data)
    assert not errors, f"validate() failed: {errors}"

    rendered = adapter.render(data)
    expected_dir = case_dir / "expected"
    expected = {p.name: p.read_bytes() for p in expected_dir.iterdir() if p.is_file()}

    assert set(rendered) == set(expected), (
        f"file set differs: render={sorted(rendered)} expected={sorted(expected)}"
    )
    for name, blob in expected.items():
        assert rendered[name] == blob, f"{name} is not byte-identical to golden file"


def test_verified_cases_have_provenance():
    """A verified case without source/verifier is worthless as evidence."""
    for case_dir in CASES:
        meta = json.loads((case_dir / "meta.json").read_text(encoding="utf-8"))
        if meta.get("status") == "verified":
            for field in ("source", "source_version", "verified_by", "verified_date"):
                assert meta.get(field), f"{_case_id(case_dir)}: meta.json missing '{field}'"