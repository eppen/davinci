(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports) :
  typeof define === 'function' && define.amd ? define(['exports'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.MesChartRuntime = {}));
})(this, (function (exports) { 'use strict';

  const PLACEHOLDER_RE = /\{\{([^}]+)\}\}/g;
  function resolvePath(ctx, path) {
    const parts = path.trim().split(".");
    let current = ctx;
    for (const part of parts) {
      if (current == null) {
        return void 0;
      }
      const bracket = part.match(/^(\w+)\[(\d+)\]$/);
      if (bracket) {
        const arr = current[bracket[1]];
        current = Array.isArray(arr) ? arr[parseInt(bracket[2], 10)] : void 0;
      } else {
        current = current[part];
      }
    }
    return current;
  }
  function resolvePlaceholder(expr, ctx) {
    const trimmed = expr.trim();
    if (trimmed.startsWith("data[")) {
      return resolvePath(ctx, trimmed);
    }
    return resolvePath(ctx, trimmed);
  }
  function bindTemplateValue(value, ctx) {
    if (typeof value === "string") {
      if (value.indexOf("{{") === -1) {
        return value;
      }
      const fullMatch = value.match(/^\{\{([^}]+)\}\}$/);
      if (fullMatch) {
        const resolved = resolvePlaceholder(fullMatch[1], ctx);
        return resolved !== void 0 ? resolved : value;
      }
      return value.replace(PLACEHOLDER_RE, (_, inner) => {
        const resolved = resolvePlaceholder(inner, ctx);
        return resolved !== void 0 && resolved !== null ? String(resolved) : "";
      });
    }
    if (Array.isArray(value)) {
      return value.map((item) => bindTemplateValue(item, ctx));
    }
    if (value !== null && typeof value === "object") {
      const out = {};
      Object.keys(value).forEach((key) => {
        out[key] = bindTemplateValue(value[key], ctx);
      });
      return out;
    }
    return value;
  }
  function bindTemplate(template, ctx) {
    return bindTemplateValue(template, ctx);
  }

  function decodeMetricName(name) {
    if (!name) {
      return name;
    }
    const idx = name.indexOf("@davinci");
    return idx > -1 ? name.substring(0, idx) : name;
  }
  function buildBindingContext(props) {
    const data = props.data || [];
    const metrics = (props.metrics || []).map((m) => {
      var _a, _b;
      const name = decodeMetricName(m.name);
      return {
        name,
        value: data.length ? (_b = (_a = data[0][m.name]) != null ? _a : data[0][name]) != null ? _b : "" : ""
      };
    });
    const cols = (props.cols || []).map((c) => {
      var _a;
      return {
        name: c.name,
        value: data.length ? String((_a = data[0][c.name]) != null ? _a : "") : ""
      };
    });
    const rows = (props.rows || []).map((r) => {
      var _a;
      return {
        name: r.name,
        value: data.length ? String((_a = data[0][r.name]) != null ? _a : "") : ""
      };
    });
    const style = props.chartStyles && props.chartStyles.dsl || {};
    return { style, metrics, cols, rows, data };
  }
  function buildSeriesFromData(props, xField, yField) {
    const data = props.data || [];
    return data.map((row) => {
      var _a;
      return {
        name: String((_a = row[xField]) != null ? _a : ""),
        value: row[yField]
      };
    });
  }
  function getMetricValues(props, metricIndex = 0) {
    const metrics = props.metrics || [];
    if (!metrics[metricIndex]) {
      return [];
    }
    const field = metrics[metricIndex].name;
    return (props.data || []).map((row) => row[field]);
  }
  function getColValues(props, colIndex = 0) {
    const cols = props.cols || [];
    if (!cols[colIndex]) {
      return [];
    }
    const field = cols[colIndex].name;
    return (props.data || []).map((row) => {
      var _a;
      return String((_a = row[field]) != null ? _a : "");
    });
  }

  var __defProp = Object.defineProperty;
  var __defProps = Object.defineProperties;
  var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
  var __getOwnPropSymbols = Object.getOwnPropertySymbols;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __propIsEnum = Object.prototype.propertyIsEnumerable;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __spreadValues = (a, b) => {
    for (var prop in b || (b = {}))
      if (__hasOwnProp.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    if (__getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(b)) {
        if (__propIsEnum.call(b, prop))
          __defNormalProp(a, prop, b[prop]);
      }
    return a;
  };
  var __spreadProps = (a, b) => __defProps(a, __getOwnPropDescs(b));
  function parseTemplate(optionTemplate) {
    if (typeof optionTemplate === "string") {
      return JSON.parse(optionTemplate);
    }
    return optionTemplate;
  }
  function enrichContext(props, base) {
    const colValues = getColValues(props, 0);
    const metricValues = getMetricValues(props, 0);
    const metricValues2 = getMetricValues(props, 1);
    const seriesData = props.cols && props.cols.length && props.metrics && props.metrics.length ? buildSeriesFromData(props, props.cols[0].name, props.metrics[0].name) : [];
    return __spreadProps(__spreadValues({}, base), {
      colValues,
      metricValues,
      metricValues2,
      seriesData,
      width: props.width,
      height: props.height
    });
  }
  function renderDslOption(optionTemplate, props) {
    const template = parseTemplate(optionTemplate);
    const ctx = enrichContext(props, buildBindingContext(props));
    const bound = bindTemplate(template, ctx);
    if (bound && bound.series) {
      const series = bound.series;
      const tplSeries = template.series;
      if (Array.isArray(series) && Array.isArray(tplSeries)) {
        series.forEach((s, i) => {
          const tpl = tplSeries[i];
          if (s && typeof s === "object" && tpl && tpl.data === "{{seriesData}}") {
            s.data = ctx.seriesData.map((d) => d.value);
          }
          if (s && typeof s === "object" && tpl && tpl.data === "{{colValues}}") {
            s.data = ctx.colValues;
          }
        });
      }
    }
    if (bound && !bound.grid) {
      bound.grid = {
        left: "8%",
        right: "8%",
        top: "12%",
        bottom: "12%",
        containLabel: true
      };
    }
    return bound;
  }

  async function request(opts, method, path, body) {
    const headers = {
      "Content-Type": "application/json"
    };
    if (opts.token) {
      headers.Authorization = opts.token.startsWith("Bearer ") ? opts.token : `Bearer ${opts.token}`;
    }
    const res = await fetch(`${opts.baseUrl.replace(/\/$/, "")}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : void 0
    });
    const json = await res.json();
    if (!res.ok) {
      throw new Error(json.message || `HTTP ${res.status}`);
    }
    return json.header || json.payload !== void 0 ? json : { payload: json };
  }
  const DavinciApi = {
    listSources(projectId, opts) {
      return request(opts, "GET", `/sources?projectId=${projectId}`);
    },
    getSource(id, opts) {
      return request(opts, "GET", `/sources/${id}`);
    },
    listViews(projectId, opts) {
      return request(opts, "GET", `/views?projectId=${projectId}`);
    },
    listWidgets(projectId, opts) {
      return request(opts, "GET", `/widgets?projectId=${projectId}`);
    },
    getWidget(id, opts) {
      return request(opts, "GET", `/widgets/${id}`);
    },
    queryWidgetData(id, executeParam, opts) {
      return request(opts, "POST", `/widgets/${id}/data`, executeParam);
    },
    listChartTypes(opts) {
      return request(opts, "GET", "/chart-types?enabled=true");
    },
    loginMesToken(mesToken, opts) {
      return request(opts, "POST", "/login/mes-token", { token: mesToken });
    }
  };

  const instances = /* @__PURE__ */ new WeakMap();
  function buildExecuteParam(widgetConfig, params) {
    var _a;
    const cols = (widgetConfig.cols || []).map((c) => c.name);
    const rows = (widgetConfig.rows || []).map((r) => r.name);
    const groups = cols.concat(rows).filter((g) => g !== "\u6307\u6807\u540D\u79F0");
    const aggregators = (widgetConfig.metrics || []).map((m) => ({
      column: m.name.split("@")[0],
      func: m.agg || "sum"
    }));
    const paramList = Object.keys(params || {}).map((name) => ({
      name,
      value: params[name]
    }));
    const staticFilters = (widgetConfig.filters || []).reduce(
      (acc, f) => acc.concat(f.config && f.config.sqlModel || []),
      []
    );
    return {
      groups,
      aggregators,
      filters: staticFilters,
      params: paramList,
      pageNo: 1,
      pageSize: ((_a = widgetConfig.pagination) == null ? void 0 : _a.pageSize) || 500,
      nativeQuery: false
    };
  }
  function showState(container, text) {
    container.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#999;">${text}</div>`;
  }
  async function mount(selector, options) {
    const container = typeof selector === "string" ? document.querySelector(selector) : selector;
    if (!container) {
      throw new Error("Chart container not found");
    }
    const existing = instances.get(container);
    if (existing) {
      existing.destroy();
    }
    const apiOpts = {
      baseUrl: options.baseUrl,
      token: options.token
    };
    const height = options.height || 320;
    container.style.height = `${height}px`;
    container.style.width = "100%";
    showState(container, "\u52A0\u8F7D\u4E2D...");
    try {
      const widgetRes = await DavinciApi.getWidget(+options.widgetId, apiOpts);
      const widget = widgetRes.payload;
      const config = typeof widget.config === "string" ? JSON.parse(widget.config) : widget.config;
      const executeParam = buildExecuteParam(config, options.params || {});
      const dataRes = await DavinciApi.queryWidgetData(+options.widgetId, executeParam, apiOpts);
      const payload = dataRes.payload || dataRes;
      const resultList = payload.resultList || [];
      const chartTypesRes = await DavinciApi.listChartTypes(apiOpts);
      const chartTypes = chartTypesRes.payload || chartTypesRes.payloads || [];
      const selectedId = config.selectedChart;
      const chartType = chartTypes.find((ct) => {
        try {
          const ds = JSON.parse(ct.dataSchema || "{}");
          return ds.id === selectedId;
        } catch (e) {
          return false;
        }
      });
      const echarts = window.echarts;
      if (!echarts) {
        showState(container, "\u8BF7\u5F15\u5165 echarts.min.js");
        throw new Error("echarts not loaded");
      }
      container.innerHTML = "";
      const chart = echarts.init(container);
      let option;
      if (chartType && chartType.optionTemplate) {
        const template = typeof chartType.optionTemplate === "string" ? JSON.parse(chartType.optionTemplate) : chartType.optionTemplate;
        option = renderDslOption(template, {
          data: resultList,
          metrics: config.metrics,
          cols: config.cols,
          rows: config.rows,
          chartStyles: config.chartStyles,
          width: container.clientWidth,
          height
        });
      } else if (resultList.length) {
        option = {
          xAxis: { type: "category", data: resultList.map((r) => Object.values(r)[0]) },
          yAxis: { type: "value" },
          series: [{ type: "bar", data: resultList.map((r) => Object.values(r)[1]) }]
        };
      } else {
        showState(container, "\u6682\u65E0\u6570\u636E");
        return { timer: null, container, chart: null, destroy: () => {
        } };
      }
      chart.setOption(option);
      if (options.onDrill) {
        chart.on("click", (params) => options.onDrill(params));
      }
      let timer = null;
      if (options.refreshInterval && options.refreshInterval > 0) {
        timer = window.setInterval(() => {
          mount(container, options).catch(() => {
          });
        }, options.refreshInterval);
      }
      const instance = {
        timer,
        container,
        chart,
        destroy() {
          if (timer) {
            clearInterval(timer);
          }
          if (chart) {
            chart.dispose();
          }
          instances.delete(container);
        }
      };
      instances.set(container, instance);
      return instance;
    } catch (err) {
      showState(container, "\u52A0\u8F7D\u5931\u8D25");
      if (options.onError) {
        options.onError(err);
      }
      throw err;
    }
  }
  function unmount(selector) {
    const container = typeof selector === "string" ? document.querySelector(selector) : selector;
    const inst = container && instances.get(container);
    if (inst) {
      inst.destroy();
    }
  }

  var index = {
    mount,
    unmount,
    DavinciApi
  };

  exports.DavinciApi = DavinciApi;
  exports["default"] = index;
  exports.mount = mount;
  exports.unmount = unmount;

  Object.defineProperty(exports, '__esModule', { value: true });

}));
//# sourceMappingURL=mes-chart-runtime.js.map
