open HistoryEntity
open RoutingUtils
module HistoryTable = {
  @react.component
  let make = (
    ~records,
    ~activeRoutingIds: array<string>,
    ~isCutover=false,
    ~onDecisionEngineRedirect=(_, _) => (),
  ) => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let (offset, setOffset) = React.useState(_ => 0)
    let authorization = userHasAccess(~groupAccess=WorkflowsManage)

    let openRecord = (historyData: RoutingTypes.historyData) => {
      let routingType = historyData.kind->routingTypeMapper
      let target = routingType->decisionEngineRoutingTarget
      if target->LogicUtils.isNonEmptyString {
        onDecisionEngineRedirect(target, historyData.id)
      } else {
        // Non-Decision-Engine kinds fall back to the native page, gated by the same access check
        // the table's getShowLink uses.
        let link = GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~authorization,
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/routing/${routingType->routingTypeName}?id=${historyData.id}${activeRoutingIds->Array.includes(
                historyData.id,
              )
                ? "&isActive=true"
                : ""}`,
          ),
        )
        if link->LogicUtils.isNonEmptyString {
          RescriptReactRouter.push(link)
        }
      }
    }

    <LoadedTable
      title="History"
      hideTitle=true
      actualData=records
      entity={historyEntity(activeRoutingIds, ~authorization)}
      resultsPerPage=10
      showSerialNumber=true
      totalResults={records->Array.length}
      offset
      setOffset
      currentFetchCount={records->Array.length}
      onEntityClick=?{isCutover ? Some(openRecord) : None}
    />
  }
}
@react.component
let make = (
  ~records,
  ~activeRoutingIds: array<string>,
  ~isCutover=false,
  ~onDecisionEngineRedirect=(_, _) => (),
) => {
  <div className="mt-8">
    <HistoryTable records activeRoutingIds isCutover onDecisionEngineRedirect />
  </div>
}
