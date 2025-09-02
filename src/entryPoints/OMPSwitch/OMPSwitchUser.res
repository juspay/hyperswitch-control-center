@react.component
let make = (~children) => {
  open LogicUtils
  open OMPSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let showToast = ToastState.useShowToast()
  let clearUserSwitchParams = () => {
    SessionStorage.sessionStorage.removeItem("switch-user-omp")
    SessionStorage.sessionStorage.removeItem("switch-user-query")
  }
  let getSwitchUserData = (~name) => {
    SessionStorage.sessionStorage.getItem(name)->getValFromNullableValue("")
  }

  let getOMPDetailsFromSessionStore = () => {
    let ompDataFromSession = getSwitchUserData(~name="switch-user-omp")->safeParseOpt
    switch ompDataFromSession {
    | Some(data) => {
        let path =
          getSwitchUserData(~name="switch-user-query")->getDictFromUrlSearchParams->Dict.get("path")
        let data = data->getArrayFromJson([])->Array.map(json => json->JSON.stringify)
        userSwitch(~ompData=data, ~path)
      }
    | None => None
    }
  }

  let getOMPDetailsFromUrl = () => {
    let path = url.search->getDictFromUrlSearchParams->Dict.get("path")
    // condition can be removed once after omp in all the URL
    switch url.path {
    | list{orgId, merchantId, profileId, "switch", "user"} =>
      userSwitch(~ompData=[orgId, merchantId, profileId], ~path)
    | _ => None
    }
  }

  let getSwitchDetails = () => {
    switch getOMPDetailsFromUrl() {
    | Some(data) => Some(data)
    | None => getOMPDetailsFromSessionStore()
    }
  }
  let switchUser = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let details = getSwitchDetails()
      switch details {
      | Some(data) =>
        await internalSwitch(
          ~expectedOrgId=data.orgId,
          ~expectedMerchantId=data.merchantId,
          ~expectedProfileId=data.profileId,
        )
        let url = decodeURIComponent(data.path->Option.getOr(""))
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url))
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
