#!/usr/bin/env python3
"""Convert bin/davinci.sql (MySQL) to bin/davinci.sqlserver.sql."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
src = (ROOT / "davinci.sql").read_text(encoding="utf-8")
out = [
    "-- Davinci system database schema for Microsoft SQL Server",
    "-- Generated from bin/davinci.sql",
    "",
]

blocks = re.split(r"(?=DROP TABLE IF EXISTS)", src)
for block in blocks[1:]:
    if not block.strip():
        continue
    m = re.search(r"DROP TABLE IF EXISTS `?(\w+)`?", block)
    if not m:
        continue
    tname = m.group(1)
    b = block
    b = re.sub(
        rf"DROP TABLE IF EXISTS `?{tname}`?;",
        f"IF OBJECT_ID(N'dbo.{tname}', N'U') IS NOT NULL DROP TABLE dbo.[{tname}];",
        b,
        count=1,
    )
    b = re.sub(rf"CREATE TABLE `?{tname}`?\s*\(", f"CREATE TABLE dbo.[{tname}] (", b, count=1)
    b = re.sub(r"`(\w+)`", r"[\1]", b)
    b = re.sub(r"\bbigint\(\d+\)", "BIGINT", b)
    b = re.sub(r"\bint\(\d+\)", "INT", b)
    b = re.sub(r"\bsmallint\(\d+\)", "SMALLINT", b)
    b = re.sub(r"\btinyint\(1\)", "TINYINT", b)
    b = re.sub(r"\bvarchar\((\d+)\)(?:\s+COLLATE\s+\w+)?", r"NVARCHAR(\1)", b)
    b = re.sub(r"\blongtext\b", "NVARCHAR(MAX)", b)
    b = re.sub(r"\btext\b", "NVARCHAR(MAX)", b)
    b = re.sub(r"\bdatetime\b", "DATETIME2", b)
    b = re.sub(r"\btimestamp\b", "DATETIME2", b)
    b = re.sub(r"NOT NULL AUTO_INCREMENT", "NOT NULL IDENTITY(1,1)", b)
    b = re.sub(r"\bAUTO_INCREMENT\b", "IDENTITY(1,1)", b)
    b = re.sub(r"DEFAULT CURRENT_TIMESTAMP", "DEFAULT GETDATE()", b)
    b = re.sub(r"ON UPDATE CURRENT_TIMESTAMP", "", b)
    b = re.sub(r"DEFAULT '0'", "DEFAULT 0", b)
    b = re.sub(r"DEFAULT '1'", "DEFAULT 1", b)
    b = re.sub(r"NOT NULL DEFAULT ''", "NOT NULL DEFAULT N''", b)
    b = re.sub(r" PRIMARY KEY \([^)]+\) USING BTREE", lambda x: x.group(0).replace(" USING BTREE", ""), b)
    b = re.sub(r"\s+COLLATE\s+\w+", "", b)
    b = re.sub(r",?\s*UNIQUE KEY \[([^\]]+)\]\s*\(([^)]+)\)(?:\s+USING\s+BTREE)?", r",\n    CONSTRAINT [\1] UNIQUE (\2)", b)
    b = re.sub(r",?\s*KEY \[([^\]]+)\]\s*\([^)]+\)(?:\s+USING\s+BTREE)?", "", b)
    b = re.sub(r"\) ENGINE\s*=\s*InnoDB[^;]*;", ");", b, flags=re.I)
    b = re.sub(r" COMMENT = '[^']*';", ";", b)
    b = re.sub(r" COMMENT '[^']*'", "", b)
    b = re.sub(r",\s*\n\s*\)", "\n)", b)
    b = re.sub(r"-- -+\n-- Table structure[^\n]*\n-- -+\n", "", b)
    out.append(b.strip())
    out.append("GO")
    out.append("")

insert_part = re.search(r"(INSERT INTO[\s\S]+)", src)
if insert_part:
    ins = insert_part.group(1)
    ins = ins.replace("SET FOREIGN_KEY_CHECKS = 1;", "").strip()
    ins = re.sub(r"INSERT INTO `(\w+)`", r"INSERT INTO dbo.[\1]", ins)
    ins = re.sub(r"`(\w+)`", r"[\1]", ins)
    out.append(ins)
    out.append("GO")

(ROOT / "davinci.sqlserver.sql").write_text("\n".join(out), encoding="utf-8")
print("Wrote", ROOT / "davinci.sqlserver.sql")
