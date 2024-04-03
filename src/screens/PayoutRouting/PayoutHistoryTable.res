open PayoutHistoryTableEntity

@react.component
let make = (~records, ~activeRoutingIds: array<string>) => {
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let (offset, setOffset) = React.useState(_ => 0)

  <LoadedTable
    title="History"
    hideTitle=true
    actualData=records
    entity={payoutHistoryEntity(activeRoutingIds, ~permission=userPermissionJson.workflowsManage)}
    resultsPerPage=10
    showSerialNumber=true
    totalResults={records->Array.length}
    offset
    setOffset
    currrentFetchCount={records->Array.length}
  />
}
