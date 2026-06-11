import { ChartPropsLike } from './types'

export interface TableColumn {
  title: string
  dataIndex: string
  key: string
}

export interface TableRenderResult {
  columns: TableColumn[]
  dataSource: Array<Record<string, unknown>>
  pagination: {
    pageNo: number
    pageSize: number
    totalCount: number
  }
}

export function renderDslTable (props: ChartPropsLike): TableRenderResult {
  const data = props.data || []
  const fields = [
    ...(props.cols || []).map((c) => c.name),
    ...(props.rows || []).map((r) => r.name),
    ...(props.metrics || []).map((m) => m.name)
  ]
  const uniqueFields = Array.from(new Set(fields))
  const columns = uniqueFields.map((field) => ({
    title: field,
    dataIndex: field,
    key: field
  }))
  const pagination = (props as { pagination?: { pageNo: number; pageSize: number; totalCount: number } }).pagination
  return {
    columns,
    dataSource: data,
    pagination: pagination || {
      pageNo: 1,
      pageSize: data.length || 20,
      totalCount: data.length
    }
  }
}
