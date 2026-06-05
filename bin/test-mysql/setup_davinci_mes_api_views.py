#!/usr/bin/env python3
"""Seed Davinci MES_API Source + API Views (Channel A) for MES chart validation."""

from __future__ import annotations

import json
from datetime import datetime

import pymysql

DAVINCI_DB = "davinci0.3"
PROJECT_ID = 1
USER_ID = 1
SOURCE_NAME = "MES-Dataset-Mock"
BASE_URL = "http://127.0.0.1:8080"

DATASETS = [
    ("MES output_shift", "output_shift", {
        "line_code": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "shift": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "output_qty": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
        "plan_qty": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
    }, ["plant", "line", "shift"]),
    ("MES yield_trend", "yield_trend", {
        "date": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "yield_rate": {"sqlType": "DECIMAL", "visualType": "number", "modelType": "value"},
    }, ["plant", "line"]),
    ("MES oee_shift", "oee_shift", {
        "line_code": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "oee": {"sqlType": "DECIMAL", "visualType": "number", "modelType": "value"},
    }, ["plant", "line", "shift"]),
    ("MES defect_pareto", "defect_pareto", {
        "defect_name": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "defect_qty": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
        "cumulative_pct": {"sqlType": "DECIMAL", "visualType": "number", "modelType": "value"},
    }, ["plant", "line"]),
    ("MES equip_status", "equip_status", {
        "equip_code": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "status_code": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
    }, ["plant", "line"]),
    ("MES wip_orders", "wip_orders", {
        "wo_no": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "product": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
        "qty": {"sqlType": "INT", "visualType": "number", "modelType": "value"},
        "status": {"sqlType": "VARCHAR", "visualType": "string", "modelType": "category"},
    }, ["plant", "line"]),
]


def query_var(name: str, default: str) -> dict:
    return {
        "name": name,
        "type": "query",
        "valueType": "string",
        "udf": False,
        "defaultValues": [default],
        "channel": None,
    }


def ensure_source(cur) -> int:
    cur.execute(
        "SELECT id FROM `source` WHERE project_id = %s AND name = %s",
        (PROJECT_ID, SOURCE_NAME),
    )
    row = cur.fetchone()
    config = {
        "baseUrl": BASE_URL,
        "datasetCode": "output_shift",
        "authType": "bearer",
        "bearerToken": "",
        "timeoutMs": 30000,
    }
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    config_json = json.dumps(config, ensure_ascii=False)
    if row:
        source_id = row[0]
        cur.execute(
            "UPDATE `source` SET config = %s, type = 'mes_api', description = %s, update_by = %s, update_time = %s WHERE id = %s",
            (config_json, "MES Dataset API Mock (Channel A)", USER_ID, now, source_id),
        )
        return source_id
    cur.execute(
        """INSERT INTO `source` (name, description, type, project_id, config, create_by, create_time, update_by, update_time)
           VALUES (%s, %s, 'mes_api', %s, %s, %s, %s, %s, %s)""",
        (SOURCE_NAME, "MES Dataset API Mock", PROJECT_ID, config_json, USER_ID, now, USER_ID, now),
    )
    return cur.lastrowid


def ensure_view(cur, source_id: int, name: str, dataset_code: str, model: dict, var_names: list) -> int:
    cur.execute(
        "SELECT id FROM `view` WHERE project_id = %s AND name = %s",
        (PROJECT_ID, name),
    )
    row = cur.fetchone()
    variables = [query_var(v, "P01" if v == "plant" else "L03" if v == "line" else "A") for v in var_names]
    sql = json.dumps({"datasetCode": dataset_code}, ensure_ascii=False)
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    model_json = json.dumps(model, ensure_ascii=False)
    var_json = json.dumps(variables, ensure_ascii=False)
    if row:
        view_id = row[0]
        cur.execute(
            """UPDATE `view` SET source_id = %s, sql = %s, model = %s, variable = %s,
               update_by = %s, update_time = %s WHERE id = %s""",
            (source_id, sql, model_json, var_json, USER_ID, now, view_id),
        )
        return view_id
    cur.execute(
        """INSERT INTO `view` (name, description, project_id, source_id, sql, model, variable,
           config, create_by, create_time, update_by, update_time)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
        (
            name,
            f"MES API View: {dataset_code}",
            PROJECT_ID,
            source_id,
            sql,
            model_json,
            var_json,
            "{}",
            USER_ID,
            now,
            USER_ID,
            now,
        ),
    )
    return cur.lastrowid


def main() -> None:
    conn = pymysql.connect(host="localhost", user="root", password="root", database=DAVINCI_DB, charset="utf8mb4")
    try:
        with conn.cursor() as cur:
            source_id = ensure_source(cur)
            print(f"Source id={source_id} ({SOURCE_NAME})")
            for name, code, model, vars_ in DATASETS:
                vid = ensure_view(cur, source_id, name, code, model, vars_)
                print(f"  View id={vid} name={name} dataset={code}")
        conn.commit()
        print("MES API Channel A seed done.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
