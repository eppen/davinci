#!/usr/bin/env python3
"""Seed Davinci Dashboard portal with MES widgets for full-page verification."""

from __future__ import annotations

import json
from datetime import datetime

import pymysql

DAVINCI_DB = "davinci0.3"
PROJECT_ID = 1
USER_ID = 1
PORTAL_NAME = "MES 验证 Portal"
DASHBOARD_NAME = "MES 整页验证"

DASHBOARD_CONFIG = {
    "filters": [],
    "linkages": [],
    "queryMode": 0,
}

# 12 列栅格：上下各一块整行图表
WIDGET_LAYOUT = [
    {
        "widget_name": "MES 班次产出柱状图",
        "alias": "班次产出",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 10,
    },
    {
        "widget_name": "MES 良率趋势折线图",
        "alias": "良率趋势",
        "x": 0,
        "y": 10,
        "width": 12,
        "height": 10,
    },
]


def now_str() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def ensure_portal(cur) -> int:
    cur.execute(
        "SELECT id FROM dashboard_portal WHERE project_id = %s AND name = %s",
        (PROJECT_ID, PORTAL_NAME),
    )
    row = cur.fetchone()
    ts = now_str()
    if row:
        portal_id = row[0]
        cur.execute(
            """
            UPDATE dashboard_portal
            SET description = %s, avatar = %s, publish = 1, update_by = %s, update_time = %s
            WHERE id = %s
            """,
            ("MES Phase1 整页验证 Portal", "1", USER_ID, ts, portal_id),
        )
        print(f"Updated portal id={portal_id} name={PORTAL_NAME}")
        return portal_id

    cur.execute(
        """
        INSERT INTO dashboard_portal
          (name, description, project_id, avatar, publish, create_by, create_time, update_by, update_time)
        VALUES (%s, %s, %s, %s, 1, %s, %s, %s, %s)
        """,
        (
            PORTAL_NAME,
            "MES Phase1 整页验证 Portal",
            PROJECT_ID,
            "1",
            USER_ID,
            ts,
            USER_ID,
            ts,
        ),
    )
    portal_id = cur.lastrowid
    print(f"Created portal id={portal_id} name={PORTAL_NAME}")
    return portal_id


def ensure_dashboard(cur, portal_id: int) -> int:
    cur.execute(
        "SELECT id FROM dashboard WHERE dashboard_portal_id = %s AND name = %s",
        (portal_id, DASHBOARD_NAME),
    )
    row = cur.fetchone()
    config_json = json.dumps(DASHBOARD_CONFIG, ensure_ascii=False)
    ts = now_str()
    if row:
        dashboard_id = row[0]
        cur.execute(
            """
            UPDATE dashboard
            SET config = %s, update_by = %s, update_time = %s
            WHERE id = %s
            """,
            (config_json, USER_ID, ts, dashboard_id),
        )
        print(f"Updated dashboard id={dashboard_id} name={DASHBOARD_NAME}")
        return dashboard_id

    cur.execute(
        """
        INSERT INTO dashboard
          (name, dashboard_portal_id, type, `index`, parent_id, config, create_by, create_time, update_by, update_time)
        VALUES (%s, %s, 1, 1, 0, %s, %s, %s, %s, %s)
        """,
        (DASHBOARD_NAME, portal_id, config_json, USER_ID, ts, USER_ID, ts),
    )
    dashboard_id = cur.lastrowid
    print(f"Created dashboard id={dashboard_id} name={DASHBOARD_NAME}")
    return dashboard_id


def load_widget_id(cur, widget_name: str) -> int:
    cur.execute(
        "SELECT id FROM widget WHERE project_id = %s AND name = %s",
        (PROJECT_ID, widget_name),
    )
    row = cur.fetchone()
    if not row:
        raise RuntimeError(f"Widget not found: {widget_name}")
    return row[0]


