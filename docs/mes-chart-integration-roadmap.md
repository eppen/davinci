# MES 自研系统 × Davinci 自定义图表组件集成改造方案

> 版本：v1.0  
> 适用分支：dev-0.4  
> 定位：Davinci 作为 MES 的**自定义图表引擎**，支持**低代码扩展系统图表**，而非独立 DVAAS 门户。

---

## 1. 背景与目标

### 1.1 背景

- MES 为**自研系统**，已有业务页面、权限、数据集与事务逻辑。
- Davinci 具备 View / Widget / 查询与 ECharts 渲染能力，但原生形态是完整 DVAAS 平台，直接嵌入 MES 过重。
- 业务需要：在 MES 页面中挂载图表，并允许配置师/工程师**低代码扩展**新的系统图表类型，减少改核心代码发版。

### 1.2 目标

| 目标 | 说明 |
|------|------|
| 图表组件化 | MES 页面通过 SDK 引用 `widgetId` 渲染图表 |
| 低代码扩展 | 新增系统图表以 JSON 注册为主，少量场景用代码插件 |
| 数据解耦 | MES 提供 Dataset API；Davinci 不直连 MES 事务库 |
| 权限统一 | 身份与组织权限以 MES 为主，Davinci 做校验代理 |
| 可运维 | 图表定义可版本化、导入导出、独立部署 Chart Service |

### 1.3 非目标（本阶段不做）

- 用 Davinci 替代 MES 门户、工单、告警事务
- 全量保留 Davinci Organization / Portal / Display 给一线操作工使用
- 开箱 WebSocket 实时推送（短期用 MES 汇总 + 轮询/短缓存）

---

## 2. 总体架构

```
┌─────────────────────────────────────────────────────────┐
│                    MES 自研前端                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ 产线看板页    │  │ 质量分析页    │  │ 报表配置页    │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │          │
│         └────────┬────────┴────────┬────────┘          │
│                  ▼                 ▼                   │
│         @mes/chart-runtime   chart-designer (iframe)   │
└──────────────────┬─────────────────┬───────────────────┘
                   │                 │
                   ▼                 ▼
┌──────────────────────────────────────────────────────────┐
│              Davinci Chart Service（精简部署）            │
│  Chart Registry │ Widget API │ View/Query │ Auth Proxy  │
└──────────────────┬───────────────────────────────────────┘
                   ▼
         MES Dataset API（主） / 只读 SQL View（辅）
```

### 2.1 数据双通道

| 通道 | 场景 | 说明 |
|------|------|------|
| **A：MES Dataset API** | 业务看板、实时性要求较高 | MES 提供标准 JSON，Davinci 映射字段渲染 |
| **B：View SQL** | 复杂分析、历史报表 | 只读从库 + 汇总视图，禁止扫事务大表 |

### 2.2 职责边界

| 职责 | MES | Davinci Chart Service |
|------|-----|------------------------|
| 页面布局、导航、路由 | ✅ | ❌ |
| 用户、角色、工厂/车间权限 | ✅ | 校验代理 |
| 业务 Dataset / 汇总表 | ✅ | 消费 |
| 图表类型注册与渲染 | 规范定义 | ✅ 存储 + 执行 |
| 图表配置设计器 | 嵌入入口 | ✅ 设计器页面 |
| 单图运行时 SDK | 集成 `@mes/chart-runtime` | 提供 API |
| 告警、工单、设备控制 | ✅ | ❌ |

---

## 3. 分模块改造路线图

### 模块 1：Chart Registry（图表注册中心）— P0

**现状问题：** 图表写死在 `webapp/app/containers/Widget/config/chart/index.tsx` 的 `widgetlibs` 数组；新增图表需改配置、渲染器、`OperatingPanel.tsx` 等多处。

**改造目标：** 系统内置图表与扩展图表统一入库，前端动态加载。

