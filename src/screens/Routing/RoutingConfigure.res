open RoutingTypes
open RoutingUtils
@react.component
let make = (~routingType) => {
  open LogicUtils
  let baseUrlForRedirection = "/routing"
  let url = RescriptReactRouter.useUrl()
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let (currentRouting, setCurrentRouting) = React.useState(() => NO_ROUTING)
  let (id, setId) = React.useState(() => None)
  let (isActive, setIsActive) = React.useState(_ => false)
  let connectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=ConnectorTypes.PaymentProcessor,
  )
  // These routing types are configured in the Decision Engine dashboard when the
  // profile is cut over, so their native forms must not be reachable there.
  let isDecisionEngineManaged = switch routingType->String.toLowerCase {
  | "volume" | "rule" | "auth-rate" => true
  | _ => false
  }
  let (cutoverStatus, setCutoverStatus) = React.useState(_ =>
    isDecisionEngineManaged ? None : Some(false)
  )

  let checkRoutingEntry = async () => {
    try {
      let entryUrl = getURL(~entityName=V1(ROUTING), ~methodType=Get, ~id=Some("entry"))
      let res = await updateDetails(entryUrl, JSON.Encode.null, Post)
      let cutover = res->getDictFromJsonObject->getBool("is_cutover", false)
      setCutoverStatus(_ => Some(cutover))
    } catch {
    | Exn.Error(_) => setCutoverStatus(_ => Some(false))
    }
  }

  React.useEffect(() => {
    if isDecisionEngineManaged {
      checkRoutingEntry()->ignore
    }
    None
  }, [])

  React.useEffect(() => {
    if isDecisionEngineManaged && cutoverStatus->Option.getOr(false) {
      showToast(
        ~message="This profile's routing is managed by the Decision Engine. Use the Smart Routing page to configure it.",
        ~toastType=ToastState.ToastInfo,
      )
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
    }
    None
  }, [cutoverStatus])

  React.useEffect(() => {
    let searchParams = url.search
    let filtersFromUrl = getDictFromUrlSearchParams(searchParams)->Dict.get("id")
    setId(_ => filtersFromUrl)
    switch routingType->String.toLowerCase {
    | "volume" => setCurrentRouting(_ => VOLUME_SPLIT)
    | "rule" => setCurrentRouting(_ => ADVANCED)
    | "default" => setCurrentRouting(_ => DEFAULTFALLBACK)
    | "auth-rate" => setCurrentRouting(_ => AUTH_RATE_ROUTING)
    | _ => setCurrentRouting(_ => NO_ROUTING)
    }
    let isActive =
      getDictFromUrlSearchParams(searchParams)
      ->Dict.get("isActive")
      ->Option.getOr("")
      ->getBoolFromString(false)
    setIsActive(_ => isActive)
    None
  }, [url.search])

  let screenState = switch cutoverStatus {
  | Some(false) => PageLoaderWrapper.Success
  | _ => PageLoaderWrapper.Loading
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading title="Smart Routing Configurations" customHeadingStyle="!mb-0" />
      <BreadCrumbNavigation
        path=[{title: "Smart Routing Configurations", link: "/routing"}]
        currentPageTitle={getContent(currentRouting).heading}
      />
      {switch currentRouting {
      | VOLUME_SPLIT =>
        <VolumeSplitRouting
          routingRuleId=id isActive connectorList urlEntityName=V1(ROUTING) baseUrlForRedirection
        />
      | ADVANCED =>
        <AdvancedRouting
          routingRuleId=id
          isActive
          setCurrentRouting
          connectorList
          urlEntityName=V1(ROUTING)
          baseUrlForRedirection
        />
      | AUTH_RATE_ROUTING =>
        <AuthRateRouting
          routingRuleId=id isActive connectorList urlEntityName=V1(ROUTING) baseUrlForRedirection
        />
      | DEFAULTFALLBACK =>
        <DefaultRouting
          urlEntityName=V1(DEFAULT_FALLBACK)
          baseUrlForRedirection
          connectorVariant=ConnectorTypes.PaymentProcessor
        />
      | _ => <> </>
      }}
    </div>
  </PageLoaderWrapper>
}
