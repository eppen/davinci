import { BindingContext, ChartPropsLike } from './types'

function decodeMetricName (name: string): string {
  if (!name) {
    return name
  }
  const idx = name.indexOf('@davinci')
  return idx > -1 ? name.substring(0, idx) : name
}

function firstRowValue (
  data: Array<Record<string, unknown>>,
  fieldName: string
): string | number {
  if (!data || !data.length || !fieldName) {
    return ''
  }
  const row = data[0]
  const val = row[fieldName]
  if (val === undefined || val === null) {
    return ''
  }
  return val as string | number
}

export function buildBindingContext (props: ChartPropsLike): BindingContext {
  const data = props.data || []
  const metrics = (props.metrics || []).map((m) => {
    const name = decodeMetricName(m.name)
    return {
      name,
      value: (data.length ? (data[0][m.name] ?? data[0][name] ?? '') : '') as string | number
    }
  })
  const cols = (props.cols || []).map((c) => ({
    name: c.name,
    value: data.length ? String(data[0][c.name] ?? '') : ''
  }))
  const rows = (props.rows || []).map((r) => ({
    name: r.name,
    value: data.length ? String(data[0][r.name] ?? '') : ''
  }))
  const style = (props.chartStyles && props.chartStyles.dsl) || {}
  return { style, metrics, cols, rows, data }
}

export function buildSeriesFromData (
  props: ChartPropsLike,
  xField: string,
  yField: string
): Array<{ name: string; value: number | string }> {
  const data = props.data || []
  return data.map((row) => ({
    name: String(row[xField] ?? ''),
    value: row[yField] as number | string
  }))
}

export function getMetricValues (
  props: ChartPropsLike,
  metricIndex = 0
): Array<number | string> {
  const metrics = props.metrics || []
  if (!metrics[metricIndex]) {
    return []
  }
  const field = metrics[metricIndex].name
  return (props.data || []).map((row) => row[field] as number | string)
}

export function getColValues (props: ChartPropsLike, colIndex = 0): string[] {
  const cols = props.cols || []
  if (!cols[colIndex]) {
    return []
  }
  const field = cols[colIndex].name
  return (props.data || []).map((row) => String(row[field] ?? ''))
}

export { firstRowValue, decodeMetricName }