| 序号 | 任务 | 产出 |
|------|------|------|
| 1.1 | 设计并创建 `chart_type` 表 | 表结构 + 迁移脚本 |
| 1.2 | 将现有 bar/line/gauge/table 等导出为 JSON 注册记录 | 内置图表包 v1 |
| 1.3 | 启用已存在但未注册的图表（boxplot、treemap 等） | 注册记录补全 |
| 1.4 | 提供 CRUD / 发布 / 停用 API | `GET/POST /api/v3/chart-types` |
| 1.5 | 前端启动时拉取并合并 widget 选择器 | 动态 `widgetlibs` |

#### 3.1.1 表结构草案：`chart_type`

```sql
CREATE TABLE chart_type (
  id              BIGINT PRIMARY KEY AUTO_INCREMENT,
  code            VARCHAR(64)  NOT NULL UNIQUE COMMENT '唯一编码，如 mes-oee-gauge',
  name            VARCHAR(128) NOT NULL COMMENT '显示名称',
  category        VARCHAR(32)  NOT NULL DEFAULT 'general' COMMENT 'general/mes/quality/equipment',
  icon            VARCHAR(64)  NULL COMMENT '图标 class 或 URL',
  renderer        VARCHAR(32)  NOT NULL DEFAULT 'echarts' COMMENT 'echarts | custom:xxx',
  config_schema   JSON         NOT NULL COMMENT '样式表单 schema',
  data_schema     JSON         NOT NULL COMMENT '维度/指标槽位规则',
  option_template JSON         NULL COMMENT 'ECharts option 模板（renderer=echarts）',
  version         INT          NOT NULL DEFAULT 1,
  builtin         TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '是否系统内置',
  enabled         TINYINT(1)   NOT NULL DEFAULT 1,
  description     VARCHAR(512) NULL,
  create_by       BIGINT       NULL,
  create_time     DATETIME     NULL,
  update_by       BIGINT       NULL,
  update_time     DATETIME     NULL
);
```

---

### 模块 2：Chart DSL（低代码图表描述）— P0

**改造目标：** 用 JSON 描述「数据槽位 + 样式表单 + ECharts 模板」，覆盖约 80% 制造图表。

#### 3.2.1 DSL 结构说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | string | 图表类型唯一编码 |
| `dataSchema` | object | 维度/指标/筛选槽位及数量规则 |
| `styleSchema` | array | 动态样式表单字段定义 |
| `optionTemplate` | object | ECharts option，支持 `{{}}` 占位符 |
| `rules` | array | 与现有 `IChartRule` 兼容的校验规则 |

#### 3.2.2 示例：MES OEE 仪表盘

```json
{
  "code": "mes-oee-gauge",
  "name": "OEE 仪表盘",
  "category": "mes",
  "renderer": "echarts",
  "dataSchema": {
    "metrics": { "min": 1, "max": 1, "title": "OEE 指标" },
    "cols": { "min": 0, "max": 1, "title": "产线（可选）" }
  },
  "styleSchema": [
    { "key": "min", "title": "最小值", "component": "number", "default": 0 },
    { "key": "max", "title": "最大值", "component": "number", "default": 100 },
    { "key": "unit", "title": "单位", "component": "input", "default": "%" }
  ],
  "rules": [{ "dimension": [0, 1], "metric": [1, 1] }],
  "optionTemplate": {
    "series": [{
      "type": "gauge",
      "min": "{{style.min}}",
      "max": "{{style.max}}",
      "detail": { "formatter": "{value}{{style.unit}}" },
      "data": [{ "value": "{{metrics[0].value}}", "name": "{{metrics[0].name}}" }]
    }]
  }
}
```

#### 3.2.3 任务清单

