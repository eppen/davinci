#!/usr/bin/env python3
"""Phase 2 end-to-end smoke test (API + seed + chart registry)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

BASE = "http://127.0.0.1:8080"
API = f"{BASE}/api/v3"
MES_MOCK = f"{BASE}/api/mes/dataset"
WEB = "http://127.0.0.1:5002"

MES_CHART_CODES = {
    "mes-output-card",
    "mes-oee-gauge",
    "mes-yield-trend",
    "mes-pareto-bar",
    "mes-equip-status",
    "mes-wip-table",
}

MOCK_DATASETS = [
    "output_shift",
    "yield_trend",
    "oee_shift",
    "defect_pareto",
    "equip_status",
    "wip_orders",
]


def http_json(method: str, url: str, body: dict | None = None, token: str | None = None) -> dict:
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}" if not token.startswith("Bearer ") else token
    data = json.dumps(body).encode("utf-8") if body is not None else None
    req = Request(url, data=data, headers=headers, method=method)
    with urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def http_status(url: str) -> int:
    req = Request(url, method="GET")
    with urlopen(req, timeout=15) as resp:
        return resp.status


def login() -> str:
    res = http_json("POST", f"{API}/login", {"username": "guest", "password": "123456"})
    token = res.get("header", {}).get("token") or res.get("payload", {}).get("token")
    if not token:
        raise RuntimeError(f"login failed: {res}")
    return token


def check(name: str, ok: bool, detail: str = "") -> bool:
    mark = "PASS" if ok else "FAIL"
    line = f"[{mark}] {name}"
    if detail:
        line += f" — {detail}"
    print(line)
    return ok


def run_seed(script: str) -> bool:
    path = Path(__file__).with_name(script)
    print(f"\n--- seed: {script} ---")
    try:
        subprocess.run([sys.executable, str(path)], check=True, timeout=120)
        return True
    except Exception as e:
        print(f"seed error: {e}")
        return False


def main() -> int:
    passed = 0
    total = 0
    results: list[bool] = []

    def record(name: str, ok: bool, detail: str = "") -> None:
        nonlocal passed, total
        total += 1
        if check(name, ok, detail):
            passed += 1
        results.append(ok)

    print("=== Phase 2 E2E Smoke ===\n")

    # 0. Reachability
    try:
        record("Webapp reachable", http_status(WEB) == 200, WEB)
    except (HTTPError, URLError, TimeoutError) as e:
        record("Webapp reachable", False, str(e))

    try:
        record("API configurations", http_status(f"{API}/configurations") == 200)
    except (HTTPError, URLError, TimeoutError) as e:
        record("API configurations", False, str(e))

    try:
        st = http_status(f"{BASE}/static/mes-chart-runtime.js")
        record("SDK UMD static", st == 200, f"HTTP {st}")
    except (HTTPError, URLError, TimeoutError) as e:
        record("SDK UMD static", False, str(e))

    # 1. Seed Channel A
    if run_seed("setup_davinci_mes_api_views.py"):
        record("Seed MES_API views", True)
    else:
        record("Seed MES_API views", False)

    # 2. Login
    try:
        token = login()
        record("Login guest", True)
    except Exception as e:
        record("Login guest", False, str(e))
        print(f"\n=== {passed}/{total} passed ===")
        return 1

    # 3. Chart types — 6 mes-*
    try:
        res = http_json("GET", f"{API}/chart-types?enabled=true", token=token)
        payloads = res.get("payload") or res.get("payloads") or []
        codes = {p.get("code") for p in payloads if p.get("category") == "mes"}
        missing = MES_CHART_CODES - codes
        record("MES chart types (6)", len(missing) == 0, f"missing={missing or 'none'}")
    except Exception as e:
        record("MES chart types (6)", False, str(e))

    # 4. MES Dataset Mock — 6 datasets
    mock_ok = 0
    for code in MOCK_DATASETS:
        try:
            res = http_json(
                "POST",
                f"{MES_MOCK}/{code}/query",
                {"params": {"plant": "P01", "line": "L03", "shift": "A"}, "pageNo": 1, "pageSize": 10},
            )
            rows = res.get("data") or res.get("rows") or []
            if rows:
                mock_ok += 1
        except Exception:
            pass
    record("MES Dataset Mock (6)", mock_ok == len(MOCK_DATASETS), f"{mock_ok}/{len(MOCK_DATASETS)}")

    # 5. Sources / Views / Widgets list
    try:
        sources = http_json("GET", f"{API}/sources?projectId=1", token=token)
        src_list = sources.get("payload") or sources.get("payloads") or []
        mes_src = [s for s in src_list if s.get("type") == "mes_api"]
        record("MES_API Source exists", len(mes_src) > 0, f"count={len(mes_src)}")
    except Exception as e:
        record("MES_API Source exists", False, str(e))

    try:
        views = http_json("GET", f"{API}/views?projectId=1", token=token)
        view_list = views.get("payload") or views.get("payloads") or []
        record("Views list", len(view_list) > 0, f"count={len(view_list)}")
    except Exception as e:
        record("Views list", False, str(e))

    widget_id = None
    try:
        widgets = http_json("GET", f"{API}/widgets?projectId=1", token=token)
        widget_list = widgets.get("payload") or widgets.get("payloads") or []
        record("Widgets list", len(widget_list) > 0, f"count={len(widget_list)}")
        if widget_list:
            widget_id = widget_list[0]["id"]
    except Exception as e:
        record("Widgets list", False, str(e))

    # 6. Widget Data API
    if widget_id:
        try:
            body = {
                "groups": [],
                "aggregators": [],
                "filters": [],
                "params": [{"name": "plant", "value": "P01"}],
                "pageNo": 1,
                "pageSize": 100,
                "nativeQuery": False,
            }
            data_res = http_json("POST", f"{API}/widgets/{widget_id}/data", body, token=token)
            payload = data_res.get("payload") or {}
            rows = payload.get("resultList") or []
            record("POST /widgets/{id}/data", True, f"widget={widget_id} rows={len(rows)}")
        except Exception as e:
            record("POST /widgets/{id}/data", False, str(e))
    else:
        record("POST /widgets/{id}/data", False, "no widget in project")

    # 7. authSso config exposed
    try:
        cfg = http_json("GET", f"{API}/configurations")
        mode = (cfg.get("payload") or {}).get("authSso", {}).get("mode")
        record("authSso.mode in configurations", mode in ("both", "mes-jwt", "eos-ticket"), f"mode={mode}")
    except Exception as e:
        record("authSso.mode in configurations", False, str(e))

    # 8. Embedded designer routes (webapp hash)
    for route in ("source-designer", "view-designer", "chart-designer"):
        try:
            st = http_status(f"{WEB}/")
            record(f"Route shell for /{route}", st == 200, "via webapp index")
            break
        except Exception as e:
            record(f"Route shell for /{route}", False, str(e))

    print(f"\n=== {passed}/{total} passed ===")
    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
