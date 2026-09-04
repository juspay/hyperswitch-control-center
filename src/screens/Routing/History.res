open HistoryEntity
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

    let openRecord = (historyData: RoutingTypes.historyData) => {
      let routingType = historyData.kind->RoutingUtils.routingTypeMapper
      let target = routingType->RoutingUtils.decisionEngineRoutingTarget
      if target->LogicUtils.isNonEmptyString {
        onDecisionEngineRedirect(target, historyData.id)
      } else {
        RescriptReactRouter.push(
          GlobalVars.appendDashboardPath(
            ~url=`/routing/${routingType->RoutingUtils.routingTypeName}?id=${historyData.id}${activeRoutingIds->Array.includes(
                historyData.id,
              )
                ? "&isActive=true"
                : ""}`,
          ),
        )
      }
    }

    <LoadedTable
      title="History"
      hideTitle=true
      actualData=records
      entity={historyEntity(
        activeRoutingIds,
        ~authorization=userHasAccess(~groupAccess=WorkflowsManage),
      )}
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
