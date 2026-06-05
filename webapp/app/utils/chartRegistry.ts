import request from 'utils/request'
import api from 'utils/api'
import localChartlibs from 'containers/Widget/config/chart'
import { IChartInfo } from 'containers/Widget/components/Widget'

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

function assembleFromRemote (
  remote: IRemoteChartType,
  local?: IChartInfo
): IChartInfo | null {
  if (remote.enabled === false) {
    return null
  }
  if (remote.builtin && local) {
    return { ...local, title: remote.title, icon: remote.icon }
  }
  try {
    const dataMeta = JSON.parse(remote.dataSchema || '{}')
    const styleMeta = JSON.parse(remote.configSchema || '{}')
    const hasFullStyle =
      styleMeta &&
      typeof styleMeta === 'object' &&
      Object.keys(styleMeta).length > 0 &&
      (styleMeta.spec !== undefined || styleMeta.bar !== undefined)
    if (hasFullStyle) {
      return {
        id: dataMeta.id || 999,
        name: remote.name,
        title: remote.title,
        icon: remote.icon,
        coordinate: dataMeta.coordinate || 'other',
        rules: dataMeta.rules || [],
        dimetionAxis: dataMeta.dimetionAxis,
        data: dataMeta.data || {},
        style: styleMeta
      } as IChartInfo
    }
    if (local) {
      return { ...local, title: remote.title, icon: remote.icon }
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
        const local = localChartlibs.find((l) => l.name === remote.name)
        const chart = assembleFromRemote(remote, local)
        if (chart) {
          merged.push(chart)
          usedNames.add(remote.name)
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
