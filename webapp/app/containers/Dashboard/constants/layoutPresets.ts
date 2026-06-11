export interface ILayoutSlot {
  x: number
  y: number
  width: number
  height: number
}

export type SlotPattern = 'repeat-row' | 'repeat-pattern'

export interface ILayoutPreset {
  id: string
  name: string
  description: string
  slots: ILayoutSlot[]
  slotPattern: SlotPattern
  patternHeight?: number
}

export const DEFAULT_LAYOUT_TEMPLATE = 'two-column'

export const LAYOUT_PRESETS: ILayoutPreset[] = [
  {
    id: 'full-stack',
    name: '整行堆叠',
    description: '每个 Widget 独占一行，适合 MES 整页验证与单图大屏',
    slots: [{ x: 0, y: 0, width: 12, height: 10 }],
    slotPattern: 'repeat-row'
  },
  {
    id: 'two-column',
    name: '左右两列',
    description: '每行两个 Widget 并排，适合对比类看板',
    slots: [
      { x: 0, y: 0, width: 6, height: 8 },
      { x: 6, y: 0, width: 6, height: 8 }
    ],
    slotPattern: 'repeat-row'
  },
  {
    id: 'three-column',
    name: '三列均分',
    description: '每行三个 Widget，适合 KPI 指标墙',
    slots: [
      { x: 0, y: 0, width: 4, height: 8 },
      { x: 4, y: 0, width: 4, height: 8 },
      { x: 8, y: 0, width: 4, height: 8 }
    ],
    slotPattern: 'repeat-row'
  },
  {
    id: 'two-over-one',
    name: '上二下一',
    description: '上行两个 Widget，下行一个整行 Widget，适合总览 + 明细',
    slots: [
      { x: 0, y: 0, width: 6, height: 8 },
      { x: 6, y: 0, width: 6, height: 8 },
      { x: 0, y: 8, width: 12, height: 10 }
    ],
    slotPattern: 'repeat-pattern',
    patternHeight: 18
  }
]

export function getLayoutPreset(templateId?: string): ILayoutPreset {
  const preset = LAYOUT_PRESETS.find((p) => p.id === templateId)
  return preset || LAYOUT_PRESETS.find((p) => p.id === DEFAULT_LAYOUT_TEMPLATE)!
}