| 序号 | 任务 |
|------|------|
| 2.1 | 从 DB/JSON 生成 `IChartInfo`，兼容现有 Widget 编辑器 |
| 2.2 | 通用 `styleSchema` 表单渲染器，减少 `OperatingPanel` 分支 |
| 2.3 | 通用 ECharts 渲染器：`optionTemplate` + 数据绑定引擎 |
| 2.4 | 保存时 JSON Schema 校验 |
| 2.5 | Widget 引用 `chartTypeCode@version`，支持平滑升级 |

#### 3.2.4 首批 MES 系统图表包

| code | 名称 | 用途 |
|------|------|------|
| `mes-output-card` | 产量卡片 | 当班产量、计划达成 |
| `mes-oee-gauge` | OEE 仪表盘 | 设备综合效率 |
| `mes-yield-trend` | 良率趋势 | 折线/柱状 |
| `mes-pareto-bar` | 不良 Pareto | 质量 Top N |
| `mes-equip-status` | 设备状态矩阵 | 红绿黄状态 |
| `mes-wip-table` | 在制工单表 | 表格 + 分页 |

---

### 模块 3：Custom Renderer（代码级扩展）— P1

适用于 DSL 无法表达的图表：SPC 控制图、甘特图、自定义 Canvas 等。

| 序号 | 任务 |
|------|------|
| 3.1 | 定义前端 `ChartRenderer` 接口 |
| 3.2 | `chart_type.renderer = 'custom:mes-spc'` 映射到实现 |
| 3.3 | 独立 npm 包 `@mes/davinci-charts`，MES 与 Davinci 共用 |
| 3.4 | 白名单注册，禁止任意 JS 注入 |

**扩展分级：**

| 级别 | 操作者 | 方式 |
|------|--------|------|
| L1 低代码 | 配置师 | 编辑 Chart DSL JSON |
| L2 模板复制 | 业务工程师 | 复制内置 JSON 修改 |
| L3 代码插件 | 研发 | `@mes/davinci-charts` 注册 custom renderer |

---

### 模块 4：Dataset Adapter（MES 数据集）— P0

#### 3.4.1 MES Dataset API 协议（建议）

**请求**

```http
POST /api/mes/dataset/{datasetCode}/query
Authorization: Bearer {mes_token}
Content-Type: application/json

{
  "params": {
    "plant": "P01",
    "line": "L03",
    "shift": "A",
    "date": "2026-06-05"
  },
  "pagination": { "pageNo": 1, "pageSize": 500 }
}
```

**响应**

```json
{
  "columns": [
    { "name": "line_code", "type": "string", "role": "dimension" },
    { "name": "output_qty", "type": "number", "role": "metric" }
  ],
  "rows": [
    { "line_code": "L03", "output_qty": 1280 }
  ],
  "meta": {
    "totalCount": 1,
    "cached": false,
    "queryTimeMs": 45
  }
}
```

#### 3.4.2 Davinci 侧改造

| 序号 | 任务 |
|------|------|
| 4.1 | 新增 Source 类型 `MES_API`（baseUrl、datasetCode、鉴权） |
| 4.2 | 新增「API View」：不写 SQL，仅字段映射到 View Model |
| 4.3 | Widget 查询时透传 MES 页面 params |
| 4.4 | 按 `datasetCode + params` 做 Redis 缓存（建议 30s～60s） |

---

### 模块 5：Chart Designer（精简设计器嵌入）— P1

从完整 Davinci 中抽出单页，供 MES「报表配置」菜单 iframe 嵌入。

**路由示例**

```
/chart-designer?viewId={viewId}&widgetId={widgetId?}&embedded=1
```

| 保留 | 隐藏 |
|------|------|
| 数据集/View 选择 | Organization / Project 切换 |
| 字段拖拽、图表类型、样式 | Portal / Display / 全局导航 |
| 保存 Widget | 独立登录（走 SSO） |

| 序号 | 任务 |
|------|------|
| 5.1 | 独立路由与 embedded 布局 |
| 5.2 | MES SSO → Davinci JWT |
| 5.3 | 保存后回传 `widgetId` 给 MES |
| 5.4 | 仅「报表配置员」角色可访问 |

