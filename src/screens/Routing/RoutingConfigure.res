open RoutingTypes
open RoutingUtils
@react.component
let make = (~routingType) => {
  open LogicUtils
  let baseUrlForRedirection = "/routing"
  let url = RescriptReactRouter.useUrl()
  let (currentRouting, setCurrentRouting) = React.useState(() => NO_ROUTING)
  let (id, setId) = React.useState(() => None)
  let (isActive, setIsActive) = React.useState(_ => false)
  let connectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=ConnectorTypes.PaymentProcessor,
  )

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

  <div className="flex flex-col overflow-auto gap-2">
    <PageUtils.PageHeading title="Smart routing configuration" />
    <History.BreadCrumbWrapper pageTitle={getContent(currentRouting).heading} baseLink={"/routing"}>
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
    </History.BreadCrumbWrapper>
  </div>
}
