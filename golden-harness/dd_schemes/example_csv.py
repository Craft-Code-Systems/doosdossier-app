"""Example adapter ("_example") — proves the golden harness works.

Not a real PRO. Remove once verpact/lucid have a verified first case.
"""
from __future__ import annotations

from . import SchemeInput, register


class ExampleCsvAdapter:
    scheme = "_example"

    def validate(self, data: SchemeInput) -> list[str]:
        errors: list[str] = []
        if not data.totals:
            errors.append("geen materiaaltotalen aangeleverd")
        if any(t.grams < 0 for t in data.totals):
            errors.append("negatief gewicht")
        return errors

    def render(self, data: SchemeInput) -> dict[str, bytes]:
        rows = sorted(data.totals, key=lambda t: t.material)
        lines = ["materiaal;gram"]
        lines += [f"{t.material};{t.grams}" for t in rows]
        lines.append(f"totaal;{sum(t.grams for t in rows)}")
        body = "\n".join(lines) + "\n"
        return {"report.csv": body.encode("utf-8")}


register(ExampleCsvAdapter())