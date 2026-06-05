#!/usr/bin/env python3
"""Apply mes_test_schema.sql to MySQL test database."""

import sys
from pathlib import Path

import pymysql

SQL_FILE = Path(__file__).with_name("mes_test_schema.sql")


def main() -> int:
    sql = SQL_FILE.read_text(encoding="utf-8")
    lines = []
    for line in sql.splitlines():
        s = line.strip()
        if s.startswith("/*") or s.startswith("*") or s.startswith("--"):
            continue
        lines.append(line)
    stmts = [s.strip() for s in "\n".join(lines).split(";") if s.strip()]

    conn = pymysql.connect(
        host="localhost",
        port=3306,
        user="root",
        password="",
        charset="utf8mb4",
        autocommit=True,
    )
    try:
        cur = conn.cursor()
        for stmt in stmts:
            cur.execute(stmt)
        print(f"Executed {len(stmts)} statements from {SQL_FILE.name}")

        cur.execute("SHOW FULL TABLES IN test WHERE Table_type = 'VIEW'")
        print("Views:", cur.fetchall())

        cur.execute("SELECT COUNT(*) FROM test.mes_shift_output")
        print("mes_shift_output rows:", cur.fetchone()[0])

        cur.execute("SELECT COUNT(*) FROM test.mes_daily_yield")
        print("mes_daily_yield rows:", cur.fetchone()[0])

        cur.execute(
            "SELECT line_code, shift, output_qty, plan_qty "
            "FROM test.v_output_shift "
            "WHERE plant='P01' AND line_code='L03' AND shift='A'"
        )
        print("v_output_shift sample:", cur.fetchall())

        cur.execute(
            "SELECT date, yield_rate FROM test.v_yield_trend "
            "WHERE plant='P01' AND line_code='L03' ORDER BY date"
        )
        print("v_yield_trend sample:", cur.fetchall())
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
