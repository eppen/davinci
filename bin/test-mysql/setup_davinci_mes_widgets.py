#!/usr/bin/env python3
"""Seed Davinci Widgets for MES test views."""

from __future__ import annotations

import json
from datetime import datetime
from typing import Any

import pymysql

DAVINCI_DB = "davinci0.3"
PROJECT_ID = 1
USER_ID = 1

FONT = "PingFang SC"
AXIS_COLOR = "#D9D9D9"
FONT_COLOR = "#666"

CHART_BAR = {
    "id": 3,
    "name": "bar",
    "title": "柱状图",
    "icon": "icon-chart-bar",
    "coordinate": "cartesian",
    "rules": [{"dimension": [0, 1], "metric": [1, 9999]}],
    "dimetionAxis": "col",
    "data": {
        "cols": {"title": "列", "type": "category"},
        "rows": {"title": "行", "type": "category"},
        "metrics": {"title": "指标", "type": "value"},
        "filters": {"title": "筛选", "type": "all"},
        "color": {"title": "颜色", "type": "category"},
        "tip": {"title": "提示信息", "type": "value"},
    },
    "style": {
        "spec": {},
        "bar": {
            "barChart": False,
            "border": {"color": "#000", "width": 0, "type": "solid", "radius": 0},
            "gap": 30,
            "width": None,
            "stack": {"on": False, "percentage": False, "group": [], "sum": {"show": False, "font": {}}},
        },
        "label": {
            "showLabel": False,
            "labelPosition": "top",
            "labelFontFamily": FONT,
            "labelFontSize": "12",
            "labelColor": FONT_COLOR,
        },
        "xAxis": {
            "showLine": True,
            "lineStyle": "solid",
            "lineSize": "1",
            "lineColor": AXIS_COLOR,
            "showLabel": True,
            "labelFontFamily": FONT,
            "labelFontSize": "12",
            "labelColor": FONT_COLOR,
            "xAxisInterval": 0,
            "xAxisRotate": 0,
        },
        "yAxis": {
            "showLine": True,
            "lineStyle": "solid",
            "lineSize": "1",
            "lineColor": AXIS_COLOR,
            "showLabel": True,
            "labelFontFamily": FONT,
            "labelFontSize": "12",
            "labelColor": FONT_COLOR,
            "showTitleAndUnit": True,
            "titleFontFamily": FONT,
            "titleFontSize": "12",
            "titleColor": FONT_COLOR,
            "nameLocation": "middle",
            "nameRotate": 90,
            "nameGap": 40,
            "min": None,
            "max": None,
        },
        "splitLine": {
            "showHorizontalLine": True,
            "horizontalLineStyle": "dashed",
            "horizontalLineSize": "1",
            "horizontalLineColor": AXIS_COLOR,
            "showVerticalLine": False,
            "verticalLineStyle": "dashed",
            "verticalLineSize": "1",
            "verticalLineColor": AXIS_COLOR,
        },
        "legend": {
            "showLegend": True,
            "legendPosition": "right",
            "selectAll": True,
            "fontFamily": FONT,
            "fontSize": "12",
            "color": FONT_COLOR,
        },
    },
}

CHART_LINE = {
    "id": 2,
    "name": "line",
    "title": "折线图",
    "icon": "icon-chart-line",
    "coordinate": "cartesian",
    "rules": [{"dimension": 1, "metric": [1, 9999]}],
    "dimetionAxis": "col",
    "data": {
        "cols": {"title": "列", "type": "category"},
        "rows": {"title": "行", "type": "category"},
        "metrics": {"title": "指标", "type": "value"},
        "filters": {"title": "筛选", "type": "all"},
        "color": {"title": "颜色", "type": "category"},
        "tip": {"title": "提示信息", "type": "value"},
    },
    "style": {
        "spec": {"smooth": False, "step": False},
        "label": {
            "showLabel": False,
            "labelPosition": "top",
            "labelFontFamily": FONT,
            "labelFontSize": "12",
            "labelColor": FONT_COLOR,
        },
        "xAxis": {
            "showLine": True,
            "lineStyle": "solid",
            "lineSize": "1",
            "lineColor": AXIS_COLOR,
            "showLabel": True,
            "labelFontFamily": FONT,
            "labelFontSize": "12",
            "labelColor": FONT_COLOR,
            "showInterval": False,
            "xAxisInterval": 0,
            "xAxisRotate": 0,
        },
        "yAxis": {
            "showLine": True,
            "lineStyle": "solid",
            "lineSize": "1",
            "lineColor": AXIS_COLOR,
            "showLabel": True,
            "labelFontFamily": FONT,
            "labelFontSize": "12",
            "labelColor": FONT_COLOR,
            "showTitleAndUnit": True,
            "titleFontFamily": FONT,
            "titleFontSize": "12",
            "titleColor": FONT_COLOR,
            "nameLocation": "middle",
            "nameRotate": 90,
            "nameGap": 40,
            "min": None,
            "max": None,
        },
        "splitLine": {
            "showHorizontalLine": True,
            "horizontalLineStyle": "dashed",
            "horizontalLineSize": "1",
            "horizontalLineColor": AXIS_COLOR,
            "showVerticalLine": False,
            "verticalLineStyle": "dashed",
            "verticalLineSize": "1",
            "verticalLineColor": AXIS_COLOR,
        },
        "legend": {
            "showLegend": True,
            "legendPosition": "right",
            "selectAll": True,
            "fontFamily": FONT,
            "fontSize": "12",
            "color": FONT_COLOR,
        },
    },
}


