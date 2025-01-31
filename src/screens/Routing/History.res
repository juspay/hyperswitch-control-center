open HistoryEntity
module HistoryTable = {
  @react.component
  let make = (~records, ~activeRoutingIds: array<string>, ~customTitle=?) => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let (offset, setOffset) = React.useState(_ => 0)

    let title = switch customTitle {
    | Some(value) => value
    | None => " "
    }
    let hideTitle = switch title {
    | " " => true
    | _ => false
    }

    <LoadedTable
      title={title}
      hideTitle={hideTitle}
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
      currrentFetchCount={records->Array.length}
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
let make = (~records, ~activeRoutingIds: array<string>, ~customTitle=?) => {
  <HistoryTable records activeRoutingIds ?customTitle />
}
