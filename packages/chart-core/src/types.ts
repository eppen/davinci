export interface StyleField {
  key: string
  title: string
  component: 'number' | 'input' | 'select' | 'color' | 'switch'
  default?: string | number | boolean
  options?: Array<{ label: string; value: string | number }>
}

export interface ChartDslMeta {
  code?: string
  optionTemplate?: object | string
  styleSchema?: StyleField[]
  renderer?: string
}

export interface BindingContext {
  style: Record<string, string | number | boolean>
  metrics: Array<{ name: string; value: number | string }>
  cols: Array<{ name: string; value: string }>
  rows: Array<{ name: string; value: string }>
  data: Array<Record<string, unknown>>
}

export interface ChartPropsLike {
  data?: Array<Record<string, unknown>>
  metrics?: Array<{ name: string; agg?: string }>
  cols?: Array<{ name: string }>
  rows?: Array<{ name: string }>
  chartStyles?: {
    dsl?: Record<string, string | number | boolean>
    [key: string]: unknown
  }
  width?: number
  height?: number
}
