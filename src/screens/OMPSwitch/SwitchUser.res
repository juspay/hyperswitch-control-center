type t
type searchParams

// methods
@send external toString: t => string = "toString"

// property access (important: @get, not @send)
@get external searchParams: t => searchParams = "searchParams"

// URLSearchParams methods
@send external append: (searchParams, string, string) => unit = "append"
@send external set: (searchParams, string, string) => unit = "set"
@send external get: (searchParams, string) => string = "get"
@get external href: t => string = "href"
@val external decodeURIComponent: string => string = "decodeURIComponent"

module HandleSwitchUser = {
  let storeQueryParams = (~searchParams) => {
    SessionStorage.sessionStorage.setItem("switch-user", searchParams)
  }
  let handleRedirect = () => {
    let searchParams = SessionStorage.sessionStorage.getItem("switch-user")->Nullable.toOption
    switch searchParams {
    | Some(query) =>
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/switch/user?${query}`))
    | None => ()
    }
  }
  let handleClearParams = () => {
    SessionStorage.sessionStorage.removeItem("switch-user")
  }
  let handleQueryParam = (url: RescriptReactRouter.url) => {
    switch url.path->HSwitchUtils.urlPath {
    | list{"switch", "user"} => storeQueryParams(~searchParams=url.search)
    | _ => ()
    }
  }
}

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let {userInfo} = React.useContext(UserInfoProvider.defaultContext)
  let val = url.search->LogicUtils.getDictFromUrlSearchParams->OMPSwitchUtils.userSwitch(userInfo)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let internalSwitch = if (
    val.orgId != userInfo.orgId ||
    val.merchantId != userInfo.merchantId ||
    val.profileId != userInfo.profileId
  ) {
    OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  } else {
    OMPSwitchHooks.useInternalSwitch()
  }
  let switchUser = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      await internalSwitch(
        ~expectedOrgId=Some(val.orgId),
        ~expectedMerchantId=Some(val.merchantId),
        ~expectedProfileId=Some(val.profileId),
      )
      let url = decodeURIComponent(val.destination)
      setScreenState(_ => PageLoaderWrapper.Success)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url))
    } catch {
    | _ => ()
    }
    HandleSwitchUser.handleClearParams()
  }
  React.useEffect(() => {
    switchUser()->ignore
    None
  }, [])
  <PageLoaderWrapper
    screenState={screenState} sectionHeight="!h-screen w-full" showLogoutButton=true>
    React.null
  </PageLoaderWrapper>
}
