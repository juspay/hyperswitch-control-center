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
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let showToast = ToastState.useShowToast()
  let clearUserSwitchParams = () => {
    SessionStorage.sessionStorage.removeItem("switch-user")
  }
  let getUserSwitchQueryParam = () => {
    SessionStorage.sessionStorage.getItem("switch-user")
    ->getValFromNullableValue("")
    ->getDictFromUrlSearchParams
  }
  let getSwitchDetails = () => {
    let urlData = url.search->getDictFromUrlSearchParams
    let sessionData = getUserSwitchQueryParam()

    if urlData->isNonEmptyDict {
      Some(userSwitch(~switchData=urlData, ~defaultValue=userInfo))
    } else if sessionData->isNonEmptyDict {
      Some(userSwitch(~switchData=sessionData, ~defaultValue=userInfo))
    } else {
      None
    }
  }
  let switchUser = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let details = getSwitchDetails()
      switch details {
      | Some(data) => {
          await internalSwitch(
            ~expectedOrgId=Some(data.orgId),
            ~expectedMerchantId=Some(data.merchantId),
            ~expectedProfileId=Some(data.profileId),
          )
          let url = decodeURIComponent(data.path)
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url))
        }
      | None => ()
      }
    } catch {
    | _ => showToast(~message="Failed to switch", ~toastType=ToastError)
    }
    clearUserSwitchParams()
    setScreenState(_ => PageLoaderWrapper.Success)
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
