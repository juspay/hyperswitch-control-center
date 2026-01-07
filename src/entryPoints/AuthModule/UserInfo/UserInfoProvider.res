let defaultContext = React.createContext(UserInfoUtils.defaultValueOfUserInfoProvider)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

type userInfoScreenState = Loading | Success | Error
@react.component
let make = (~children, ~isEmbeddableApp=false) => {
  open UserInfoUtils
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (applicationState, setApplicationState) = React.useState(_ => UserInfoTypes.DashboardSession(
    defaultValueOfUserInfo,
  ))

  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    open LogicUtils

    let url = `${Window.env.apiBaseUrl}/user`
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute, ~forceCookies)
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->itemMapperToDashboardUserType
      HyperSwitchEntryUtils.setThemeIdtoStore(userInfo.themeId)
      setApplicationState(_ => DashboardSession(userInfo))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Error)
    }
  }

  /*
   * Use this when the component only needs `userInfo` and will not be used for embeddable users.
   * Returns the set `userInfo` for dashboard users and a default value for embeddable users.
   *
   * Example: recovery codes remaining.
   */
  let getResolvedUserInfo = () =>
    applicationState
    ->getDashboardSession
    ->Option.mapOr(defaultValueOfUserInfo, info => info)

  /*
   * Use this when the component only needs `embeddableInfo` and will not be used for dashboard users.
   * Returns the set `embeddableInfo` for embeddable users and a default value for dashboard users.
   *
   */
  let getResolvedEmbeddableInfo = () =>
    applicationState
    ->getEmbeddableSession
    ->Option.mapOr(defaultValueOfEmbeddedInfo, info => info)

  /*
   * Updates the dashboard user's `userInfo` in the application state.
   *
   * This function only applies to `DashboardSession`. If the current user is an
   * `EmbeddableSession`, the state is returned unchanged.
   */

  let setUpdatedDashboardSessionInfo = (userInfo: UserInfoTypes.userInfo) => {
    setApplicationState(prevState =>
      switch prevState {
      | DashboardSession(_) => DashboardSession(userInfo)
      | EmbeddableSession(_) => prevState
      }
    )
  }

  /*
   * Updates the embeddable user's `emeddableInfo` in the application state.
   *
   * This function only applies to `EmbeddableSession`. If the current user is an
   * `DashboardSession`, the state is returned unchanged.
   */
  let setUpdatedEmbeddableSessionInfo = (userInfo: UserInfoTypes.embeddableInfoType) => {
    setApplicationState(prevState =>
      switch prevState {
      | DashboardSession(_) => prevState
      | EmbeddableSession(_) => EmbeddableSession(userInfo)
      }
    )
  }

  let getCommonSessionDetails: unit => UserInfoTypes.commonInfoType = () => {
    switch applicationState {
    | DashboardSession(dashboardInfo) => {
        orgId: dashboardInfo.orgId,
        merchantId: dashboardInfo.merchantId,
        profileId: dashboardInfo.profileId,
        version: dashboardInfo.version,
      }
    | EmbeddableSession(embeddableInfo) => {
        orgId: embeddableInfo.orgId,
        merchantId: embeddableInfo.merchantId,
        profileId: embeddableInfo.profileId,
        version: embeddableInfo.version,
      }
    }
  }

  let checkUserEntity = (entities: array<UserInfoTypes.entity>) => {
    switch applicationState {
    | DashboardSession(userInfo) => entities->Array.includes(userInfo.userEntity)
    | EmbeddableSession(_) => false
    }
  }

  React.useEffect(() => {
    getUserInfo()->ignore
    None
  }, [])

  <Provider
    value={
      state: applicationState,
      setApplicationState,
      getResolvedUserInfo,
      setUpdatedDashboardSessionInfo,
      getResolvedEmbeddableInfo,
      setUpdatedEmbeddableSessionInfo,
      getCommonSessionDetails,
      checkUserEntity,
    }>
    <RenderIf condition={screenState === Success}> children </RenderIf>
    <RenderIf condition={screenState === Error}>
      <NoDataFound message="Something went wrong" renderType=Painting />
    </RenderIf>
  </Provider>
}
