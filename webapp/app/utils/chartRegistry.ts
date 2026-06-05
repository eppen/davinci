import request from 'utils/request'
import api from 'utils/api'
import localChartlibs from 'containers/Widget/config/chart'
import { IChartInfo, IChartStyleField } from 'containers/Widget/components/Widget'

interface IRemoteChartType {
  code: string
  name: string
  title: string
  icon: string
  category: string
  renderer: string
  configSchema: string
  dataSchema: string
  optionTemplate?: string
  version: number
  builtin: boolean
  enabled: boolean
}

let chartLibsCache: IChartInfo[] | null = null
let initPromise: Promise<IChartInfo[]> | null = null

function buildDslDefaults (styleSchema: IChartStyleField[]): Record<string, string | number | boolean> {
  const dsl: Record<string, string | number | boolean> = {}
  styleSchema.forEach((field) => {
    if (field.default !== undefined) {
      dsl[field.key] = field.default
    }
  })
  return dsl
}

function parseStyleSchema (styleMeta: unknown): IChartStyleField[] | null {
  if (Array.isArray(styleMeta)) {
    return styleMeta as IChartStyleField[]
  }
  if (styleMeta && typeof styleMeta === 'object' && Array.isArray((styleMeta as { styleSchema?: unknown }).styleSchema)) {
    return (styleMeta as { styleSchema: IChartStyleField[] }).styleSchema
  }
  return null
}

function assembleFromRemote (
  remote: IRemoteChartType,
  local?: IChartInfo
): IChartInfo | null {
  if (remote.enabled === false) {
    return null
  }

  let optionTemplate: object | string | undefined
  if (remote.optionTemplate) {
    try {
      optionTemplate = JSON.parse(remote.optionTemplate)
    } catch (e) {
      optionTemplate = remote.optionTemplate
    }
  }

  const isDslChart = remote.renderer === 'echarts' && !!optionTemplate
  const isMesTable = remote.category === 'mes' && remote.renderer === 'table'

  if (remote.builtin && local && !isDslChart && !isMesTable) {
    return { ...local, title: remote.title, icon: remote.icon, code: remote.code }
  }

  try {
    const dataMeta = JSON.parse(remote.dataSchema || '{}')
    const styleMetaRaw = JSON.parse(remote.configSchema || '{}')
    const styleSchema = parseStyleSchema(styleMetaRaw)

    if (isMesTable) {
      const tableLocal = localChartlibs.find((l) => l.name === 'table')
      return {
        id: dataMeta.id || 1,
        code: remote.code,
        name: remote.name,
        title: remote.title,
        icon: remote.icon,
        coordinate: dataMeta.coordinate || 'other',
        rules: dataMeta.rules || [],
        data: dataMeta.data || {},
        style: tableLocal ? tableLocal.style : {}
      } as IChartInfo
    }

    if (isDslChart && styleSchema) {
      return {
        id: dataMeta.id || 900 + remote.code.length,
        code: remote.code,
        name: remote.name,
        title: remote.title,
        icon: remote.icon,
        coordinate: dataMeta.coordinate || 'other',
        rules: dataMeta.rules || [],
        dimetionAxis: dataMeta.dimetionAxis,
        data: dataMeta.data || {},
        style: { dsl: buildDslDefaults(styleSchema) },
        styleSchema,
        optionTemplate,
        isDsl: true
      } as IChartInfo
    }

    const styleMeta = styleMetaRaw
    const hasFullStyle =
      styleMeta &&
      typeof styleMeta === 'object' &&
      !Array.isArray(styleMeta) &&
      Object.keys(styleMeta).length > 0 &&
      (styleMeta.spec !== undefined || styleMeta.bar !== undefined)

    if (hasFullStyle) {
      return {
        id: dataMeta.id || 999,
        code: remote.code,
        name: remote.name,
        title: remote.title,
        icon: remote.icon,
        coordinate: dataMeta.coordinate || 'other',
        rules: dataMeta.rules || [],
        dimetionAxis: dataMeta.dimetionAxis,
        data: dataMeta.data || {},
        style: styleMeta,
        optionTemplate
      } as IChartInfo
    }

    if (local) {
      return { ...local, title: remote.title, icon: remote.icon, code: remote.code, optionTemplate }
    }
    return null
  } catch (e) {
    return local || null
  }
}

export async function initChartRegistry (): Promise<IChartInfo[]> {
  if (chartLibsCache) {
    return chartLibsCache
  }
  if (initPromise) {
    return initPromise
  }
  initPromise = (async () => {
    try {
      const asyncData = await request({
        method: 'get',
        url: `${api.chartTypes}?enabled=true`
      })
      const remotes: IRemoteChartType[] = asyncData.payload || []
      const merged: IChartInfo[] = []
      const usedNames = new Set<string>()
      remotes.forEach((remote) => {
        const local = localChartlibs.find(
          (l) => l.name === remote.name || l.code === remote.code
        )
        const chart = assembleFromRemote(remote, local)
        if (chart) {
          merged.push(chart)
          usedNames.add(chart.name)
        }
      })
      localChartlibs.forEach((local) => {
        if (!usedNames.has(local.name)) {
          merged.push(local)
        }
      })
      chartLibsCache = merged.length ? merged : [...localChartlibs]
    } catch (e) {
      chartLibsCache = [...localChartlibs]
    }
    return chartLibsCache
  })()
  return initPromise
}

export function getChartLibs (): IChartInfo[] {
  return chartLibsCache || localChartlibs
}

export function getChartByCode (code: string): IChartInfo | undefined {
  return getChartLibs().find((c) => c.code === code)
}
