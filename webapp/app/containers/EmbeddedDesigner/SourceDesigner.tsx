import React, { useEffect, useState, useCallback } from 'react'
import { connect } from 'react-redux'
import { createStructuredSelector } from 'reselect'
import { compose, Dispatch } from 'redux'
import { RouteComponentWithParams } from 'utils/types'
import injectReducer from 'utils/injectReducer'
import injectSaga from 'utils/injectSaga'
import reducer from 'containers/Source/reducer'
import saga from 'containers/Source/sagas'
import { SourceActions } from 'containers/Source/actions'
import {
  makeSelectFormLoading,
  makeSelectTestLoading,
  makeSelectDatasourcesInfo
} from 'containers/Source/selectors'
import { checkNameUniqueAction } from 'containers/App/actions'
import SourceConfigModal from 'containers/Source/components/SourceConfigModal'
import { parseDesignerQuery, postToMesParent } from 'utils/embeddedDesigner'
import { hideNavigator } from 'containers/App/actions'
import { message } from 'antd'
import request from 'utils/request'
import api from 'utils/api'
import { ISourceFormValues } from 'containers/Source/types'

const styles = require('./EmbeddedDesigner.less')

type SourceDesignerProps = ReturnType<typeof mapStateToProps> &
  ReturnType<typeof mapDispatchToProps> &
  RouteComponentWithParams

const SourceDesigner: React.FC<SourceDesignerProps> = (props) => {
  const qs = parseDesignerQuery()
  const projectId = +(qs.projectId || '1')
  const sourceId = qs.sourceId ? +qs.sourceId : null
  const [visible, setVisible] = useState(true)
  const [source, setSource] = useState<ISourceFormValues>({
    name: '',
    type: (qs.sourceType as 'mes_api' | 'jdbc') || 'mes_api',
    description: '',
    datasourceInfo: [],
    config: {
      url: 'http://127.0.0.1:8080',
      datasetCode: 'output_shift',
      authType: 'bearer',
      bearerToken: '',
      username: '',
      password: '',
      parameters: []
    }
  })

  useEffect(() => {
    props.onHideNavigator()
    props.onLoadDatasourcesInfo()
    if (sourceId) {
      request({ method: 'get', url: `${api.source}/${sourceId}` }).then((res) => {
        const detail = res.payload
        setSource({
          id: detail.id,
          name: detail.name,
          type: detail.type === 'mes_api' ? 'mes_api' : 'jdbc',
          description: detail.description || '',
          datasourceInfo: [],
          config: typeof detail.config === 'string' ? JSON.parse(detail.config) : detail.config
        })
      })
    }
  }, [sourceId])

  const handleSave = useCallback((values) => {
    const payload = {
      ...values,
      projectId,
      config: JSON.stringify(values.config)
    }
    const method = sourceId ? 'put' : 'post'
    const url = sourceId ? `${api.source}/${sourceId}` : api.source
    if (sourceId) {
      payload.id = sourceId
    }
    request({ method, url, data: payload })
      .then((res) => {
        const saved = res.payload || { id: sourceId, ...payload }
        message.success('保存成功')
        postToMesParent('davinci:source-saved', {
          sourceId: saved.id || sourceId,
          projectId,
          name: values.name,
          type: values.type
        })
        setVisible(false)
      })
      .catch((err) => {
        message.error(err.message || '保存失败')
      })
  }, [projectId, sourceId])

  return (
    <div className={styles.embeddedDesigner}>
      <div className={styles.embeddedHeader}>数据连接配置</div>
      <SourceConfigModal
        visible={visible}
        formLoading={props.formLoading}
        testLoading={props.testLoading}
        source={source}
        datasourcesInfo={props.datasourcesInfo}
        onSave={handleSave}
        onClose={() => postToMesParent('davinci:designer-cancel', {})}
        onTestSourceConnection={props.onTestSourceConnection}
        onCheckUniqueName={props.onCheckUniqueName}
        embeddedMesMode
      />
    </div>
  )
}

const mapStateToProps = createStructuredSelector({
  formLoading: makeSelectFormLoading(),
  testLoading: makeSelectTestLoading(),
  datasourcesInfo: makeSelectDatasourcesInfo()
})

const mapDispatchToProps = (dispatch: Dispatch) => ({
  onHideNavigator: () => dispatch(hideNavigator()),
  onLoadDatasourcesInfo: () => dispatch(SourceActions.loadDatasourcesInfo()),
  onTestSourceConnection: (testSource) => dispatch(SourceActions.testSourceConnection(testSource)),
  onCheckUniqueName: (pathname, data, resolve, reject) =>
    dispatch(checkNameUniqueAction(pathname, data, resolve, reject))
})

const withConnect = connect(mapStateToProps, mapDispatchToProps)
const withReducer = injectReducer({ key: 'source', reducer })
const withSaga = injectSaga({ key: 'sourceDesigner', saga })

export default compose(withReducer, withSaga, withConnect)(SourceDesigner)
