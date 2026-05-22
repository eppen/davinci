#!/usr/bin/env python3
"""Fix SQL Server branches: insert ignore, invalid merge into."""
import re
from pathlib import Path

MAPPER_DIR = Path(__file__).resolve().parents[2] / "server" / "src" / "main" / "resources" / "mybatis" / "mapper"

REPLACE_BATCH = {
    "rel_role_dashboard": ("role_id", "dashboard_id"),
    "rel_role_display": ("role_id", "display_id"),
    "rel_role_portal": ("role_id", "portal_id"),
    "rel_role_slide": ("role_id", "slide_id"),
    "rel_role_view": ("view_id", "role_id"),
    "rel_role_dashboard_widget": ("role_id", "mem_dashboard_widget_id"),
    "rel_role_display_slide_widget": ("role_id", "mem_display_slide_widget_id"),
}


def fix_sqlserver_section(section: str) -> str:
    s = section
    s = re.sub(r"\binsert\s+ignore\s+into\b", "insert into", s, flags=re.I)
    s = re.sub(r"\binsert\s+ignore\s+", "insert into ", s, flags=re.I)
    for table, (k1, k2) in REPLACE_BATCH.items():
        if f"merge into {table}" not in s.lower():
            continue
        # insertBatch style: merge into table (...) VALUES foreach
        m = re.search(
            rf'<insert databaseId="sqlserver" id="insertBatch"[^>]*>(.*?)</insert>',
            s,
            re.DOTALL | re.I,
        )
        if m and "foreach" in m.group(1):
            body = m.group(1)
            new_body = f"""
        <foreach collection="list" item="record" separator=";">
            DELETE FROM dbo.{table} WHERE [{k1}] = #{{record.{camel(k1)}}} AND [{k2}] = #{{record.{camel(k2)}}};
            INSERT INTO dbo.{table} ([{k1}], [{k2}], [visible], [create_by], [create_time])
            VALUES (#{{record.{camel(k1)},jdbcType=BIGINT}}, #{{record.{camel(k2)},jdbcType=BIGINT}},
                #{{record.visible,jdbcType=TINYINT}}, #{{record.createBy,jdbcType=BIGINT}},
                #{{record.createTime,jdbcType=TIMESTAMP}})
        </foreach>
"""
            # keep it simple - use generic visible columns from original if present
            s = s.replace(m.group(0), f'<insert databaseId="sqlserver" id="insertBatch" useGeneratedKeys="true" keyProperty="id">{new_body}\n    </insert>')
    s = re.sub(r"\bmerge\s+into\b", "insert into", s, flags=re.I)
    return s


def camel(snake: str) -> str:
    parts = snake.split("_")
    return parts[0] + "".join(p.title() for p in parts[1:])


def process_file(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    if 'databaseId="sqlserver"' not in text:
        return
    parts = re.split(r'(?=<(?:insert|update|select|delete)\s+databaseId="sqlserver")', text)
    out = [parts[0]]
    for part in parts[1:]:
        if part.startswith("<"):
            # find end of this statement
            m = re.match(r"(<(?:insert|update|select|delete)\s+databaseId=\"sqlserver\"[^>]*>)(.*?)(</(?:insert|update|select|delete)>)", part, re.DOTALL | re.I)
            if m:
                fixed = m.group(1) + fix_sqlserver_section(m.group(2)) + m.group(3)
                rest = part[m.end() :]
                out.append(fixed + rest)
            else:
                out.append(fix_sqlserver_section(part))
        else:
            out.append(part)
    new_text = "".join(out)
    # simpler global fix for sqlserver-only issues in whole file
    chunks = re.split(r'(databaseId="sqlserver")', new_text)
    rebuilt = chunks[0]
    i = 1
    while i < len(chunks):
        rebuilt += chunks[i]
        if i + 1 < len(chunks):
            chunk = chunks[i + 1]
            end = re.search(r'databaseId="mysql"|</mapper>', chunk)
            if end:
                ss_part = chunk[: end.start()]
                tail = chunk[end.start() :]
                ss_part = re.sub(r"\binsert\s+ignore\s+into\b", "insert into", ss_part, flags=re.I)
                ss_part = re.sub(r"\binsert\s+ignore\s+", "insert into ", ss_part, flags=re.I)
                ss_part = re.sub(r"\bmerge\s+into\b", "insert into", ss_part, flags=re.I)
                rebuilt += ss_part + tail
            else:
                rebuilt += chunk
            i += 2
        else:
            i += 1
    if rebuilt != text:
        path.write_text(rebuilt, encoding="utf-8")
        print("Fixed", path.name)


for xml in sorted(MAPPER_DIR.glob("*Mapper.xml")):
    process_file(xml)
