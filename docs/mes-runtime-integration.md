# MES × Davinci Chart Runtime 集成说明

## UMD 引入

```html
<script src="https://cdn.jsdelivr.net/npm/echarts@4/dist/echarts.min.js"></script>
<script src="{davinci-host}/mes-chart-runtime.js?v=1.0.0"></script>
```

## 产线看板嵌入示例（Vue2 + jQuery）

```javascript
MesChartRuntime.mount('#outputChart', {
  baseUrl: 'http://davinci-host:8080/api/v3',
  widgetId: 123,
  token: localStorage.getItem('token'),
  params: { plant: 'P01', line: 'L03', shift: 'A' },
  height: 320,
  refreshInterval: 60000,
  onDrill: function (payload) {
    console.log('drill', payload)
  }
})
```

## 报表配置 iframe

| 设计器 | URL |
|--------|-----|
| Source | `/#/source-designer?projectId=1&embedded=1&mesToken={token}` |
| View | `/#/view-designer?projectId=1&viewId={id?}&embedded=1&mesToken={token}` |
| Widget | `/#/chart-designer?projectId=1&viewId=5&widgetId={id?}&embedded=1&mesToken={token}` |

保存后监听 `postMessage`：`davinci:source-saved` / `davinci:view-saved` / `davinci:widget-saved`。

## API

- `GET /api/v3/widgets/{id}`
- `POST /api/v3/widgets/{id}/data`
- `GET /api/v3/chart-types?enabled=true`
