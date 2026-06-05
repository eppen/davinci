/*
 * Portal / Project card background images.
 * avatar/pic must be 1-19; default to 1 when empty to avoid require('bg.png').
 */

const MIN_BG_INDEX = 1
const MAX_BG_INDEX = 19

function normalizeBgIndex (value?: string | number | null): string {
  const raw = value == null ? '' : String(value).trim()
  if (!raw) {
    return String(MIN_BG_INDEX)
  }
  const num = Number(raw)
  if (!Number.isFinite(num)) {
    return String(MIN_BG_INDEX)
  }
  const clamped = Math.min(MAX_BG_INDEX, Math.max(MIN_BG_INDEX, Math.floor(num)))
  return String(clamped)
}

export function getVizBackgroundUrl (avatar?: string | number | null): string {
  const index = normalizeBgIndex(avatar)
  return require(`assets/images/bg${index}.png`)
}
