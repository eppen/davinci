export interface DavinciApiOptions {
  baseUrl: string
  token?: string
}

async function request (
  opts: DavinciApiOptions,
  method: string,
  path: string,
  body?: unknown
): Promise<any> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json'
  }
  if (opts.token) {
    headers.Authorization = opts.token.startsWith('Bearer ')
      ? opts.token
      : `Bearer ${opts.token}`
  }
  const res = await fetch(`${opts.baseUrl.replace(/\/$/, '')}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined
  })
  const json = await res.json()
  if (!res.ok) {
    throw new Error(json.message || `HTTP ${res.status}`)
  }
  return json.header || json.payload !== undefined ? json : { payload: json }
}

export const DavinciApi = {
  listSources (projectId: number, opts: DavinciApiOptions) {
    return request(opts, 'GET', `/sources?projectId=${projectId}`)
  },
  getSource (id: number, opts: DavinciApiOptions) {
    return request(opts, 'GET', `/sources/${id}`)
  },
  listViews (projectId: number, opts: DavinciApiOptions) {
    return request(opts, 'GET', `/views?projectId=${projectId}`)
  },
  listWidgets (projectId: number, opts: DavinciApiOptions) {
    return request(opts, 'GET', `/widgets?projectId=${projectId}`)
  },
  getWidget (id: number, opts: DavinciApiOptions) {
    return request(opts, 'GET', `/widgets/${id}`)
  },
  queryWidgetData (id: number, executeParam: object, opts: DavinciApiOptions) {
    return request(opts, 'POST', `/widgets/${id}/data`, executeParam)
  },
  listChartTypes (opts: DavinciApiOptions) {
    return request(opts, 'GET', '/chart-types?enabled=true')
  },
  loginMesToken (mesToken: string, opts: DavinciApiOptions) {
    return request(opts, 'POST', '/login/mes-token', { token: mesToken })
  }
}