def field_config(alias: str = "") -> dict:
    return {"alias": alias, "desc": "", "useExpression": False}


def format_config() -> dict:
    return {"formatType": "default"}


def dimension(name: str) -> dict:
    return {
        "name": name,
        "field": field_config(),
        "format": format_config(),
    }


def metric(name: str, chart: dict, agg: str = "sum") -> dict:
    return {
        "name": name,
        "agg": agg,
        "chart": chart,
        "field": field_config(),
        "format": format_config(),
    }


def empty_data_param(title: str, param_type: str) -> dict:
    # value 必填：图表渲染会访问 color.value[metricName]
    return {"title": title, "type": param_type, "items": [], "value": {}}


def base_widget_config(model: dict, chart_styles: dict, selected_chart: int, cols: list, metrics: list) -> dict:
    return {
        "controls": [],
        "limit": None,
        "cache": False,
        "expired": 300,
        "autoLoadData": True,
        "queryMode": 0,
        "data": [],
        "cols": cols,
        "rows": [],
        "metrics": metrics,
        "filters": [],
        "color": empty_data_param("颜色", "category"),
        "label": empty_data_param("标签", "category"),
        "tip": empty_data_param("提示信息", "value"),
        "chartStyles": chart_styles,
        "selectedChart": selected_chart,
        "orders": [],
        "mode": "chart",
        "model": model,
        "dimetionAxis": "col",
        "pagination": {
            "pageNo": 0,
            "pageSize": 0,
            "totalCount": 0,
            "withPaging": False,
        },
        "references": [],
        "computed": [],
    }


WIDGET_SPECS = [
    {
        "name": "MES 班次产出柱状图",
        "description": "绑定 MES v_output_shift，对比实际/计划产量",
        "view_name": "MES v_output_shift",
        "chart_type": 3,
        "build_config": lambda model: base_widget_config(
            model,
            CHART_BAR["style"],
            3,
            [dimension("shift")],
            [metric("output_qty", CHART_BAR), metric("plan_qty", CHART_BAR)],
        ),
    },
    {
        "name": "MES 良率趋势折线图",
        "description": "绑定 MES v_yield_trend，展示近 7 天良率",
        "view_name": "MES v_yield_trend",
        "chart_type": 2,
        "build_config": lambda model: base_widget_config(
            model,
            CHART_LINE["style"],
            2,
            [dimension("date")],
            [metric("yield_rate", CHART_LINE)],
        ),
    },
]


def load_view_model(cur, view_name: str) -> tuple[int, dict]:
    cur.execute(
        "SELECT id, model FROM `view` WHERE project_id = %s AND name = %s",
        (PROJECT_ID, view_name),
    )
    row = cur.fetchone()
    if not row:
        raise RuntimeError(f"View not found: {view_name}")
    view_id, model_raw = row
    model = json.loads(model_raw) if model_raw else {}
    return view_id, model


def upsert_widget(cur, spec: dict[str, Any], view_id: int, config: dict) -> int:
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    config_json = json.dumps(config, ensure_ascii=False)
    cur.execute(
        "SELECT id FROM widget WHERE project_id = %s AND name = %s",
        (PROJECT_ID, spec["name"]),
    )
    row = cur.fetchone()
    if row:
        widget_id = row[0]
        cur.execute(
            """
            UPDATE widget
            SET view_id = %s, type = %s, publish = 1, config = %s,
                description = %s, update_by = %s, update_time = %s
            WHERE id = %s
            """,
            (
                view_id,
                spec["chart_type"],
                config_json,
                spec["description"],
                USER_ID,
                now,
                widget_id,
            ),
        )
        print(f"Updated widget id={widget_id} name={spec['name']}")
        return widget_id

    cur.execute(
        """
        INSERT INTO widget
          (name, description, view_id, project_id, type, publish, config,
           create_by, create_time, update_by, update_time, is_folder, `index`)
        VALUES (%s, %s, %s, %s, %s, 1, %s, %s, %s, %s, %s, 0, %s)
        """,
        (
            spec["name"],
            spec["description"],
            view_id,
            PROJECT_ID,
            spec["chart_type"],
            config_json,
            USER_ID,
            now,
            USER_ID,
            now,
            spec.get("index", 1),
        ),
    )
    widget_id = cur.lastrowid
    print(f"Created widget id={widget_id} name={spec['name']}")
    return widget_id


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
        widget_ids = []
        for idx, spec in enumerate(WIDGET_SPECS, start=1):
            spec["index"] = idx
            view_id, model = load_view_model(cur, spec["view_name"])
            config = spec["build_config"](model)
            widget_ids.append(upsert_widget(cur, spec, view_id, config))

        cur.execute(
            "SELECT id, name, view_id, type FROM widget WHERE project_id = %s ORDER BY id",
            (PROJECT_ID,),
        )
        print("Project widgets:", cur.fetchall())
        print("Widget IDs for MES:", widget_ids)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
