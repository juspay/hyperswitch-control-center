open LogicUtils

@react.component
let make = (~startTime, ~endTime, ~filterValueJson, ~filterValue, ~registerRefetch) => {
  let fetchAlerts = AlertsHooks.useAlertsList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (resolvedAlerts, setResolvedAlerts) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => 0)
  let resultsPerPage = 10

  let getResolvedAlerts = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let list = await fetchAlerts(
        ~limit=resultsPerPage,
        ~offset,
        ~startTime,
        ~endTime,
        ~filterValueJson,
        ~isResolved=true,
        ~onTotalCount=total => setTotalCount(_ => total),
      )

      if list->isNonEmptyArray {
        let padding = Array.make(~length=offset, Dict.make()->AlertsUtils.itemToObjMapper)
        setResolvedAlerts(_ => padding->Array.concat(list))
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setResolvedAlerts(_ => [])
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | Exn.Error(e) =>
      setScreenState(_ => PageLoaderWrapper.Error(
        Exn.message(e)->Option.getOr("Failed to fetch alerts"),
      ))
    }
  }

  React.useEffect(() => {
    getResolvedAlerts()->ignore
    registerRefetch(() => getResolvedAlerts()->ignore)
    None
  }, (offset, filterValue))

  let customUI = <NoDataFound message="No resolved alerts found" renderType={Painting} />

  <div className="flex flex-col gap-2 mt-3">
    <div className={`${Typography.heading.sm.semibold} text-nd_gray-800`}>
      {"Resolved Alerts"->React.string}
    </div>
    <PageLoaderWrapper screenState customUI>
      <LoadedTableWithCustomColumns
        title="ResolvedAlerts"
        hideTitle=true
        actualData={resolvedAlerts->Array.map(Nullable.make)}
        entity=AlertsEntity.alertsEntity
        resultsPerPage
        totalResults=totalCount
        offset
        setOffset
        currentFetchCount={resolvedAlerts->Array.length}
        customColumnMapper=TableAtoms.alertsMapDefaultCols
        defaultColumns={AlertsEntity.defaultColumns}
        showSerialNumber=false
        showSerialNumberInCustomizeColumns=false
        sortingBasedOnDisabled=false
        showAutoScroll=true
        isDraggable=true
        visitedRows={{getId: alert => alert.id, prefix_key: "resolved-alert"}}
      />
    </PageLoaderWrapper>
  </div>
}
