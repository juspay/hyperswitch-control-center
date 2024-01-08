open RoutingTypes
open RoutingUtils
@react.component
let make = (~routingType) => {
  let url = RescriptReactRouter.useUrl()
  let (currentRouting, setCurrentRouting) = React.useState(() => NO_ROUTING)
  let (id, setId) = React.useState(() => None)
  let (isActive, setIsActive) = React.useState(_ => false)

  React.useEffect1(() => {
    let searchParams = url.search
    let filtersFromUrl = LogicUtils.getDictFromUrlSearchParams(searchParams)->Dict.get("id")
    setId(_ => filtersFromUrl)
    switch routingType->String.toLowerCase {
    | "rank" => setCurrentRouting(_ => PRIORITY)
    | "volume" => setCurrentRouting(_ => VOLUME_SPLIT)
    | "rule" => setCurrentRouting(_ => ADVANCED)
    | "default" => setCurrentRouting(_ => DEFAULTFALLBACK)
    | _ => setCurrentRouting(_ => NO_ROUTING)
    }
    let isActive =
      LogicUtils.getDictFromUrlSearchParams(searchParams)
      ->Dict.get("isActive")
      ->Belt.Option.getWithDefault("")
      ->LogicUtils.getBoolFromString(false)
    setIsActive(_ => isActive)
    None
  }, [url.search])

  <div className="flex flex-col overflow-auto gap-2">
    <PageUtils.PageHeading title="Smart routing configuration" />
    <History.BreadCrumbWrapper pageTitle={getContent(currentRouting).heading}>
      {switch currentRouting {
      | PRIORITY => <PriorityRouting routingRuleId=id isActive />
      | VOLUME_SPLIT => <VolumeSplitRouting routingRuleId=id isActive />
      | ADVANCED => <AdvancedRouting routingRuleId=id isActive setCurrentRouting />
      | DEFAULTFALLBACK => <DefaultRouting />
      | _ => <> </>
      }}
    </History.BreadCrumbWrapper>
  </div>
}
