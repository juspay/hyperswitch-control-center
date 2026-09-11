open HistoryEntity
open RoutingUtils
open LogicUtils
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
      if target->isNonEmptyString {
        onDecisionEngineRedirect(target, historyData.id)
      } else {
        let link = GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~authorization,
          ~url=historyRecordNativeUrl(
            ~kind=historyData.kind,
            ~id=historyData.id,
            ~activeRoutingIds,
          ),
        )
        if link->isNonEmptyString {
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
