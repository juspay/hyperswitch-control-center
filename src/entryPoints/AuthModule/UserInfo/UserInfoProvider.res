let defaultContext = React.createContext(UserInfoUtils.defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => None)
  let (userInfo, setUserInfo) = React.useState(_ => UserInfoUtils.defaultValue)
  let fetchApi = AuthHooks.useApiFetcher()
  let getUserInfo = async () => {
    open LogicUtils
    let url = `${Window.env.apiBaseUrl}/user`
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ())
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->UserInfoUtils.itemMapper
      setUserInfo(_ => userInfo)
      setScreenState(_ => Some(true))
    } catch {
    | _ => setScreenState(_ => Some(false))
    }
  }

  React.useEffect(() => {
    getUserInfo()->ignore
    None
  }, [])

  <Provider value={userInfo}>
    <RenderIf condition={screenState->Option.isSome && screenState->Option.getOr(false) == true}>
      children
    </RenderIf>
    <RenderIf condition={screenState->Option.isSome && screenState->Option.getOr(true) == false}>
      <NoDataFound message="Something went wrong" renderType=Painting />
    </RenderIf>
  </Provider>
}
