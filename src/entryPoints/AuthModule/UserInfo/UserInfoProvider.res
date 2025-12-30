let defaultContext = React.createContext(UserInfoUtils.defaultValueOfUserInfoProvider)

module Provider = {
  let make = React.Context.provider(defaultContext)
}
type userInfoScreenState = Loading | Success | Error
@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (applicationState, setApplicationState) = React.useState(_ => UserInfoTypes.DashboardUser(
    UserInfoUtils.defaultValueOfUserInfo,
  ))

  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    open LogicUtils
    open UserInfoUtils
    let url = `${Window.env.apiBaseUrl}/user`
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute, ~forceCookies)
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->itemMapperToDashboardUserType
      HyperSwitchEntryUtils.setThemeIdtoStore(userInfo.themeId)
      setApplicationState(_ => DashboardUser(userInfo))
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
  let getResolvedUserInfo = () => {
    switch applicationState {
    | DashboardUser(info) => info
    | EmbeddableUser(_) => UserInfoUtils.defaultValueOfUserInfo // Return default for embeddable user
    }
  }

  /*
   * Use this when the component only needs `embeddableInfo` and will not be used for dashboard users.
   * Returns the set `embeddableInfo` for embeddable users and a default value for dashboard users.
   *
   */
  let getResolvedEmbeddableInfo = () => {
    switch applicationState {
    | DashboardUser(_) => UserInfoUtils.defaultValueOfEmbeddedInfo
    | EmbeddableUser(info) => info // Return default for embeddable user
    }
  }

  /*
   * Updates the dashboard user's `userInfo` in the application state.
   *
   * This function only applies to `DashboardUser`. If the current user is an
   * `EmbeddableUser`, the state is returned unchanged.
   */
  let setUpdatedDashboardUserInfo = (userInfo: UserInfoTypes.userInfo) => {
    setApplicationState(prevState =>
      switch prevState {
      | DashboardUser(_) => DashboardUser(userInfo)
      | EmbeddableUser(_) => prevState
      }
    )
  }

  /*
   * Updates the embeddable user's `emeddableInfo` in the application state.
   *
   * This function only applies to `EmbeddableUser`. If the current user is an
   * `DashboardUser`, the state is returned unchanged.
   */
  let setUpdatedEmbeddableInfo = (userInfo: UserInfoTypes.embeddableInfoType) => {
    setApplicationState(prevState =>
      switch prevState {
      | DashboardUser(_) => prevState
      | EmbeddableUser(_) => EmbeddableUser(userInfo)
      }
    )
  }

  let getCommonDetails: unit => UserInfoTypes.commonInfoType = () => {
    switch applicationState {
    | DashboardUser(dashboardInfo) => {
        orgId: dashboardInfo.orgId,
        merchantId: dashboardInfo.merchantId,
        profileId: dashboardInfo.profileId,
        version: dashboardInfo.version,
      }
    | EmbeddableUser(embeddableInfo) => {
        orgId: embeddableInfo.orgId,
        merchantId: embeddableInfo.merchantId,
        profileId: embeddableInfo.profileId,
        version: embeddableInfo.version,
      }
    }
  }

  let checkUserEntity = (entities: array<UserInfoTypes.entity>) => {
    switch applicationState {
    | EmbeddableUser(_) => false
    | DashboardUser(userInfo) => entities->Array.includes(userInfo.userEntity)
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
      setUpdatedDashboardUserInfo,
      getResolvedEmbeddableInfo,
      setUpdatedEmbeddableInfo,
      getCommonDetails,
      checkUserEntity,
    }>
    <RenderIf condition={screenState === Success}> children </RenderIf>
    <RenderIf condition={screenState === Error}>
      <NoDataFound message="Something went wrong" renderType=Painting />
    </RenderIf>
  </Provider>
}
