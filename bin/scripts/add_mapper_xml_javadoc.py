#!/usr/bin/env python3
"""Add class Javadoc linking *Mapper.java to *Mapper.xml."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DAO = ROOT / "server" / "src" / "main" / "java" / "edp" / "davinci" / "dao"
XML_DIR = ROOT / "server" / "src" / "main" / "resources" / "mybatis" / "mapper"
XML_PATH = "server/src/main/resources/mybatis/mapper/{name}.xml"
MARKER = "MyBatis mapper. XML:"


def xml_statement_ids(xml_file: Path) -> list:
    text = xml_file.read_text(encoding="utf-8")
    ids = re.findall(r'<(?:select|insert|update|delete)\s+[^>]*\bid="([^"]+)"', text, re.I)
    seen = set()
    ordered = []
    for i in ids:
        if i not in seen:
            seen.add(i)
            ordered.append(i)
    return ordered


def build_javadoc(mapper_name: str, stmt_ids: list) -> str:
    xml_rel = XML_PATH.format(name=mapper_name)
    ids_part = ", ".join(stmt_ids) if stmt_ids else "(see XML)"
    return (
        "/**\n"
        f" * {MARKER} {xml_rel}\n"
        f" * XML statements: {ids_part}.\n"
        " */"
    )


def add_javadoc(java_file: Path, javadoc: str) -> bool:
    text = java_file.read_text(encoding="utf-8")
    if MARKER in text:
        return False
    # insert before @Component + public interface
    m = re.search(r"\n(@Component\s*\npublic interface )", text)
    if not m:
        m = re.search(r"\n(public interface )", text)
        if not m:
            return False
        insert_at = m.start() + 1
        new_text = text[:insert_at] + javadoc + "\n\n" + text[insert_at:]
    else:
        insert_at = m.start() + 1
        new_text = text[:insert_at] + javadoc + "\n" + text[insert_at:]
    java_file.write_text(new_text, encoding="utf-8")
    return True


def main():
    for java_file in sorted(DAO.glob("*Mapper.java")):
        name = java_file.stem
        xml_file = XML_DIR / f"{name}.xml"
        if not xml_file.exists():
            continue
        ids = xml_statement_ids(xml_file)
        doc = build_javadoc(name, ids)
        if add_javadoc(java_file, doc):
            print("Updated", java_file.name)


if __name__ == "__main__":
    main()
