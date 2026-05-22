#!/usr/bin/env python3
"""Duplicate MyBatis statements that need SQL dialect into mysql/sqlserver branches."""
import re
from pathlib import Path

MAPPER_DIR = Path(__file__).resolve().parents[2] / "server" / "src" / "main" / "resources" / "mybatis" / "mapper"
TAGS = ("insert", "update", "select", "delete")


def needs_dialect(body: str) -> bool:
    b = body.lower()
    return (
        "`" in body
        or "now()" in b
        or "insert ignore" in b
        or "replace into" in b
        or "if(" in b
        or "last_insert_id" in b
    )


def to_sqlserver(body: str) -> str:
    s = body
    s = s.replace("LAST_INSERT_ID()", "SCOPE_IDENTITY()")
    s = re.sub(r"`(\w+)`", r"[\1]", s)
    s = re.sub(r"\bNOW\(\)", "GETDATE()", s)
    s = re.sub(r"\binsert\s+ignore\s+into\b", "insert into", s, flags=re.I)
    s = re.sub(r"\binsert\s+ignore\s+", "insert into ", s, flags=re.I)
    s = re.sub(r"\breplace\s+into\b", "merge into", s, flags=re.I)
    # IF(a,b,c) -> IIF(a,b,c) for simple cases
    s = re.sub(r"\bIF\s*\(", "IIF(", s)
    return s


def process_file(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    changed = False
    for tag in TAGS:
        pattern = re.compile(
            rf"<({tag})\s+([^>]*?)>(.*?)</\1>",
            re.DOTALL | re.IGNORECASE,
        )

        def repl(m):
            nonlocal changed
            tag_name, attrs, body = m.group(1), m.group(2), m.group(3)
            if "databaseId=" in attrs:
                return m.group(0)
            if not needs_dialect(body):
                return m.group(0)
            changed = True
            mysql = f'<{tag_name} databaseId="mysql" {attrs.strip()}>{body}</{tag_name}>'
            ss_body = to_sqlserver(body)
            sqlserver = f'<{tag_name} databaseId="sqlserver" {attrs.strip()}>{ss_body}</{tag_name}>'
            return mysql + "\n\n    " + sqlserver

        text = pattern.sub(repl, text)
    if changed:
        path.write_text(text, encoding="utf-8")
        print("Updated dialect statements:", path.name)


for xml in sorted(MAPPER_DIR.glob("*Mapper.xml")):
    process_file(xml)
