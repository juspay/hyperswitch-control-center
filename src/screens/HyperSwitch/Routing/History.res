open HistoryEntity
module HistoryTable = {
  @react.component
  let make = (~records, ~activeRoutingIds: array<string>) => {
    let (offset, setOffset) = React.useState(_ => 0)
    <LoadedTable
      title="History"
      hideTitle=true
      actualData=records
      entity={historyEntity(activeRoutingIds)}
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
let make = (~records, ~activeRoutingIds: array<string>) => {
  <HistoryTable records activeRoutingIds />
}
