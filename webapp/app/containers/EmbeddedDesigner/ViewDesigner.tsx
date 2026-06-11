import React from 'react'
import { RouteComponentWithParams } from 'utils/types'
import { parseDesignerQuery } from 'utils/embeddedDesigner'
import ViewEditor from 'containers/View/Editor'

const ViewDesigner: React.FC<RouteComponentWithParams> = (props) => {
  const qs = parseDesignerQuery()
  const projectId = qs.projectId || '1'
  const viewId = qs.viewId || ''
  const sourceId = qs.sourceId || ''
  const match = {
    ...props.match,
    params: {
      projectId,
      viewId: viewId || undefined,
      sourceId: sourceId || undefined
    },
    url: props.match.url,
    path: props.match.path,
    isExact: true
  }
  return <ViewEditor {...props} match={match as any} />
}

export default ViewDesigner
