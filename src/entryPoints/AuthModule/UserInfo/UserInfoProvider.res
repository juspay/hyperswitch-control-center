let defaultContext = React.createContext(UserInfoUtils.defaultValueOfUserInfoProvider)

module Provider = {
  let make = React.Context.provider(defaultContext)
}
type userInfoScreenState = Loading | Success | Error
@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (applicationState, setApplicationState) = React.useState(_ =>
    UserInfoUtils.defaultApplicationState
  )

  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    open LogicUtils
    let url = `${Window.env.apiBaseUrl}/user`
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute, ~forceCookies)
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo =
        response->getDictFromJsonObject->UserInfoUtils.convertValueToDashboardApplicationState

      let themeId = switch userInfo.details {
      | DashboardUser(info) => info.themeId
      | EmbeddableUser => ""
      }
      HyperSwitchEntryUtils.setThemeIdtoStore(themeId)
      setApplicationState(_ => userInfo)
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
  let resolvedUserInfo = {
    switch applicationState.details {
    | DashboardUser(info) => info
    | EmbeddableUser => UserInfoUtils.defaultValueOfUserInfo // Return default for embeddable user
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
      switch prevState.details {
      | DashboardUser(_) => {
          commonInfo: {
            orgId: userInfo.orgId,
            merchantId: userInfo.merchantId,
            profileId: userInfo.profileId,
            version: userInfo.version,
          },
          details: DashboardUser(userInfo),
        }
      | EmbeddableUser => prevState
      }
    )
  }

  let checkUserEntity = (entities: array<UserInfoTypes.entity>) => {
    switch applicationState.details {
    | EmbeddableUser => false
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
      setUpdatedDashboardUserInfo,
      setApplicationState,
      resolvedUserInfo,
      checkUserEntity,
    }>
    <RenderIf condition={screenState === Success}> children </RenderIf>
    <RenderIf condition={screenState === Error}>
      <NoDataFound message="Something went wrong" renderType=Painting />
    </RenderIf>
  </Provider>
}
