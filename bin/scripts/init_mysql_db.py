#!/usr/bin/env python3
"""Initialize davinci0.3 MySQL database from bin/davinci.sql."""
import os
import sys

try:
    import pymysql
except ImportError:
    print("pymysql not installed; run: pip install pymysql")
    sys.exit(1)

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SQL_FILE = os.path.join(ROOT, "bin", "davinci.sql")
HOST = os.environ.get("MYSQL_HOST", "127.0.0.1")
PORT = int(os.environ.get("MYSQL_PORT", "3306"))
USER = os.environ.get("MYSQL_USER", "root")
PASSWORD = os.environ.get("MYSQL_PASS", "")
DB = os.environ.get("MYSQL_DB", "davinci0.3")


def main():
    conn = pymysql.connect(host=HOST, port=PORT, user=USER, password=PASSWORD, charset="utf8mb4")
    try:
        with conn.cursor() as cur:
            cur.execute(f"CREATE DATABASE IF NOT EXISTS `{DB}` DEFAULT CHARACTER SET utf8mb4")
            cur.execute(f"USE `{DB}`")
            cur.execute("SHOW TABLES")
            tables = cur.fetchall()
            if tables:
                print(f"Database {DB} already has {len(tables)} tables, skip import.")
                return
        conn.commit()
        conn.select_db(DB)
        with open(SQL_FILE, "r", encoding="utf-8", errors="replace") as f:
            sql = f.read()
        # allowMultiQueries-style: split on semicolon at line end (simple heuristic)
        statements = []
        buf = []
        for line in sql.splitlines():
            stripped = line.strip()
            if stripped.startswith("--") or not stripped:
                continue
            buf.append(line)
            if stripped.endswith(";"):
                statements.append("\n".join(buf))
                buf = []
        if buf:
            statements.append("\n".join(buf))
        with conn.cursor() as cur:
            for i, stmt in enumerate(statements):
                stmt = stmt.strip()
                if not stmt:
                    continue
                try:
                    cur.execute(stmt)
                except Exception as e:
                    print(f"Statement {i + 1} failed: {e}")
                    print(stmt[:200], "...")
                    raise
        conn.commit()
        with conn.cursor() as cur:
            cur.execute("SHOW TABLES")
            print(f"Imported {DB}: {len(cur.fetchall())} tables")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
