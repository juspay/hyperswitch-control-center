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
    ~title="Smart Routing Configurations",
    ~baseLink="/routing",
    ~breadCrumbCustomStyle=?,
  ) => {
    let breadCrumb =
      <BreadCrumbNavigation
        path=[
          {
            title,
            link: baseLink,
          },
        ]
        currentPageTitle={pageTitle}
      />
    <>
      {switch breadCrumbCustomStyle {
      | Some(className) => <div className> breadCrumb </div>
      | None => breadCrumb
      }}
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
