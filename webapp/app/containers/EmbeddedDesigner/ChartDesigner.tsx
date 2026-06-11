import React from 'react'
import { RouteComponentWithParams } from 'utils/types'
import { parseDesignerQuery } from 'utils/embeddedDesigner'
import Workbench from 'containers/Widget/components/Workbench'

const ChartDesigner: React.FC<RouteComponentWithParams> = (props) => {
  const qs = parseDesignerQuery()
  const projectId = qs.projectId || '1'
  const widgetId = qs.widgetId || 'add'
  const match = {
    ...props.match,
    params: {
      projectId,
      widgetId
    },
    url: props.match.url,
    path: props.match.path,
    isExact: true
  }
  return <Workbench {...props} match={match as any} />
}

export default ChartDesigner
