#!/usr/bin/env python3
"""Convert bin/patch/*.sql to bin/patch-sqlserver/*.sql."""
import re
from pathlib import Path

PATCH = Path(__file__).resolve().parents[1] / "patch"
OUT = Path(__file__).resolve().parents[1] / "patch-sqlserver"
OUT.mkdir(exist_ok=True)


def convert_line(line: str) -> str:
    s = line
    if not s.strip() or s.strip().startswith("/*") or s.strip().startswith("*"):
        return s
    s = re.sub(r"`(\w+)`", r"[\1]", s)
    s = re.sub(r"\bNOW\(\)", "GETDATE()", s, flags=re.I)
    s = re.sub(r"ADD COLUMN\s+", "ADD ", s, flags=re.I)
    s = re.sub(r"\s+AFTER\s+`?\w+`?", "", s, flags=re.I)
    s = re.sub(r"\bMODIFY COLUMN\b", "ALTER COLUMN", s, flags=re.I)
    s = re.sub(r"\bbigint\(\d+\)", "BIGINT", s)
    s = re.sub(r"\bint\(\d+\)", "INT", s)
    s = re.sub(r"\bsmallint\(\d+\)", "SMALLINT", s)
    s = re.sub(r"\bvarchar\((\d+)\)", r"NVARCHAR(\1)", s)
    s = re.sub(r"\btimestamp\(\d+\)", "DATETIME2", s)
    s = re.sub(r"\btimestamp\b", "DATETIME2", s)
    s = re.sub(r"\btext\b", "NVARCHAR(MAX)", s)
    s = re.sub(r"DEFAULT CURRENT_TIMESTAMP", "DEFAULT GETDATE()", s)
    s = re.sub(r"ALTER TABLE \[(\w+)\]", r"ALTER TABLE dbo.[\1]", s)
    s = re.sub(r"ALTER TABLE (\w+)", r"ALTER TABLE dbo.[\1]", s)
    return s


def convert_file(text: str) -> str:
    lines = text.splitlines()
    out = []
    for line in lines:
        out.append(convert_line(line))
    return "\n".join(out) + ("\n" if text.endswith("\n") else "")


for f in sorted(PATCH.glob("*.sql")):
    if f.name == "001_beta5.sql":
        # Large migration: run full DDL converter on patch body
        import subprocess
        import sys
        tmp = PATCH.parent / "scripts" / "_tmp_beta5.sql"
        body = f.read_text(encoding="utf-8")
        header_end = body.find("DROP TABLE")
        if header_end < 0:
            header_end = 17
        header = body[:body.find("set @", 0) if "set @" in body else 17]
        # use mysql_to_sqlserver logic inline
        from importlib.util import spec_from_loader, module_from_spec
        conv = Path(__file__).parent / "mysql_to_sqlserver.py"
        # simplified: copy with table conversion for 001
        converted = convert_file(body)
        (OUT / f.name).write_text(
            "-- SQL Server: beta.4 -> beta.5 migration. Review before apply.\n"
            + converted,
            encoding="utf-8",
        )
    else:
        (OUT / f.name).write_text(convert_file(f.read_text(encoding="utf-8")), encoding="utf-8")
    print("Wrote", OUT / f.name)
