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

  let getOMPDetailsFromUrl = (~ompData: array<string>) => {
    let path = url.search->getDictFromUrlSearchParams->Dict.get("path")
    userSwitch(~ompData, ~path)
  }
  let getSwitchDetails = (~ompData: array<string>) => {
    let switchDataFromURL = getOMPDetailsFromUrl(~ompData)
    let switchDataFromSessionStore = getOMPDetailsFromSessionStore()
    if switchDataFromURL->Option.isSome {
      switchDataFromURL
    } else if switchDataFromSessionStore->Option.isSome {
      switchDataFromSessionStore
    } else {
      None
    }
  }
  let switchUser = async (~ompData) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let details = getSwitchDetails(~ompData)
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
    // condition can be removed once after omp in all the URL
    switch url.path->HSwitchUtils.urlPath {
    | list{orgId, merchantId, profileId, "switch", "user"} =>
      switchUser(~ompData=[orgId, merchantId, profileId])->ignore
    | _ => setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [])
  <PageLoaderWrapper
    screenState={screenState} sectionHeight="!h-screen w-full" showLogoutButton=true>
    children
  </PageLoaderWrapper>
}
