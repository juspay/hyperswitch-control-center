open PayoutHistoryTableEntity

@react.component
let make = (~records, ~activeRoutingIds: array<string>) => {
  let {userHasAccess} = PermissionHooks.useUserGroupPermissionsHook()
  let (offset, setOffset) = React.useState(_ => 0)

  <LoadedTable
    title="History"
    hideTitle=true
    actualData=records
    entity={payoutHistoryEntity(
      activeRoutingIds,
      ~permission=userHasAccess(~permission=WorkflowsManage),
    )}
    resultsPerPage=10
    showSerialNumber=true
    totalResults={records->Array.length}
    offset
    setOffset
    currrentFetchCount={records->Array.length}
  />
}
