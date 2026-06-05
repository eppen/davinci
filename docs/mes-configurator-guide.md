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

## 相关文档

- [集成路线图](./mes-chart-integration-roadmap.md)
- [Dataset API 契约](./mes-dataset-api.openapi.yaml)
- [EOS SSO](./eos-sso-integration.md)
