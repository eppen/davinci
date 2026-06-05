#!/usr/bin/env python3
"""Seed Davinci JDBC Source + Views for MES test schema in MySQL test db."""

from __future__ import annotations

import json
from datetime import datetime

import pymysql

DAVINCI_DB = "davinci0.3"
PROJECT_ID = 1
USER_ID = 1
SOURCE_NAME = "MES-Test-MySQL"
VIEW_OUTPUT_SHIFT = "MES v_output_shift"
VIEW_YIELD_TREND = "MES v_yield_trend"


def query_var(name: str, default: str, value_type: str = "string") -> dict:
    return {
        "name": name,
        "type": "query",
        "valueType": value_type,
        "udf": False,
        "defaultValues": [default],
        "channel": None,
    }


def model_for_output_shift() -> dict:
    return {
        "line_code": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "shift": {"sqlType": "CHAR", "visualType": "string", "modelType": "category"},
        "output_qty": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
        "plan_qty": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
        "achievement_rate": {"sqlType": "DECIMAL", "visualType": "number", "modelType": "value"},
    }


def model_for_yield_trend() -> dict:
    return {
        "date": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "yield_rate": {"sqlType": "DECIMAL", "visualType": "number", "modelType": "value"},
    }


# Davinci 字符串变量会自动加引号，占位符写 $name$，不要写成 '$name$'
SQL_OUTPUT_SHIFT = """SELECT
  line_code,
  shift,
  output_qty,
  plan_qty,
  achievement_rate
FROM v_output_shift
WHERE plant = $plant$
  AND line_code = $line$
  AND shift = $shift$"""

SQL_YIELD_TREND = """SELECT
  date,
  yield_rate
FROM v_yield_trend
WHERE plant = $plant$
  AND line_code = $line$
ORDER BY date"""

VARS_OUTPUT_SHIFT = [
    query_var("plant", "P01"),
    query_var("line", "L03"),
    query_var("shift", "A"),
]

VARS_YIELD_TREND = [
    query_var("plant", "P01"),
    query_var("line", "L03"),
]


def ensure_source(cur) -> int:
    cur.execute(
        "SELECT id, config FROM `source` WHERE project_id = %s AND name = %s",
        (PROJECT_ID, SOURCE_NAME),
    )
    row = cur.fetchone()
    config = {
        "ext": False,
        "password": "",
        "version": "",
        "properties": [],
        "url": "jdbc:mysql://localhost:3306/test?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai",
        "username": "root",
        "name": "mysql",
    }
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    config_json = json.dumps(config, ensure_ascii=False)

    if row:
        source_id = row[0]
        cur.execute(
            "UPDATE `source` SET config = %s, type = 'jdbc', description = %s, update_by = %s, update_time = %s WHERE id = %s",
            (
                config_json,
                "MES Phase1 测试只读库（test 库 v_output_shift / v_yield_trend）",
                USER_ID,
                now,
                source_id,
            ),
        )
        print(f"Updated source id={source_id} name={SOURCE_NAME}")
        return source_id

    cur.execute(
        """
        INSERT INTO `source`
          (name, description, config, type, project_id, create_by, create_time, update_by, update_time, is_folder, `index`)
        VALUES (%s, %s, %s, 'jdbc', %s, %s, %s, %s, %s, 0, 1)
        """,
        (
            SOURCE_NAME,
            "MES Phase1 测试只读库（test 库 v_output_shift / v_yield_trend）",
            config_json,
            PROJECT_ID,
            USER_ID,
            now,
            USER_ID,
            now,
        ),
    )
    source_id = cur.lastrowid
    print(f"Created source id={source_id} name={SOURCE_NAME}")
    return source_id


def upsert_view(cur, source_id: int, name: str, sql: str, variables: list, model: dict, index: int) -> int:
    cur.execute(
        "SELECT id FROM `view` WHERE project_id = %s AND name = %s",
        (PROJECT_ID, name),
    )
    row = cur.fetchone()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    variable_json = json.dumps(variables, ensure_ascii=False)
    model_json = json.dumps(model, ensure_ascii=False)

    if row:
        view_id = row[0]
        cur.execute(
            """
            UPDATE `view`
            SET source_id = %s, `sql` = %s, variable = %s, model = %s,
                description = %s, update_by = %s, update_time = %s, `index` = %s
            WHERE id = %s
            """,
            (
                source_id,
                sql,
                variable_json,
                model_json,
                "MES 通道 B 测试视图",
                USER_ID,
                now,
                index,
                view_id,
            ),
        )
        print(f"Updated view id={view_id} name={name}")
        return view_id

    cur.execute(
        """
        INSERT INTO `view`
          (name, description, project_id, source_id, `sql`, model, variable, create_by, create_time, update_by, update_time, is_folder, `index`)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 0, %s)
        """,
        (
            name,
            "MES 通道 B 测试视图",
            PROJECT_ID,
            source_id,
            sql,
            model_json,
            variable_json,
            USER_ID,
            now,
            USER_ID,
            now,
            index,
        ),
    )
    view_id = cur.lastrowid
    print(f"Created view id={view_id} name={name}")
    return view_id


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
        source_id = ensure_source(cur)
        upsert_view(
            cur,
            source_id,
            VIEW_OUTPUT_SHIFT,
            SQL_OUTPUT_SHIFT,
            VARS_OUTPUT_SHIFT,
            model_for_output_shift(),
            1,
        )
        upsert_view(
            cur,
            source_id,
            VIEW_YIELD_TREND,
            SQL_YIELD_TREND,
            VARS_YIELD_TREND,
            model_for_yield_trend(),
            2,
        )

        cur.execute(
            "SELECT id, name, source_id FROM `view` WHERE project_id = %s ORDER BY id",
            (PROJECT_ID,),
        )
        print("Project views:", cur.fetchall())
    finally:
        conn.close()


if __name__ == "__main__":
    main()
