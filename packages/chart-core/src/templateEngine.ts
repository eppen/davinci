const PLACEHOLDER_RE = /\{\{([^}]+)\}\}/g

function resolvePath (ctx: Record<string, unknown>, path: string): unknown {
  const parts = path.trim().split('.')
  let current: unknown = ctx
  for (const part of parts) {
    if (current == null) {
      return undefined
    }
    const bracket = part.match(/^(\w+)\[(\d+)\]$/)
    if (bracket) {
      const arr = (current as Record<string, unknown>)[bracket[1]]
      current = Array.isArray(arr) ? arr[parseInt(bracket[2], 10)] : undefined
    } else {
      current = (current as Record<string, unknown>)[part]
    }
  }
  return current
}

function resolvePlaceholder (expr: string, ctx: Record<string, unknown>): unknown {
  const trimmed = expr.trim()
  if (trimmed.startsWith('data[')) {
    return resolvePath(ctx, trimmed)
  }
  return resolvePath(ctx, trimmed)
}

export function bindTemplateValue (
  value: unknown,
  ctx: Record<string, unknown>
): unknown {
  if (typeof value === 'string') {
    if (value.indexOf('{{') === -1) {
      return value
    }
    const fullMatch = value.match(/^\{\{([^}]+)\}\}$/)
    if (fullMatch) {
      const resolved = resolvePlaceholder(fullMatch[1], ctx)
      return resolved !== undefined ? resolved : value
    }
    return value.replace(PLACEHOLDER_RE, (_, inner) => {
      const resolved = resolvePlaceholder(inner, ctx)
      return resolved !== undefined && resolved !== null ? String(resolved) : ''
    })
  }
  if (Array.isArray(value)) {
    return value.map((item) => bindTemplateValue(item, ctx))
  }
  if (value !== null && typeof value === 'object') {
    const out: Record<string, unknown> = {}
    Object.keys(value as Record<string, unknown>).forEach((key) => {
      out[key] = bindTemplateValue((value as Record<string, unknown>)[key], ctx)
    })
    return out
  }
  return value
}

export function bindTemplate (
  template: unknown,
  ctx: Record<string, unknown>
): unknown {
  return bindTemplateValue(template, ctx)
}