---

### 模块 6：Chart Runtime SDK — P0

MES 前端通过 SDK 挂载图表，日常集成主路径。

#### 3.6.1 使用示例

```tsx
import { MesChart } from '@mes/chart-runtime'

<MesChart
  widgetId="123456"
  params={{ plant: 'P01', line: 'L03', shift: 'A' }}
  height={320}
  refreshInterval={60000}
  onDrill={(payload) => mesRouter.open('workorder', payload)}
/>
```

#### 3.6.2 SDK 职责

1. `GET /api/v3/widgets/{id}` — 拉 Widget 配置  
2. `POST /api/v3/widgets/{id}/data` — 拉数据（带 params）  
3. 调用 Chart Registry 对应 renderer 渲染  
4. 统一 loading / empty / error 态  

#### 3.6.3 Davinci API 契约（Chart Service 对外）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v3/chart-types` | 图表类型列表（Registry） |
| GET | `/api/v3/chart-types/{code}` | 单个类型含 DSL |
| GET | `/api/v3/widgets/{id}` | Widget 配置 |
| POST | `/api/v3/widgets/{id}/data` | 查询数据，body 含 params/filters |
| POST | `/api/v3/widgets` | 创建（设计器） |
| PUT | `/api/v3/widgets/{id}` | 更新（设计器） |

**查询数据请求体示例**

```json
{
  "params": { "plant": "P01", "line": "L03" },
  "filters": [],
  "pagination": { "pageNo": 1, "pageSize": 100 }
}
```

**查询数据响应体示例**

```json
{
  "payload": {
    "resultList": [],
    "columns": [],
    "pageNo": 1,
    "pageSize": 100,
    "totalCount": 0
  }
}
```

---

### 模块 7：Dashboard 轻量化 — P2（可选）

| 方案 | 说明 | 建议 |
|------|------|------|
| A | MES 自研 grid 布局 + 多个 `MesChart` | **推荐** |
| B | Davinci Dashboard 导出 layout JSON，MES 解析 | 仅配置预览场景 |

Davinci 专注**单图**；整页布局由 MES 负责。

---

### 模块 8：Query Engine 修复与精简 — P1

| 序号 | 任务 | 原因 |
|------|------|------|
| 8.1 | 合并 widget 静态 filter + 全局 filter + 联动 filter（`tempFilters`） | 代码内 15+ 处 TODO，MES 多参数必备 |
| 8.2 | 修复循环联动（`LinkageForm` FIXME） | 多图联动场景 |
| 8.3 | API View 路径免二次 SQL 聚合 | 性能与语义清晰 |
| 8.4 | 查询超时、并发限制、慢 SQL 日志 | 保护 MES 数据层 |

---

### 模块 9：身份与权限 — P1

| 序号 | 任务 |
|------|------|
| 9.1 | MES JWT / SSO Ticket → Davinci 会话（可扩展 `docs/eos-sso-integration.md`） |
| 9.2 | MES 用户-工厂-角色同步到 Davinci user + 权限变量默认值 |
| 9.3 | Widget 绑定 scope（如 `plant:P01`）或 MES 菜单权限码 |
| 9.4 | 单 MES 实例映射单 Org/Project，简化多租户 UI |

---

### 模块 10：运维与工程化 — 持续

| 任务 | 说明 |
|------|------|
| Chart Service 独立部署 | 与 MES 主应用分离，便于扩缩容 |
| 图表 JSON 进 Git | `chart_type` 支持 import/export |
| CI 校验 DSL | 合并前 JSON Schema + 样例数据渲染测试 |
| 监控指标 | 慢查询率、渲染失败率、缓存命中率 |
| 启动配置 | mail 校验改为警告模式；Redis 生产建议必开 |

---

## 4. 实施阶段

