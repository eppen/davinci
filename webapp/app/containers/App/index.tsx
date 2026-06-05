/*
 * <<
 * Davinci
 * ==
 * Copyright (C) 2016 - 2017 EDP
 * ==
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * >>
 */

import React from 'react'
import Helmet from 'react-helmet'
import { connect } from 'react-redux'
import { createStructuredSelector } from 'reselect'
import { Route, HashRouter as Router, Switch, Redirect } from 'react-router-dom'
import { RouteComponentWithParams } from 'utils/types'

import { compose } from 'redux'
import { logged, logout, getServerConfigurations, eosSsoLogin, mesTokenLogin } from './actions'
import injectReducer from 'utils/injectReducer'
import reducer from './reducer'
import injectSaga from 'utils/injectSaga'
import saga from './sagas'

import { makeSelectLogged } from './selectors'

import checkLogin from 'utils/checkLogin'
import { setToken } from 'utils/request'
import { parseSearchParams, stripSsoQueryFromUrl, navigateAfterSso } from 'utils/eosSso'
import { initChartRegistry } from 'utils/chartRegistry'
import { message } from 'antd'
import { statistic } from 'utils/statistic/statistic.dv'
import FindPassword from 'containers/FindPassword'

import { Background } from 'containers/Background/Loadable'
import { Main } from 'containers/Main/Loadable'
import { Activate } from 'containers/Register/Loadable'
import { ChartDesigner, ViewDesigner, SourceDesigner } from 'containers/EmbeddedDesigner/Loadable'

type MappedStates = ReturnType<typeof mapStateToProps>
type MappedDispatches = ReturnType<typeof mapDispatchToProps>
type AppProps = MappedStates & MappedDispatches & RouteComponentWithParams

export class App extends React.PureComponent<AppProps> {

  constructor (props: AppProps) {
    super(props)
    props.onGetServerConfigurations()
    initChartRegistry()
    this.checkTokenLink()
  }

  private checkTokenLink = () => {
    const { history, onEosSsoLogin, onMesTokenLogin } = this.props
    const qs = parseSearchParams()
    const ssoTicket = qs.ssoTicket || qs.usertoken
    const mesToken = qs.mesToken

    if (qs.embedded === '1') {
      localStorage.setItem('embedded', '1')
    }

    if (mesToken) {
      onMesTokenLogin(
        mesToken,
        () => {
          stripSsoQueryFromUrl()
          navigateAfterSso(qs.goto, history)
          statistic.sendPrevDurationRecord()
        },
        () => {
          message.error('MES 免登录失败，请联系管理员')
          this.props.onLogout()
        }
      )
      return
    }

    if (ssoTicket) {
      onEosSsoLogin(
        ssoTicket,
        (loginUser) => {
          stripSsoQueryFromUrl()
          const goto = loginUser.gotoPath || qs.goto
          navigateAfterSso(goto, history)
          statistic.sendPrevDurationRecord()
        },
        () => {
          message.error('EOS 免登录失败，请联系管理员')
          this.props.onLogout()
        }
      )
      return
    }

    this.checkNormalLogin()
  }

  private checkNormalLogin = () => {
    if (checkLogin()) {
      const token = localStorage.getItem('TOKEN')
      const loginUser = localStorage.getItem('loginUser')
      setToken(token)
      this.props.onLogged(JSON.parse(loginUser))
      statistic.sendPrevDurationRecord()
    } else {
      this.props.onLogout()
    }
  }

  private renderRoute = () => {
    const { logged } = this.props

    return (
      logged ? (
        <Redirect to="/projects" />
      ) : (
        <Redirect to="/login" />
      )
    )
  }

  public render () {
    const { logged } = this.props
    if (typeof logged !== 'boolean') { return null }

    return (
      <div>
        <Helmet
          titleTemplate="%s - Davinci"
          defaultTitle="Davinci Web Application"
          meta={[
            {
              name: 'description',
              content: 'Davinci web application built for data visualization'
            }
          ]}
        />
        <Router>
          <Switch>
            <Route path="/activate" component={Activate} />
            <Route path="/joinOrganization" exact component={Background} />
            <Route path="/findPassword" component={FindPassword} />
            <Route path="/chart-designer" component={logged ? ChartDesigner : Background} />
            <Route path="/view-designer" component={logged ? ViewDesigner : Background} />
            <Route path="/source-designer" component={logged ? SourceDesigner : Background} />
            <Route path="/" exact render={this.renderRoute} />
            <Route path="/" component={logged ? Main : Background} />
          </Switch>
        </Router>
      </div>
    )
  }
}

const withReducer = injectReducer({ key: 'global', reducer })
const withSaga = injectSaga({ key: 'global', saga })

const mapStateToProps = createStructuredSelector({
  logged: makeSelectLogged()
})

const mapDispatchToProps = (dispatch) => ({
  onLogged: (user) => dispatch(logged(user)),
  onLogout: () => dispatch(logout()),
  onEosSsoLogin: (ticket, resolve, reject) => dispatch(eosSsoLogin(ticket, resolve, reject)),
  onMesTokenLogin: (token, resolve, reject) => dispatch(mesTokenLogin(token, resolve, reject)),
  onGetServerConfigurations: () => dispatch(getServerConfigurations())
})

const withConnect = connect(
  mapStateToProps,
  mapDispatchToProps
)

export default compose(
  withReducer,
  withSaga,
  withConnect
)(App)