def upsert_dashboard_widget(cur, dashboard_id: int, layout: dict) -> int:
    widget_id = load_widget_id(cur, layout["widget_name"])
    cur.execute(
        """
        SELECT id FROM mem_dashboard_widget
        WHERE dashboard_id = %s AND widget_Id = %s
        """,
        (dashboard_id, widget_id),
    )
    row = cur.fetchone()
    ts = now_str()
    if row:
        rel_id = row[0]
        cur.execute(
            """
            UPDATE mem_dashboard_widget
            SET alias = %s, x = %s, y = %s, width = %s, height = %s,
                polling = 0, frequency = 60, update_by = %s, update_time = %s
            WHERE id = %s
            """,
            (
                layout["alias"],
                layout["x"],
                layout["y"],
                layout["width"],
                layout["height"],
                USER_ID,
                ts,
                rel_id,
            ),
        )
        print(
            f"Updated dashboard widget rel id={rel_id} widget={layout['widget_name']}"
        )
        return rel_id

    cur.execute(
        """
        INSERT INTO mem_dashboard_widget
          (alias, dashboard_id, widget_Id, x, y, width, height, polling, frequency,
           create_by, create_time, update_by, update_time)
        VALUES (%s, %s, %s, %s, %s, %s, %s, 0, 60, %s, %s, %s, %s)
        """,
        (
            layout["alias"],
            dashboard_id,
            widget_id,
            layout["x"],
            layout["y"],
            layout["width"],
            layout["height"],
            USER_ID,
            ts,
            USER_ID,
            ts,
        ),
    )
    rel_id = cur.lastrowid
    print(f"Created dashboard widget rel id={rel_id} widget={layout['widget_name']}")
    return rel_id


def cleanup_legacy_test_dashboard(cur, keep_dashboard_id: int, keep_portal_id: int) -> None:
    """Remove old test dashboard entries if they differ from the MES verification dashboard."""
    cur.execute(
        """
        SELECT id, dashboard_portal_id FROM dashboard
        WHERE name = 'test' AND id <> %s
        """,
        (keep_dashboard_id,),
    )
    for dashboard_id, portal_id in cur.fetchall():
        cur.execute("DELETE FROM mem_dashboard_widget WHERE dashboard_id = %s", (dashboard_id,))
        cur.execute("DELETE FROM dashboard WHERE id = %s", (dashboard_id,))
        print(f"Removed legacy dashboard id={dashboard_id}")

    cur.execute(
        """
        SELECT id FROM dashboard_portal
        WHERE project_id = %s AND name = 'test' AND id <> %s
        """,
        (PROJECT_ID, keep_portal_id),
    )
    for (portal_id,) in cur.fetchall():
        cur.execute(
            "DELETE FROM mem_dashboard_widget WHERE dashboard_id IN (SELECT id FROM dashboard WHERE dashboard_portal_id = %s)",
            (portal_id,),
        )
        cur.execute("DELETE FROM dashboard WHERE dashboard_portal_id = %s", (portal_id,))
        cur.execute("DELETE FROM dashboard_portal WHERE id = %s", (portal_id,))
        print(f"Removed legacy portal id={portal_id}")


def main() -> None:
    conn = pymysql.connect(
        host="localhost",
        port=3306,
        user="root",
        password="",
        database=DAVINCI_DB,
        charset="utf8mb4",
        autocommit=True,
    )
    try:
        cur = conn.cursor()
        portal_id = ensure_portal(cur)
        dashboard_id = ensure_dashboard(cur, portal_id)
        rel_ids = [
            upsert_dashboard_widget(cur, dashboard_id, layout)
            for layout in WIDGET_LAYOUT
        ]
        cleanup_legacy_test_dashboard(cur, dashboard_id, portal_id)

        cur.execute(
            """
            SELECT d.id, d.name, dp.id, dp.name, dp.publish
            FROM dashboard d
            JOIN dashboard_portal dp ON dp.id = d.dashboard_portal_id
            WHERE d.id = %s
            """,
            (dashboard_id,),
        )
        print("Dashboard ready:", cur.fetchone())
        cur.execute(
            """
            SELECT id, alias, widget_Id, x, y, width, height
            FROM mem_dashboard_widget WHERE dashboard_id = %s ORDER BY y, x
            """,
            (dashboard_id,),
        )
        print("Layout:", cur.fetchall())
        print(
            f"Open: /project/{PROJECT_ID}/portal/{portal_id}/dashboard/{dashboard_id}"
        )
        print("Relation IDs:", rel_ids)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
