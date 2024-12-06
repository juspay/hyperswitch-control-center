let defaultContext = React.createContext(UserInfoUtils.defaultValueOfUserInfoProvider)

module Provider = {
  let make = React.Context.provider(defaultContext)
}
type userInfoScreenState = Loading | Success | Error
@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (userInfo, setUserInfo) = React.useState(_ => UserInfoUtils.defaultValueOfUserInfo)
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let userInfoRef = Some(React.useRef(userInfo))

  let updateUserInfoRef = updatedUserInfo => {
    switch userInfoRef {
    | Some(ref) => ref.current = updatedUserInfo
    | None => ()
    }
  }

  let userInfoFromRef = switch userInfoRef {
  | Some(ref) => ref.current
  | None => userInfo
  }

  let getUserInfo = async () => {
    open LogicUtils
    let url = `${Window.env.apiBaseUrl}/user`
    try {
      let res = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute)
      let response = await res->(res => res->Fetch.Response.json)
      let userInfo = response->getDictFromJsonObject->UserInfoUtils.itemMapper
      updateUserInfoRef(userInfo)
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
      updateUserInfoRef,
      userInfoFromRef,
      userInfo,
      setUserInfoData,
      getUserInfoData,
      checkUserEntity,
    }>
    <RenderIf condition={screenState === Success}> children </RenderIf>
    <RenderIf condition={screenState === Error}>
      <NoDataFound message="Something went wrong" renderType=Painting />
    </RenderIf>
  </Provider>
}
