open LogicUtils

@react.component
let make = () => {
  open HSAnalyticsUtils
  open AlertsTypes
  open AlertsFilters

  let fetchAlerts = AlertsHooks.useAlertsList()
  let fetchDictionary = AlertsHooks.useAlertsDictionary()
  let {filterValueJson, filterValue, updateExistingKeys, reset} = React.useContext(
    FilterContext.filterContext,
  )

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (alertsData, setAlertsData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => 0)

  let (resolvedScreenState, setResolvedScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (resolvedAlerts, setResolvedAlerts) = React.useState(_ => [])
  let (resolvedTotalCount, setResolvedTotalCount) = React.useState(_ => 0)
  let (resolvedOffset, setResolvedOffset) = React.useState(_ => 0)

  let (dictionary, setDictionary) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->AlertsUtils.columnarResponseToDictionary
  )
  let resultsPerPage = 10

  let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=7)
  let startTime = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
  let endTime = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

  let fetchSection = async (~isResolved, ~offset, ~setData, ~setTotalCount, ~setScreenState) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let list = await fetchAlerts(
        ~limit=resultsPerPage,
        ~offset,
        ~startTime,
        ~endTime,
        ~filterValueJson,
        ~isResolved,
        ~onTotalCount=total => setTotalCount(_ => total),
      )

      if list->isNonEmptyArray {
        let padding = Array.make(~length=offset, Dict.make()->AlertsUtils.itemToObjMapper)
        setData(_ => padding->Array.concat(list))
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setData(_ => [])
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | Exn.Error(e) =>
      setScreenState(_ => PageLoaderWrapper.Error(
        Exn.message(e)->Option.getOr("Failed to fetch alerts"),
      ))
    }
  }

  let getAlerts = () =>
    fetchSection(
      ~isResolved=false,
      ~offset,
      ~setData=setAlertsData,
      ~setTotalCount,
      ~setScreenState,
    )

  let getResolvedAlerts = () =>
    fetchSection(
      ~isResolved=true,
      ~offset=resolvedOffset,
      ~setData=setResolvedAlerts,
      ~setTotalCount=setResolvedTotalCount,
      ~setScreenState=setResolvedScreenState,
    )

  let getDictionary = async () => {
    let result = await fetchDictionary()
    setDictionary(_ => result)
  }

  React.useEffect(() => {
    getDictionary()->ignore
    None
  }, [])

  let refresh = () => {
    getAlerts()->ignore
    getResolvedAlerts()->ignore
    getDictionary()->ignore
  }

  React.useEffect(() => {
    getAlerts()->ignore
    None
  }, (offset, filterValue))

  React.useEffect(() => {
    getResolvedAlerts()->ignore
    None
  }, (resolvedOffset, filterValue))

  let customUI = <NoDataFound message="No alerts found" renderType={Painting} />
  let resolvedCustomUI = <NoDataFound message="No resolved alerts found" renderType={Painting} />
  let filters = AlertsFilters.initialFilters(~dictionary)

  <div className="flex flex-col gap-4">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading
        title="Alerts" customHeadingStyle="mb-2" subTitle="Monitoring & Merchant Success alerts"
      />
      <Button
        text="Refresh"
        buttonType=Secondary
        leftIcon={CustomIcon(<Icon name="sync" size=14 />)}
        onClick={_ => refresh()}
      />
    </div>
    <Filter
      key="AlertsFilters"
      title="Alerts"
      defaultFilters={""->JSON.Encode.string}
      fixedFilters={initialFixedFilter()}
      requiredSearchFieldsList=[]
      localFilters=filters
      localOptions=[]
      remoteOptions=[]
      remoteFilters=filters
      autoApply=false
      defaultFilterKeys=[
        startTimeFilterKey,
        endTimeFilterKey,
        priorityFilterKey,
        stateFilterKey,
        merchantIdFilterKey,
        profileIdFilterKey,
        connectorFilterKey,
        paymentMethodFilterKey,
      ]
      updateUrlWith=updateExistingKeys
      clearFilters={() => reset()}
    />
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
    <div className="flex flex-col gap-2 mt-3">
      <div className={`${Typography.heading.sm.semibold} text-nd_gray-800`}>
        {"Resolved Alerts"->React.string}
      </div>
      <PageLoaderWrapper screenState=resolvedScreenState customUI=resolvedCustomUI>
        <LoadedTableWithCustomColumns
          title="ResolvedAlerts"
          hideTitle=true
          actualData={resolvedAlerts->Array.map(Nullable.make)}
          entity=AlertsEntity.alertsEntity
          resultsPerPage
          totalResults=resolvedTotalCount
          offset=resolvedOffset
          setOffset=setResolvedOffset
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
  </div>
}
