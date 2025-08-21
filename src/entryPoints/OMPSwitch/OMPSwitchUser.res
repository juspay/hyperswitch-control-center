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

@react.component
let make = (~children) => {
  open LogicUtils
  open OMPSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let {userInfo} = React.useContext(UserInfoProvider.defaultContext)
  // let val = url.search->LogicUtils.getDictFromUrlSearchParams->OMPSwitchUtils.userSwitch(userInfo)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let clearUserSwitchParams = () => {
    SessionStorage.sessionStorage.removeItem("switch-user")
  }
  let getUserSwitchQueryParam = () => {
    SessionStorage.sessionStorage.getItem("switch-user")
    ->getValFromNullableValue("")
    ->safeParse
    ->getDictFromJsonObject
  }
  let getSwitchDetails = () => {
    let urlData = url.search->getDictFromUrlSearchParams
    let sessionData = getUserSwitchQueryParam()

    if urlData->isNonEmptyDict {
      Some(userSwitch(~switchdataFrom=URL(urlData), ~defaultValue=userInfo))
    } else if sessionData->isNonEmptyDict {
      Some(userSwitch(~switchdataFrom=SESSION_STORE(sessionData), ~defaultValue=userInfo))
    } else {
      None
    }
  }
  let switchUser = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let details = getSwitchDetails()
      switch details {
      | Some(data) => {
          await internalSwitch(
            ~expectedOrgId=Some(data.orgId),
            ~expectedMerchantId=Some(data.merchantId),
            ~expectedProfileId=Some(data.profileId),
          )
          let url = decodeURIComponent(data.destination)
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url))
        }
      | None => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
    }
    clearUserSwitchParams()
  }
  React.useEffect(() => {
    switchUser()->ignore
    None
  }, [])
  <PageLoaderWrapper
    screenState={screenState} sectionHeight="!h-screen w-full" showLogoutButton=true>
    children
  </PageLoaderWrapper>
}
