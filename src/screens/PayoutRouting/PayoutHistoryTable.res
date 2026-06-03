open PayoutHistoryTableEntity

@react.component
let make = (~records, ~activeRoutingIds: array<string>) => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (offset, setOffset) = React.useState(_ => 0)

  <LoadedTable
    title="History"
    hideTitle=true
    actualData=records
    entity={payoutHistoryEntity(
      activeRoutingIds,
      ~authorization=userHasAccess(~groupAccess=WorkflowsManage),
    )}
    resultsPerPage=10
    showSerialNumber=true
    totalResults={records->Array.length}
    offset
    setOffset
    currentFetchCount={records->Array.length}
  />
}
