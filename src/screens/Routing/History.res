open HistoryEntity
module HistoryTable = {
  @react.component
  let make = (~records, ~activeRoutingIds: array<string>) => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let (offset, setOffset) = React.useState(_ => 0)

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
    />
  }
}
module BreadCrumbWrapper = {
  @react.component
  let make = (
    ~children,
    ~pageTitle,
    ~title="Smart Routing Configuration",
    ~baseLink="/routing",
  ) => {
    <>
      <BreadCrumbNavigation
        path=[
          {
            title,
            link: baseLink,
          },
        ]
        currentPageTitle={pageTitle}
        cursorStyle="cursor-pointer"
      />
      {children}
    </>
  }
}

@react.component
let make = (~records, ~activeRoutingIds: array<string>) => {
  <div className="mt-8">
    <HistoryTable records activeRoutingIds />
  </div>
}
