"""dd_schemes — SchemeAdapter contract + registry (Decision 0002/0009).

A SchemeAdapter converts engine output (kg per material, as integer
grams — N-05) into the submission format of one PRO.
Rounding and category mapping live EXCLUSIVELY here.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Protocol
import json

__all__ = ["MaterialTotal", "SchemeInput", "SchemeAdapter", "REGISTRY", "register"]


@dataclass(frozen=True)
class MaterialTotal:
    material: str          # internal material taxonomy code
    grams: int             # integer grams (N-05) — never floats


@dataclass(frozen=True)
class SchemeInput:
    scheme: str            # e.g. "verpact", "lucid"
    country: str           # ISO-2 destination country
    period: str            # e.g. "2026" or "2026-H1"
    ruleset_version: str   # explicit ruleset version (Decision 0003)
    tenant: dict           # registration numbers etc. — no end-customer PII
    totals: tuple[MaterialTotal, ...] = field(default_factory=tuple)

    @staticmethod
    def from_json(path: Path) -> "SchemeInput":
        raw = json.loads(path.read_text(encoding="utf-8"))
        return SchemeInput(
            scheme=raw["scheme"],
            country=raw["country"],
            period=raw["period"],
            ruleset_version=raw["ruleset_version"],
            tenant=raw.get("tenant", {}),
            totals=tuple(
                MaterialTotal(material=t["material"], grams=int(t["grams"]))
                for t in raw.get("totals", [])
            ),
        )


class SchemeAdapter(Protocol):
    scheme: str

    def validate(self, data: SchemeInput) -> list[str]:
        """Returns human-readable error messages; empty = valid."""
        ...

    def render(self, data: SchemeInput) -> dict[str, bytes]:
        """Filename → bytes; compared byte-exact with expected/."""
        ...


REGISTRY: dict[str, SchemeAdapter] = {}


def register(adapter: SchemeAdapter) -> SchemeAdapter:
    REGISTRY[adapter.scheme] = adapter
    return adapter


# Import adapters so they self-register.
from . import example_csv  # noqa: E402,F401