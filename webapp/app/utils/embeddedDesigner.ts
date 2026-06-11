export function isEmbeddedDesigner (): boolean {
  if (localStorage.getItem('embedded') === '1') {
    return true
  }
  const hash = window.location.hash || ''
  return hash.indexOf('embedded=1') > -1
}

export function parseDesignerQuery (): Record<string, string> {
  const hash = window.location.hash || ''
  const qIndex = hash.indexOf('?')
  const search = qIndex > -1 ? hash.substring(qIndex + 1) : window.location.search.replace(/^\?/, '')
  const params: Record<string, string> = {}
  if (!search) {
    return params
  }
  search.split('&').forEach((pair) => {
    const [k, v] = pair.split('=')
    if (k) {
      params[decodeURIComponent(k)] = decodeURIComponent(v || '')
    }
  })
  return params
}

export function postToMesParent (type: string, payload: Record<string, unknown>) {
  if (window.parent && window.parent !== window) {
    window.parent.postMessage({ type, ...payload }, '*')
  }
}