```
Phase 1（第 1～2 月）打地基
├── Chart Registry 表 + API + 内置图表 JSON 化
├── MES Dataset API 协议定稿 + MES_API Source
├── SSO 与 MES  token 打通
└── tempFilters 合并修复

Phase 2（第 2～4 月）可用
├── Chart DSL + 通用 ECharts 渲染器
├── Chart Designer 嵌入页
├── @mes/chart-runtime SDK v1
└── 6 个 MES 系统图表内置

Phase 3（第 4～6 月）可扩展
├── custom renderer 插件机制
├── @mes/davinci-charts 制造插件包
├── 图表 import/export + 版本管理
└── 权限与 MES 菜单深度集成

Phase 4（第 6 月+）增强
├── SPC / 甘特等 L3 插件
├── 刷新策略优化（汇总表 + 短缓存）
└── ECharts 5 / 前端栈升级评估
```

---

## 5. 最小可行试点（MVP，建议 8 周）

### 5.1 范围

1. Chart Registry 入库，动态加载 3 类图：柱状图、仪表盘、表格  
2. MES 提供 2 个 Dataset API：`output_shift`（产量）、`yield_trend`（良率）  
3. `@mes/chart-runtime` 在 MES **一条产线看板页**嵌入 2 个 Widget  
4. Chart Designer iframe：配置师新建 1 个 Widget 并在 MES 页引用  
5. SSO 单点登录，无二次登录  

### 5.2 验收标准

- [ ] 新增一种柱状图变种**不改 Davinci 核心代码**，仅新增 `chart_type` JSON 记录  
- [ ] MES 页面改 `params` 后图表数据随工厂/产线/班次变化  
- [ ] 配置师可在设计器完成绑数据集 → 选图 → 保存 → MES 引用  
- [ ] 无 MES 权限的用户无法通过 API 拉取对应 Widget 数据  

---

## 6. 风险与规避

| 风险 | 影响 | 规避措施 |
|------|------|----------|
| Davinci 直连 MES 事务库 | 拖垮生产 | 强制 Dataset API + 只读从库 |
| 权限漏配 | 跨厂数据泄露 | View 权限变量 + Widget scope + 渗透测试 |
| 过度依赖完整 Davinci UI | 集成重、学习成本高 | 仅嵌入 Designer + Runtime SDK |
| 实时预期过高 | 体验不达标 | 分级 SLA：30s 轮询 vs T+1 报表 |
| 核心代码 fork 过重 | 升级困难 | Registry/DSL 优先，少改 OperatingPanel |

---

## 7. 附录

### 7.1 与现有 Davinci 概念映射

| Davinci 概念 | MES 集成后角色 |
|--------------|----------------|
| Source | MES_API + 可选只读 JDBC |
| View | 字段模型 + 变量；API View 可无 SQL |
| Widget | 可复用单元，MES 通过 widgetId 引用 |
| Dashboard | 可选；建议 MES 自研布局 |
| Display | 非主路径；工厂大屏可二期再议 |
| Organization / Project | 简化为单实例映射 |

### 7.2 相关仓库文档

- [EOS SSO 集成说明](./eos-sso-integration.md)
- [SQL Server 冒烟测试清单](./sqlserver-smoke-test.md)
- [部署手册](./_docs/zh/1.1-deployment.md)
- [Widget 用户手册](./_docs/zh/2.3-widget.md)

### 7.3 文档维护

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-06-05 | 初版：MES 图表组件 + 低代码扩展路线图 |

---

## 8. 下一步建议交付物

按优先级择一开工：

1. **Chart Registry**：`chart_type` 建表 SQL + Java CRUD + 前端动态加载 POC  
2. **MES API 契约**：OpenAPI 3.0 完整描述 Dataset 与 Widget Data 接口  
3. **@mes/chart-runtime**：npm 包骨架 + 对接现有 Davinci Widget API  

建议顺序：**Registry → Dataset 契约 → Runtime SDK → Designer 嵌入**。
