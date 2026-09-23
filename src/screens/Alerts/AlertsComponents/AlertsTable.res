open LogicUtils

@react.component
let make = (~startTime, ~endTime, ~filterValueJson, ~filterValue, ~registerRefetch) => {
  let fetchAlerts = AlertsHooks.useAlertsList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (alertsData, setAlertsData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => 0)
  let resultsPerPage = 10

  let getAlerts = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let list = await fetchAlerts(
        ~limit=resultsPerPage,
        ~offset,
        ~startTime,
        ~endTime,
        ~filterValueJson,
        ~isResolved=false,
        ~onTotalCount=total => setTotalCount(_ => total),
      )

      if list->isEmptyArray && offset > 0 {
        setOffset(_ => 0)
      } else if list->isNonEmptyArray {
        let padding = Array.make(~length=offset, Dict.make()->AlertsUtils.itemToObjMapper)
        setAlertsData(_ => padding->Array.concat(list))
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setAlertsData(_ => [])
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
    getAlerts()->ignore
    registerRefetch(() => getAlerts()->ignore)
    None
  }, (offset, filterValue))

  let customUI = <NoDataFound message="No alerts found" renderType={Painting} />

  <PageLoaderWrapper screenState customUI>
    <LoadedTableWithCustomColumns
      title="Alerts"
      hideTitle=true
      actualData={alertsData->Array.map(Nullable.make)}
      entity=AlertsEntity.alertsEntity
      resultsPerPage
      totalResults=totalCount
      offset
      setOffset
      currentFetchCount={alertsData->Array.length}
      customColumnMapper=TableAtoms.alertsMapDefaultCols
      defaultColumns={AlertsEntity.defaultColumns}
      showSerialNumber=false
      showSerialNumberInCustomizeColumns=false
      sortingBasedOnDisabled=false
      showAutoScroll=true
      isDraggable=true
      visitedRows={{getId: alert => alert.id, prefix_key: "alert"}}
    />
  </PageLoaderWrapper>
}
