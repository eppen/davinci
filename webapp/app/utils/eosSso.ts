/*
 * EOS integration gateway: post-login navigation inside iframe.
 */

export function parseSearchParams (): Record<string, string> {
  const search = window.location.search
  if (!search || search.length < 2) {
    return {}
  }
  const params: Record<string, string> = {}
  const qs = search.charAt(0) === '?' ? search.substring(1) : search
  qs.split('&').forEach((pair) => {
    const idx = pair.indexOf('=')
    if (idx > 0) {
      const key = decodeURIComponent(pair.substring(0, idx))
      const val = decodeURIComponent(pair.substring(idx + 1))
      params[key] = val
    } else if (pair) {
      params[decodeURIComponent(pair)] = ''
    }
  })
  return params
}

export function stripSsoQueryFromUrl (): void {
  const params = parseSearchParams()
  if (!params.ssoTicket && !params.mesToken && !params.goto && params.embedded === undefined) {
    return
  }
  delete params.ssoTicket
  delete params.mesToken
  delete params.goto
  delete params.embedded
  const keys = Object.keys(params)
  const newSearch = keys.length
    ? '?' + keys.map((k) => `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`).join('&')
    : ''
  const newUrl = `${window.location.pathname}${newSearch}${window.location.hash}`
  window.history.replaceState(null, '', newUrl)
}

/**
 * Navigate after SSO. Handles share.html entry and hash routes.
 */
export function navigateAfterSso (gotoPath: string | undefined, history: { replace: (path: string) => void }): void {
  const goto = (gotoPath || '/#/projects').trim()

  if (goto.indexOf('/share.html') === 0) {
    const hashIdx = goto.indexOf('#')
    const path = hashIdx >= 0 ? goto.substring(0, hashIdx) : goto
    const hash = hashIdx >= 0 ? goto.substring(hashIdx) : ''
    window.location.replace(`${path}${hash}`)
    return
  }

  let route = goto
  if (route.indexOf('#/') === 0) {
    route = route.substring(1)
  } else if (route.indexOf('/#/') === 0) {
    route = route.substring(2)
  } else if (route.charAt(0) === '/') {
    route = route.substring(1)
  }
  if (!route) {
    route = 'projects'
  }
  history.replace(route.startsWith('/') ? route : `/${route}`)
}
