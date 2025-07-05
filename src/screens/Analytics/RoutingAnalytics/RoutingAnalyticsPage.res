open APIUtils
open LogicUtils
open RoutingAnalyticsEntity

@react.component
let make = () => {
  // API Hooks
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  // Filter Management
  let {filterValue, filterValueJson, updateExistingKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let defaultFilters = [HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]
  let filterKeys = ["payment_method", "payment_method_type", "routing_approach"]

  // State Management
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (_metrics, setMetrics) = React.useState(_ => [])
  let (_dimensions, setDimensions) = React.useState(_ => [])
  let (_summaryData, setSummaryData) = React.useState(_ => None)
  let (_distributionData, setDistributionData) = React.useState(_ => [])
  let (_tableData, setTableData) = React.useState(_ => [])
  let (_timeSeriesData, setTimeSeriesData) = React.useState(_ => [])
  let (filterDataJson, setFilterDataJson) = React.useState(_ => None)

  // Filter Context Values
  let startTimeVal = filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, "")
  let endTimeVal = filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, "")
  let paymentMethodVal = filterValueJson->getString("payment_method", "")
  let paymentMethodTypeVal = filterValueJson->getString("payment_method_type", "")
  let routingApproachVal = filterValueJson->getString("routing_approach", "")

  // Module name for filter prefixing
  let moduleName = "RoutingAnalytics"

  // Domain constant
  let domain = "routing"

  // Initial Filters Setup
  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey=HSAnalyticsUtils.startTimeFilterKey,
    ~endTimeFilterKey=HSAnalyticsUtils.endTimeFilterKey,
    ~origin="analytics",
    (),
  )

  // Mixpanel event for date filter
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="routing_analytics_date_filter_opened")
  }

  // Filter data fallback
  let filterData = filterDataJson->Option.getOr(Dict.make()->JSON.Encode.object)

  // URL Update Utility - temporarily unused but kept for future implementation
  let _updateUrlWithPrefix = React.useMemo(() => {
    (chartType: string) => {
      (dict: Dict.t<string>) => {
        let prev = filterValue
        let prevDictArr =
          prev
          ->Dict.toArray
          ->Belt.Array.keepMap(item => {
            let (key, _) = item
            switch dict->Dict.get(key) {
            | Some(_) => None
            | None => Some(item)
            }
          })
        let currentDict =
          dict
          ->Dict.toArray
          ->Belt.Array.keepMap(item => {
            let (key, value) = item
            if value->isNonEmptyString {
              Some((`${moduleName}${chartType}.${key}`, value))
            } else {
              None
            }
          })
        updateExistingKeys(Array.concat(prevDictArr, currentDict)->Dict.fromArray)
      }
    }
  }, [updateExistingKeys])

  // Single Stat Entity
  let singleStatEntity = React.useMemo(() => {
    let uri = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Post, ~id=Some(domain))
    routingSingleStatEntity(~uri)
  }, [])

  // Chart entities for distribution charts
  let volumeDistributionEntity = React.useMemo(() => {
    let uri = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Post, ~id=Some(domain))
    volumeDistributionChartEntity(filterKeys, uri)
  }, [])

  let routingLogicDistributionEntity = React.useMemo(() => {
    let uri = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Post, ~id=Some(domain))
    routingLogicDistributionChartEntity(filterKeys, uri)
  }, [])

  // Time series chart entities
  let successOverTimeEntity = React.useMemo(() => {
    let uri = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Post, ~id=Some(domain))
    successOverTimeChartEntity(filterKeys, uri)
  }, [])

  let volumeOverTimeEntity = React.useMemo(() => {
    let uri = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Post, ~id=Some(domain))
    volumeOverTimeChartEntity(filterKeys, uri)
  }, [])

  // Table entity for summary table
  let tableEntity = React.useMemo(() => {
    let uri = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Post, ~id=Some(domain))
    routingTableEntityForLoadedTable(~uri)
  }, [])

  // Filter Body for API Requests
  let filterBody = React.useMemo(() => {
    let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
      startTime: startTimeVal,
      endTime: endTimeVal,
      groupByNames: ["routing_approach"],
      source: "BATCH",
    }
    AnalyticsUtils.filterBody(filterBodyEntity)
  }, (startTimeVal, endTimeVal))

  // Filter URL for fetching filter options
  let filterUrl = getURL(~entityName=V1(ANALYTICS_FILTERS), ~methodType=Post, ~id=Some(domain))

  // Load initial info (metrics and dimensions)
  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=V1(ANALYTICS_ROUTING_V1), ~methodType=Get, ~id=Some(domain))
      let infoDetails = await fetchDetails(infoUrl)
      let metricsData = infoDetails->getDictFromJsonObject->getArrayFromDict("metrics", [])
      let dimensionsData = infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", [])

      setMetrics(_ => metricsData)
      setDimensions(_ => dimensionsData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  // Fetch filter data
  let fetchFilterData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      try {
        let response = await updateDetails(filterUrl, filterBody->JSON.Encode.object, Post)
        setFilterDataJson(_ => Some(response))
      } catch {
      | _ => () // Handle error silently for now
      }
    }
  }

  // Fetch summary stats data
  let fetchSummaryData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      try {
        let summaryUrl = getURL(
          ~entityName=V1(ANALYTICS_ROUTING_V1),
          ~methodType=Post,
          ~id=Some(domain),
        )
        let summaryMetrics = [
          "payment_success_rate",
          "payment_count",
          "payment_success_count",
          "payment_processed_amount",
        ]
        let body = AnalyticsUtils.getFilterRequestBody(
          ~startDateTime=startTimeVal,
          ~endDateTime=endTimeVal,
          ~metrics=Some(summaryMetrics),
          ~source="BATCH",
        )
        let response = await updateDetails(
          summaryUrl,
          [body->JSON.Encode.object]->JSON.Encode.array,
          Post,
        )
        let queryData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

        if queryData->Array.length > 0 {
          // Process summary data here
          setSummaryData(_ => Some(queryData))
        }
      } catch {
      | _ => () // Handle error silently for now
      }
    }
  }

  // Fetch distribution data for donut charts
  let fetchDistributionData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      try {
        let distributionUrl = getURL(
          ~entityName=V1(ANALYTICS_ROUTING_V1),
          ~methodType=Post,
          ~id=Some(domain),
        )
        let body = AnalyticsUtils.getFilterRequestBody(
          ~startDateTime=startTimeVal,
          ~endDateTime=endTimeVal,
          ~metrics=Some(["payment_count"]),
          ~groupByNames=Some(["routing_approach"]),
          ~source="BATCH",
        )
        let response = await updateDetails(
          distributionUrl,
          [body->JSON.Encode.object]->JSON.Encode.array,
          Post,
        )
        let queryData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

        setDistributionData(_ => queryData)
      } catch {
      | _ => () // Handle error silently for now
      }
    }
  }

  // Fetch table data
  let fetchTableData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      try {
        let tableUrl = getURL(
          ~entityName=V1(ANALYTICS_ROUTING_V1),
          ~methodType=Post,
          ~id=Some(domain),
        )
        let tableMetrics = ["payment_count", "payment_success_rate", "payment_processed_amount"]
        let body = AnalyticsUtils.getFilterRequestBody(
          ~startDateTime=startTimeVal,
          ~endDateTime=endTimeVal,
          ~metrics=Some(tableMetrics),
          ~groupByNames=Some(["routing_approach"]),
          ~source="BATCH",
        )
        let response = await updateDetails(
          tableUrl,
          [body->JSON.Encode.object]->JSON.Encode.array,
          Post,
        )
        let queryData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

        setTableData(_ => queryData)
      } catch {
      | _ => () // Handle error silently for now
      }
    }
  }

  // Fetch time series data
  let fetchTimeSeriesData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      try {
        let timeSeriesUrl = getURL(
          ~entityName=V1(ANALYTICS_ROUTING_V1),
          ~methodType=Post,
          ~id=Some(domain),
        )
        let body = AnalyticsUtils.getFilterRequestBody(
          ~startDateTime=startTimeVal,
          ~endDateTime=endTimeVal,
          ~metrics=Some(["payment_success_rate", "payment_count"]),
          ~groupByNames=Some(["routing_approach"]),
          ~granularity=Some("G_ONEDAY"),
          ~source="BATCH",
        )
        let response = await updateDetails(
          timeSeriesUrl,
          [body->JSON.Encode.object]->JSON.Encode.array,
          Post,
        )
        let queryData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

        setTimeSeriesData(_ => queryData)
      } catch {
      | _ => () // Handle error silently for now
      }
    }
  }

  // Initialize filters on mount
  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  // Initialize data on mount
  React.useEffect(() => {
    loadInfo()->ignore
    None
  }, [])

  // Fetch filter data when time range changes
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      fetchFilterData()->ignore
    }
    None
  }, [startTimeVal, endTimeVal])

  // Fetch analytics data when filters change
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      fetchSummaryData()->ignore
      fetchDistributionData()->ignore
      fetchTableData()->ignore
      fetchTimeSeriesData()->ignore
    }
    None
  }, [startTimeVal, endTimeVal, paymentMethodVal, paymentMethodTypeVal, routingApproachVal])

  <PageLoaderWrapper screenState>
    <div className="routing-analytics-page">
      <PageUtils.PageHeading
        title="Routing Analytics"
        subTitle="Analyze routing performance and success rates across different routing approaches"
      />
      /* Filter Bar */
      <div className="filter-bar mb-4">
        <div className="flex flex-row">
          <DynamicFilter
            title="RoutingAnalytics"
            initialFilters={switch filterDataJson {
            | Some(_filterData) => []
            | None => []
            }}
            options=[]
            popupFilterFields={switch filterDataJson {
            | Some(_filterData) => []
            | None => []
            }}
            initialFixedFilters={RoutingAnalyticsEntity.initialFixedFilterFields(
              filterData,
              ~events=dateDropDownTriggerMixpanelCallback,
            )}
            defaultFilterKeys=defaultFilters
            tabNames=filterKeys
            updateUrlWith=updateExistingKeys
            key={switch filterDataJson {
            | Some(_) => "routing-analytics-filter-0"
            | None => "routing-analytics-filter-1"
            }}
            filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
            showCustomFilter=false
            refreshFilters=false
          />
        </div>
      </div>
      /* Stats Cards Row */
      <div className="stats-cards-row mb-6">
        <DynamicSingleStat
          entity=singleStatEntity
          startTimeFilterKey=HSAnalyticsUtils.startTimeFilterKey
          endTimeFilterKey=HSAnalyticsUtils.endTimeFilterKey
          filterKeys
          moduleName
          showPercentage=false
        />
      </div>
      /* Distribution Section */
      <div className="distribution-section mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="volume-distribution-chart">
            {if _distributionData->Array.length > 0 {
              <DynamicChart
                entity=volumeDistributionEntity
                selectedTab=Some(["routing_approach"])
                chartId="volume-distribution"
                updateUrl=updateExistingKeys
                enableBottomChart=false
                showTableLegend=false
                showMarkers=false
                legendType=HighchartTimeSeriesChart.Points
                tabTitleMapper={Dict.make()}
                comparitionWidget=false
              />
            } else {
              <div
                className="border rounded bg-white border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 p-6 h-96 flex items-center justify-center">
                <AnalyticsUtils.NoDataFound />
              </div>
            }}
          </div>
          <div className="routing-logic-distribution-chart">
            {if _distributionData->Array.length > 0 {
              <DynamicChart
                entity=routingLogicDistributionEntity
                selectedTab=Some(["routing_approach"])
                chartId="routing-logic-distribution"
                updateUrl=updateExistingKeys
                enableBottomChart=false
                showTableLegend=false
                showMarkers=false
                legendType=HighchartTimeSeriesChart.Points
                tabTitleMapper={Dict.make()}
                comparitionWidget=false
              />
            } else {
              <div
                className="border rounded bg-white border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 p-6 h-96 flex items-center justify-center">
                <AnalyticsUtils.NoDataFound />
              </div>
            }}
          </div>
        </div>
      </div>
      /* Summary Table Section */
      <div className="summary-table-section">
        <LoadedTableWithCustomColumns
          title="Routing Summary"
          actualData={_tableData->Array.map(item => item->Nullable.make)}
          entity=tableEntity
          resultsPerPage=20
          showSerialNumber=false
          totalResults={_tableData->Array.length}
          offset=0
          setOffset={_ => ()}
          currrentFetchCount={_tableData->Array.length}
          customColumnMapper=TableAtoms.routingAnalyticsDefaultCols
          defaultColumns={RoutingAnalyticsEntity.defaultRoutingColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=false
          previewOnly=false
          remoteSortEnabled=false
          showAutoScroll=false
        />
      </div>
      /* Time Series Section */
      <div className="time-series-section">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <div className="success-over-time-chart">
            {if _timeSeriesData->Array.length > 0 {
              <DynamicChart
                entity=successOverTimeEntity
                selectedTab=Some(["routing_approach"])
                chartId="success-over-time"
                updateUrl=updateExistingKeys
                enableBottomChart=false
                showTableLegend=false
                showMarkers=true
                legendType=HighchartTimeSeriesChart.Points
                tabTitleMapper={Dict.make()}
                comparitionWidget=false
              />
            } else {
              <div
                className="border rounded bg-white border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 p-6 h-96 flex items-center justify-center">
                <AnalyticsUtils.NoDataFound />
              </div>
            }}
          </div>
          <div className="volume-over-time-chart">
            {if _timeSeriesData->Array.length > 0 {
              <DynamicChart
                entity=volumeOverTimeEntity
                selectedTab=Some(["routing_approach"])
                chartId="volume-over-time"
                updateUrl=updateExistingKeys
                enableBottomChart=false
                showTableLegend=false
                showMarkers=true
                legendType=HighchartTimeSeriesChart.Points
                tabTitleMapper={Dict.make()}
                comparitionWidget=false
              />
            } else {
              <div
                className="border rounded bg-white border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 p-6 h-96 flex items-center justify-center">
                <AnalyticsUtils.NoDataFound />
              </div>
            }}
          </div>
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
