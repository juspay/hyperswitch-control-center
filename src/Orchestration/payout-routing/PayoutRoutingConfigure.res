@react.component
let make = (~routingType) => {
  open LogicUtils
  open RoutingTypes
  open RoutingUtils

  let url = RescriptReactRouter.useUrl()
  let (currentRouting, setCurrentRouting) = React.useState(() => NO_ROUTING)
  let (id, setId) = React.useState(() => None)
  let (isActive, setIsActive) = React.useState(_ => false)
  let connectorList = ConnectorListInterface.useFilteredConnectorList(~retainInList=PayoutProcessor)

  let baseUrlForRedirection = "/payoutrouting"

  React.useEffect(() => {
    let searchParams = url.search
    let filtersFromUrl = getDictFromUrlSearchParams(searchParams)->Dict.get("id")
    setId(_ => filtersFromUrl)
    switch routingType->String.toLowerCase {
    | "volume" => setCurrentRouting(_ => VOLUME_SPLIT)
    | "rule" => setCurrentRouting(_ => ADVANCED)
    | "default" => setCurrentRouting(_ => DEFAULTFALLBACK)
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
    <History.BreadCrumbWrapper
      pageTitle={getContent(currentRouting).heading} baseLink={"/payoutrouting"}>
      {switch currentRouting {
      | VOLUME_SPLIT =>
        <VolumeSplitRouting
          routingRuleId=id
          isActive
          connectorList
          urlEntityName=V1(PAYOUT_ROUTING)
          baseUrlForRedirection
        />
      | ADVANCED =>
        <AdvancedRouting
          routingRuleId=id
          isActive
          setCurrentRouting
          connectorList
          urlEntityName=V1(PAYOUT_ROUTING)
          baseUrlForRedirection
        />
      | DEFAULTFALLBACK =>
        <DefaultRouting
          urlEntityName=V1(PAYOUT_DEFAULT_FALLBACK)
          baseUrlForRedirection
          connectorVariant=ConnectorTypes.PayoutProcessor
        />
      | _ => React.null
      }}
    </History.BreadCrumbWrapper>
  </div>
}
