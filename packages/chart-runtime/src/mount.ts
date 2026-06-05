import { renderDslOption } from '@mes/chart-core'
import { DavinciApi, DavinciApiOptions } from './api'

export interface MountOptions {
  baseUrl: string
  widgetId: number | string
  token?: string
  params?: Record<string, string>
  height?: number
  refreshInterval?: number
  onDrill?: (payload: unknown) => void
  onError?: (error: Error) => void
}

interface ChartInstance {
  timer: number | null
  container: HTMLElement
  chart: any
  destroy: () => void
}

const instances = new WeakMap<HTMLElement, ChartInstance>()

function buildExecuteParam (widgetConfig: any, params: Record<string, string>) {
  const cols = (widgetConfig.cols || []).map((c: any) => c.name)
  const rows = (widgetConfig.rows || []).map((r: any) => r.name)
  const groups = cols.concat(rows).filter((g: string) => g !== '指标名称')
  const aggregators = (widgetConfig.metrics || []).map((m: any) => ({
    column: m.name.split('@')[0],
    func: m.agg || 'sum'
  }))
  const paramList = Object.keys(params || {}).map((name) => ({
    name,
    value: params[name]
  }))
  const staticFilters = (widgetConfig.filters || []).reduce(
    (acc: string[], f: any) => acc.concat((f.config && f.config.sqlModel) || []),
    []
  )
  return {
    groups,
    aggregators,
    filters: staticFilters,
    params: paramList,
    pageNo: 1,
    pageSize: widgetConfig.pagination?.pageSize || 500,
    nativeQuery: false
  }
}

function showState (container: HTMLElement, text: string) {
  container.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#999;">${text}</div>`
}

export async function mount (
  selector: string | HTMLElement,
  options: MountOptions
): Promise<ChartInstance> {
  const container = typeof selector === 'string'
    ? document.querySelector(selector) as HTMLElement
    : selector
  if (!container) {
    throw new Error('Chart container not found')
  }
  const existing = instances.get(container)
  if (existing) {
    existing.destroy()
  }

  const apiOpts: DavinciApiOptions = {
    baseUrl: options.baseUrl,
    token: options.token
  }
  const height = options.height || 320
  container.style.height = `${height}px`
  container.style.width = '100%'
  showState(container, '加载中...')

  try {
    const widgetRes = await DavinciApi.getWidget(+options.widgetId, apiOpts)
    const widget = widgetRes.payload
    const config = typeof widget.config === 'string' ? JSON.parse(widget.config) : widget.config
    const executeParam = buildExecuteParam(config, options.params || {})
    const dataRes = await DavinciApi.queryWidgetData(+options.widgetId, executeParam, apiOpts)
    const payload = dataRes.payload || dataRes
    const resultList = payload.resultList || []

    const chartTypesRes = await DavinciApi.listChartTypes(apiOpts)
    const chartTypes = chartTypesRes.payload || chartTypesRes.payloads || []
    const selectedId = config.selectedChart
    const chartType = chartTypes.find((ct: any) => {
      try {
        const ds = JSON.parse(ct.dataSchema || '{}')
        return ds.id === selectedId
      } catch (e) {
        return false
      }
    })

    const echarts = (window as any).echarts
    if (!echarts) {
      showState(container, '请引入 echarts.min.js')
      throw new Error('echarts not loaded')
    }

    container.innerHTML = ''
    const chart = echarts.init(container)
    let option: object

    if (chartType && chartType.optionTemplate) {
      const template = typeof chartType.optionTemplate === 'string'
        ? JSON.parse(chartType.optionTemplate)
        : chartType.optionTemplate
      option = renderDslOption(template, {
        data: resultList,
        metrics: config.metrics,
        cols: config.cols,
        rows: config.rows,
        chartStyles: config.chartStyles,
        width: container.clientWidth,
        height
      }) as object
    } else if (resultList.length) {
      option = {
        xAxis: { type: 'category', data: resultList.map((r: any) => Object.values(r)[0]) },
        yAxis: { type: 'value' },
        series: [{ type: 'bar', data: resultList.map((r: any) => Object.values(r)[1]) }]
      }
    } else {
      showState(container, '暂无数据')
      return { timer: null, container, chart: null, destroy: () => {} }
    }

    chart.setOption(option)
    if (options.onDrill) {
      chart.on('click', (params: unknown) => options.onDrill(params))
    }

    let timer: number | null = null
    if (options.refreshInterval && options.refreshInterval > 0) {
      timer = window.setInterval(() => {
        mount(container, options).catch(() => {})
      }, options.refreshInterval)
    }

    const instance: ChartInstance = {
      timer,
      container,
      chart,
      destroy () {
        if (timer) {
          clearInterval(timer)
        }
        if (chart) {
          chart.dispose()
        }
        instances.delete(container)
      }
    }
    instances.set(container, instance)
    return instance
  } catch (err) {
    showState(container, '加载失败')
    if (options.onError) {
      options.onError(err as Error)
    }
    throw err
  }
}

export function unmount (selector: string | HTMLElement) {
  const container = typeof selector === 'string'
    ? document.querySelector(selector) as HTMLElement
    : selector
  const inst = container && instances.get(container)
  if (inst) {
    inst.destroy()
  }
}
