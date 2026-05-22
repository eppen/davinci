#!/usr/bin/env python3
"""Add databaseId mysql/sqlserver branches to Mapper insert id=insert blocks."""
import re
from pathlib import Path

MAPPER_DIR = Path(__file__).resolve().parents[2] / "server" / "src" / "main" / "resources" / "mybatis" / "mapper"


def to_sqlserver_block(block: str) -> str:
    s = block
    s = re.sub(r'<insert id="insert"', '<insert id="insert" databaseId="sqlserver"', s, count=1)
    s = s.replace("LAST_INSERT_ID()", "SCOPE_IDENTITY()")
    s = re.sub(r"`(\w+)`", r"[\1]", s)
    s = re.sub(r"\bNOW\(\)", "GETDATE()", s)
    return s


def process_insert(content: str) -> str:
    pattern = re.compile(
        r'(\s*)<insert id="insert"([^>]*)>(.*?)</insert>',
        re.DOTALL,
    )

    def repl(m):
        indent, attrs, body = m.group(1), m.group(2), m.group(3)
        if 'databaseId=' in attrs:
            return m.group(0)
        mysql_tag = f'{indent}<insert id="insert" databaseId="mysql"{attrs}>'
        mysql_block = mysql_tag + body + f'{indent}</insert>'
        ss_body = body.replace("LAST_INSERT_ID()", "SCOPE_IDENTITY()")
        ss_body = re.sub(r"`(\w+)`", r"[\1]", ss_body)
        ss_body = re.sub(r"\bNOW\(\)", "GETDATE()", ss_body)
        sqlserver_tag = f'{indent}<insert id="insert" databaseId="sqlserver"{attrs}>'
        sqlserver_block = sqlserver_tag + ss_body + f'{indent}</insert>'
        return mysql_block + "\n" + sqlserver_block

    return pattern.sub(repl, content)


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if '<insert id="insert"' not in text or 'databaseId="mysql"' in text:
        return False
    new_text = process_insert(text)
    if new_text != text:
        path.write_text(new_text, encoding="utf-8")
        return True
    return False


for xml in sorted(MAPPER_DIR.glob("*Mapper.xml")):
    if process_file(xml):
        print("Updated", xml.name)
