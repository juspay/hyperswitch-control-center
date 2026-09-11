open RoutingTypes
open RoutingUtils
@react.component
let make = (~routingType) => {
  open LogicUtils
  let baseUrlForRedirection = "/routing"
  let url = RescriptReactRouter.useUrl()
  let showToast = ToastAdapter.useShowToast()
  let checkRoutingEntryCutover = useCheckRoutingEntryCutover()
  let (currentRouting, setCurrentRouting) = React.useState(() => NO_ROUTING)
  let (id, setId) = React.useState(() => None)
  let (isActive, setIsActive) = React.useState(_ => false)
  let connectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=ConnectorTypes.PaymentProcessor,
  )
  // Volume / rule / auth-rate are configured in the Decision Engine dashboard when the profile is
  // cut over, so their native forms must not be reachable there — they are exactly the routing
  // types that have a Decision Engine target.
  let isDecisionEngineManaged =
    routingType->routingTypeFromName->decisionEngineRoutingTarget->isNonEmptyString
  let (cutoverStatus, setCutoverStatus) = React.useState(_ =>
    isDecisionEngineManaged ? None : Some(false)
  )

  React.useEffect(() => {
    setCutoverStatus(_ => isDecisionEngineManaged ? None : Some(false))
    if isDecisionEngineManaged {
      let bounceToRouting = () =>
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))

      (
        async () => {
          switch await checkRoutingEntryCutover() {
          | Some(true) =>
            setCutoverStatus(_ => Some(true))
            showToast(
              ~message="This profile's routing is managed by the Decision Engine. Use the Smart Routing page to configure it.",
              ~toastType=ToastState.ToastInfo,
            )
            bounceToRouting()
          | Some(false) => setCutoverStatus(_ => Some(false))
          | None => bounceToRouting()
          }
        }
      )()->ignore
    }
    None
  }, [routingType])

  React.useEffect(() => {
    let searchParams = url.search
    let filtersFromUrl = getDictFromUrlSearchParams(searchParams)->Dict.get("id")
    setId(_ => filtersFromUrl)
    setCurrentRouting(_ => routingType->routingTypeFromName)
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
  | Some(true) | None => PageLoaderWrapper.Loading
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
      | NO_ROUTING => <> </>
      }}
    </div>
  </PageLoaderWrapper>
}
