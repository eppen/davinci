import { IDashboardItem } from '../types'
import {
  ILayoutPreset,
  ILayoutSlot,
  getLayoutPreset,
  DEFAULT_LAYOUT_TEMPLATE
} from '../constants/layoutPresets'

function getRowHeight(preset: ILayoutPreset): number {
  return Math.max(...preset.slots.map((s) => s.y + s.height))
}

export function getSlotForIndex(preset: ILayoutPreset, index: number): ILayoutSlot {
  if (preset.slotPattern === 'repeat-row') {
    const slotsPerRow = preset.slots.length
    const row = Math.floor(index / slotsPerRow)
    const colInRow = index % slotsPerRow
    const base = preset.slots[colInRow]
    const rowHeight = getRowHeight(preset)
    return {
      x: base.x,
      y: base.y + row * rowHeight,
      width: base.width,
      height: base.height
    }
  }

  const patternLen = preset.slots.length
  const cycle = Math.floor(index / patternLen)
  const slotInPattern = index % patternLen
  const base = preset.slots[slotInPattern]
  const patternHeight = preset.patternHeight || getRowHeight(preset)
  return {
    x: base.x,
    y: base.y + cycle * patternHeight,
    width: base.width,
    height: base.height
  }
}

export function applyLayoutPreset(
  items: IDashboardItem[],
  preset: ILayoutPreset
): IDashboardItem[] {
  const sorted = [...items].sort((a, b) => (a.y === b.y ? a.x - b.x : a.y - b.y))
  return sorted.map((item, index) => {
    const slot = getSlotForIndex(preset, index)
    return {
      ...item,
      x: slot.x,
      y: slot.y,
      width: slot.width,
      height: slot.height
    }
  })
}

export function getNextSlots(
  preset: ILayoutPreset,
  currentItems: IDashboardItem[],
  count: number
): ILayoutSlot[] {
  const startIndex = currentItems.length
  return Array.from({ length: count }, (_, i) => getSlotForIndex(preset, startIndex + i))
}

export function resolveLayoutTemplate(templateId?: string): string {
  return templateId || DEFAULT_LAYOUT_TEMPLATE
}

export function resolveLayoutPreset(templateId?: string): ILayoutPreset {
  return getLayoutPreset(resolveLayoutTemplate(templateId))
}
