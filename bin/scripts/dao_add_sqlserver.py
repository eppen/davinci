#!/usr/bin/env python3
"""Add databaseId mysql/sqlserver pairs to MyBatis annotations in *Mapper.java."""
import re
from pathlib import Path

DAO_DIR = Path(__file__).resolve().parents[2] / "server" / "src" / "main" / "java" / "edp" / "davinci" / "dao"
ANNOTATIONS = ("Select", "Update", "Insert", "Delete")


def needs_dialect(sql: str) -> bool:
    return "`" in sql or "now()" in sql.lower()


def to_sqlserver(sql: str) -> str:
    s = sql
    s = re.sub(r"`(\w+)`", r"[\1]", s)
    s = re.sub(r"\bNOW\(\)", "GETDATE()", s, flags=re.I)
    return s


def process_annotation_block(ann, inner, original):
    if "databaseId" in inner:
        return original
    # extract string array content
    strings = re.findall(r'"((?:[^"\\]|\\.)*)"', inner)
    if not strings:
        return original
    combined = " ".join(strings)
    if not needs_dialect(combined):
        return original
    mysql_inner = inner
    if "value" not in inner:
        mysql_inner = f'value = {{{inner}}}, databaseId = "mysql"'
    else:
        mysql_inner = re.sub(r"databaseId\s*=\s*\"[^\"]*\"", 'databaseId = "mysql"', inner)
        if "databaseId" not in mysql_inner:
            mysql_inner = mysql_inner.rstrip() + ', databaseId = "mysql"'
    ss_strings = [to_sqlserver(s) for s in strings]
    ss_array = ", ".join(f'"{s}"' for s in ss_strings)
    if "value" in inner:
        ss_inner = re.sub(r'\{[^}]+\}', "{" + ss_array + "}", inner)
        ss_inner = re.sub(r"databaseId\s*=\s*\"[^\"]*\"", '', ss_inner)
        ss_inner = ss_inner.replace("value =", 'value =').rstrip().rstrip(',') + ', databaseId = "sqlserver"'
    else:
        ss_inner = f'value = {{{ss_array}}}, databaseId = "sqlserver"'
    return f"@{ann}({mysql_inner})\n    @{ann}({ss_inner})"


def process_file(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    orig = text
    for ann in ANNOTATIONS:
        pattern = re.compile(rf"@{ann}\(([^;]+?)\)\s*\n", re.DOTALL)
        def repl(m):
            orig = m.group(0)
            return process_annotation_block(ann, m.group(1), orig) + "\n"
        text = pattern.sub(repl, text)
    if text != orig:
        path.write_text(text, encoding="utf-8")
        print("Updated", path.name)


for java in sorted(DAO_DIR.glob("*Mapper.java")):
    process_file(java)
