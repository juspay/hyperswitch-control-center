let defaultContext = React.createContext(UserInfoUtils.defaultValueOfUserInfoProvider)

module ErrorPage = {
  @react.component
  let make = () => {
    let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)

    <div className="h-screen gap-4">
      <NoDataFound
        message="Something went wrong"
        renderType=Painting
        customCssClass="h-full"
        customContainerClass="flex flex-col gap-6 h-full "
        customBorderClass="h-full ">
        <div className="flex items-center justify-center h-full gap-8">
          <Button text="Refresh" onClick={_ => Window.Location.reload()} />
          <Button
            text="Logout"
            onClick={_ => {
              let _ = CommonAuthUtils.clearLocalStorage()
              setAuthStateToLogout()
              AuthUtils.redirectToLogin()
            }}
          />
        </div>
      </NoDataFound>
    </div>
  }
}

module Provider = {
  let make = React.Context.provider(defaultContext)
}
type userInfoScreenState = Loading | Success | Error
@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (userInfo, setUserInfo) = React.useState(_ => UserInfoUtils.defaultValueOfUserInfo)
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let getUserInfo = async () => {
    open LogicUtils
    let url = `${Window.env.apiBaseUrl}/user`
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute, ~forceCookies)
      let response = await res->(
        res => {
          // Todo : Handle 500 in AuthHooks api fetcher
          if res->Fetch.Response.status >= 500 {
            Exn.raiseError("Server Error: Unable to fetch user info")
          }
          res->Fetch.Response.json
        }
      )
      let userInfo = response->getDictFromJsonObject->UserInfoUtils.itemMapper
      let themeId = userInfo.themeId
      HyperSwitchEntryUtils.setThemeIdtoStore(themeId)
      setUserInfo(_ => userInfo)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Error)
    }
  }

  let setUserInfoData = userData => {
    setUserInfo(_ => userData)
  }

  let getUserInfoData = () => {
    userInfo
  }

  let checkUserEntity = (entities: array<UserInfoTypes.entity>) => {
    entities->Array.includes(userInfo.userEntity)
  }

  React.useEffect(() => {
    getUserInfo()->ignore
    None
  }, [])

  <Provider
    value={
      userInfo,
      setUserInfoData,
      getUserInfoData,
      checkUserEntity,
    }>
    <RenderIf condition={screenState === Success}> children </RenderIf>
    <RenderIf condition={screenState === Error}>
      <ErrorPage />
    </RenderIf>
  </Provider>
}
