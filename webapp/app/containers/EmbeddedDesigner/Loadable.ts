import loadable from 'utils/loadable'

export const ChartDesigner = loadable(() => import('./ChartDesigner'), {
  fallback: null
})
export const ViewDesigner = loadable(() => import('./ViewDesigner'), {
  fallback: null
})
export const SourceDesigner = loadable(() => import('./SourceDesigner'), {
  fallback: null
})
