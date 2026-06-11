# MES × Davinci 配置师操作说明（Phase 1）

> 适用：Phase 1 地基阶段。配置师仍使用完整 Davinci UI 完成 Source → View → Widget。

## 设计链路（不变）

```
Source（数据源）→ View（字段模型）→ Widget（图表配置）→ MES 引用 widgetId
```

## 相同 / 不同对照表

| 操作步骤 | 与原生 Davinci | Phase 1 变化 |
|----------|----------------|--------------|
| **创建 Source** | 部分相同 | 新增 `MES_API`（baseUrl、datasetCode、鉴权）；只读 JDBC 禁止事务库 |
| **创建 View** | 视通道而定 | **通道 A**：API View，无 SQL，字段映射 + 变量；**通道 B**：查 `v_xxx` 汇总视图 |
| **创建 Widget** | **基本相同** | 拖拽、选图、样式；图表列表由 Registry 动态加载 |
| **创建 Dashboard** | 不同 | Phase 1 可内部验证；生产由 MES 自研布局 |
| **一线看板** | 不同 | MES 页面通过 `widgetId` 挂载（Phase 2 SDK） |

## 决策树

```
需要新业务数据？
├─ 是 → 联系 MES 提供 Dataset API 或只读汇总视图
└─ 否 → 复用已有 View

数据通道选择？
├─ 看板/实时 → MES_API + API View（推荐）
└─ 复杂历史报表 → 只读 JDBC + v_xxx 视图

需要新图表样式？
├─ 现有类型够用 → 选 bar / gauge / table
└─ 需新变种 → 研发在 chart_type 加 JSON（不需 MES 新接口）
```

## Phase 1 须知（3 条）

1. **数据找 MES，图表找 Davinci** — 汇总逻辑不在 Davinci 写 SQL
2. **API View 是新技能点** — 无 SQL，只做列映射和参数绑定
3. **Widget 步骤最熟悉** — 拖拽、选图、样式与以前一致

## MES_API Source 配置示例

| 字段 | 示例 | 说明 |
|------|------|------|
| Base URL | `http://127.0.0.1:8080` | MES 或 Davinci 内置 Mock |
| Dataset Code | `output_shift` | 与 MES OpenAPI 一致 |
| 鉴权 | `bearer` / `forward-mes-token` | 静态 Token 或透传 MES Token |

开发 Mock：Davinci 内置 `POST /api/mes/dataset/{code}/query`，试点 `output_shift`、`yield_trend`。

## API View 配置要点

- View 绑定 `MES_API` Source
- `sql` 可留空或写 `{"datasetCode":"output_shift"}` 覆盖 Source 默认
- View 变量名与 MES `params` 键一致（如 `plant`、`line`、`shift`）
- 预览数据走 MES Dataset API，不经 SQL 引擎

## Dashboard URL 与 MES 发布说明

> 常见问题：`http://localhost:5002/#/project/1/portal/2/dashboard/2` 是不是发布到 MES 的 URL？

**不完全是。** 该 URL 是 Davinci 内部打开某个 Dashboard 的地址，**不是** MES 集成的标准「发布 URL」。

### URL 含义

前端路由为 `/project/:projectId/portal/:portalId/dashboard/:dashboardId`，例如：

```text
http://localhost:5002/#/project/1/portal/2/dashboard/2
```

| 段 | 含义 |
|----|------|
| `project/1` | 项目 ID |
| `portal/2` | Dashboard Portal（门户）ID |
| `dashboard/2` | Dashboard ID |

`5002` 为本地前端开发端口，**仅用于本机验证**；MES 生产环境应替换为实际部署的 Davinci 域名。

### 「发布」在 Davinci 里指什么

发布开关在 **Portal（门户）** 上，不在 Dashboard 上：

- 编辑 Portal 时勾选「发布」→ `dashboard_portal.publish = 1`
- 未发布时，只有具备写权限的配置师可见；只读用户不可见

整页验证脚本 `bin/test-mysql/setup_davinci_mes_dashboard.py` 也会将 Portal 设为 `publish = 1`。使用前请确认对应 Portal 已发布。

### MES 集成应如何使用

| 场景 | 正确做法 |
|------|----------|
| **配置师在 Davinci 内整页验证** | 使用上述 `#/project/.../portal/.../dashboard/...` URL（生产环境换域名） |
| **MES 一线看板（正式集成）** | 使用 `widgetId` + `@mes/chart-runtime` SDK，**不是**整页 Dashboard URL |
| **MES 自研页面布局** | MES 自行排布，引用多个 Widget |

Phase 1 分工：Dashboard 仅作内部验证；生产环境由 MES 自研布局，通过 `widgetId` 挂载（见 [集成路线图](./mes-chart-integration-roadmap.md) 模块 6、7）。

### 若 MES 需 iframe 嵌入整页 Dashboard

不推荐直接使用 `#/project/...`（需 Davinci 登录），常见两种方式：

**1. 分享链接（免登录）**

```text
http://{davinci-host}/share.html?shareToken={token}#share/dashboard
```

在 Dashboard 页面点击「分享」生成。

**2. SSO 跳转（MES 菜单带登录）**

```text
http://{gateway}/sso/launch?token={EOS_TOKEN}&app=davinci&redirect=%2F%23%2Fproject%2F1%2Fportal%2F2%2Fdashboard%2F2&embedded=1
```

`redirect` 为 URL 编码后的 hash 路径，详见 [EOS SSO](./eos-sso-integration.md)。

### 结论

- **本地验证**：URL 路径正确；`localhost:5002` 仅开发用；须确保 Portal 已发布。
- **MES 正式对接**：不是该 URL，而是各 Widget 的 `widgetId`（Phase 2 SDK）或分享 / SSO 嵌入整页。
- **临时整页嵌入 MES**：用分享链接或 SSO redirect，勿用需单独登录的 `#/project/...` 直连。

## MES 报表配置菜单（Phase 2）

MES 侧三级页面（`mes-web/modules/bi/`）：

| 菜单 | 页面 | 功能 |
|------|------|------|
| 数据连接 | `source-list.html` | Source 列表 + source-designer iframe |
| 数据集 | `view-list.html` | View 列表 + view-designer iframe |
| 图表库 | `widget-list.html` | Widget 列表 + chart-designer iframe |

配置项：`window.DAVINCI_API_BASE`、`window.DAVINCI_WEB_BASE`、`window.DAVINCI_PROJECT_ID`。

一线看板使用 `@mes/chart-runtime`，见 [运行时集成说明](./mes-runtime-integration.md)。

## 相关文档

- [集成路线图](./mes-chart-integration-roadmap.md)
- [运行时 SDK 集成](./mes-runtime-integration.md)
- [Dataset API 契约](./mes-dataset-api.openapi.yaml)
- [EOS SSO](./eos-sso-integration.md)
