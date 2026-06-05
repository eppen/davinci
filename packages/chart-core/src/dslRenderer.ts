import { bindTemplate } from './templateEngine'
import { buildBindingContext, buildSeriesFromData, getColValues, getMetricValues } from './dataBinder'
import { ChartPropsLike } from './types'

function parseTemplate (optionTemplate: object | string): object {
  if (typeof optionTemplate === 'string') {
    return JSON.parse(optionTemplate)
  }
  return optionTemplate
}

function enrichContext (props: ChartPropsLike, base: ReturnType<typeof buildBindingContext>) {
  const colValues = getColValues(props, 0)
  const metricValues = getMetricValues(props, 0)
  const metricValues2 = getMetricValues(props, 1)
  const seriesData = props.cols && props.cols.length && props.metrics && props.metrics.length
    ? buildSeriesFromData(props, props.cols[0].name, props.metrics[0].name)
    : []
  return {
    ...base,
    colValues,
    metricValues,
    metricValues2,
    seriesData,
    width: props.width,
    height: props.height
  }
}

export function renderDslOption (
  optionTemplate: object | string,
  props: ChartPropsLike
): object {
  const template = parseTemplate(optionTemplate)
  const ctx = enrichContext(props, buildBindingContext(props))
  const bound = bindTemplate(template, ctx) as object

  if (bound && (bound as { series?: unknown[] }).series) {
    const series = (bound as { series: unknown[] }).series
    const tplSeries = (template as { series?: unknown[] }).series
    if (Array.isArray(series) && Array.isArray(tplSeries)) {
      series.forEach((s, i) => {
        const tpl = tplSeries[i] as { data?: unknown }
        if (s && typeof s === 'object' && tpl && tpl.data === '{{seriesData}}') {
          (s as { data: unknown }).data = ctx.seriesData.map((d) => d.value)
        }
        if (s && typeof s === 'object' && tpl && tpl.data === '{{colValues}}') {
          (s as { data: unknown }).data = ctx.colValues
        }
      })
    }
  }

  if (bound && !(bound as { grid?: unknown }).grid) {
    (bound as { grid: object }).grid = {
      left: '8%',
      right: '8%',
      top: '12%',
      bottom: '12%',
      containLabel: true
    }
  }

  return bound
}
