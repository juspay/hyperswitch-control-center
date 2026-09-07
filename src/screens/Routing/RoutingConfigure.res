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
    if isDecisionEngineManaged {
      (
        async () => {
          let cutover = await checkRoutingEntryCutover()
          setCutoverStatus(_ => Some(cutover))

          // Cut-over profiles configure these routing types in the Decision Engine dashboard, so
          // bounce back to the Smart Routing page instead of showing the native form.
          if cutover {
            showToast(
              ~message="This profile's routing is managed by the Decision Engine. Use the Smart Routing page to configure it.",
              ~toastType=ToastState.ToastInfo,
            )
            RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
          }
        }
      )()->ignore
    }
    None
  }, [])

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
      | _ => <> </>
      }}
    </div>
  </PageLoaderWrapper>
}
