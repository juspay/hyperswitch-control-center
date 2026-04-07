@react.component
let make = (~widget: CustomDashboardTypes.widget) => {
  open APIUtils
  open LogicUtils
  open InsightsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (chartData, setChartData) = React.useState(_ => JSON.Encode.array([]))
  let (rawData, setRawData) = React.useState(_ => [])
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let widgetConfig = widget.config
  let title = widget.widgetName
  let primaryMetric = widgetConfig.metrics->Array.get(0)->Option.getOr("")

  let fetchData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setScreenState(_ => Loading)
      try {
        let url = getURL(
          ~entityName=CustomDashboardUtils.getDomainApiEntity(widgetConfig.domain),
          ~methodType=Post,
          ~id=Some(CustomDashboardUtils.getDomainString(widgetConfig.domain)),
        )

        let metrics: array<InsightsTypes.metrics> =
          widgetConfig.metrics->Array.map(m => m->Obj.magic)

        let groupByNames = if widgetConfig.groupBy->Array.length > 0 {
          Some(widgetConfig.groupBy)
        } else {
          None
        }

        let body = switch widgetConfig.granularity {
        | Some(g) =>
          requestBody(
            ~startTime=startTimeVal,
            ~endTime=endTimeVal,
            ~metrics,
            ~groupByNames,
            ~granularity=Some(g),
            ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
          )
        | None =>
          requestBody(
            ~startTime=startTimeVal,
            ~endTime=endTimeVal,
            ~metrics,
            ~groupByNames,
            ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
          )
        }
        let response = await updateDetails(url, body, Post)
        let queryData =
          response->getDictFromJsonObject->getArrayFromDict("queryData", [])

        if queryData->Array.length > 0 {
          setRawData(_ => queryData)

          switch widget.chartType {
          | LineChart | ColumnChart => {
              let sortedData = queryData->NewAnalyticsUtils.sortQueryDataByDate
              let filledData = [sortedData]->Array.map(data => {
                fillMissingDataPoints(
                  ~data,
                  ~startDate=startTimeVal,
                  ~endDate=endTimeVal,
                  ~timeKey="time_bucket",
                  ~defaultValue={
                    "time_bucket": startTimeVal,
                  }->Identity.genericTypeToJson,
                  ~granularity=widgetConfig.granularity->Option.getOr("G_ONEDAY"),
                  ~isoStringToCustomTimeZone,
                  ~granularityEnabled=featureFlag.granularity,
                )
              })
              setChartData(_ => filledData->Identity.genericTypeToJson)
            }
          | _ => setChartData(_ => queryData->Identity.genericTypeToJson)
          }
          setScreenState(_ => Success)
        } else {
          setScreenState(_ => Custom)
        }
      } catch {
      | _ => setScreenState(_ => Custom)
      }
    }
  }

  React.useEffect(() => {
    fetchData()->ignore
    None
  }, (startTimeVal, endTimeVal, filterValueJson))

  <PageLoaderWrapper
    screenState customLoader={<InsightsHelper.Shimmer layoutId=title />} customUI={<NewAnalyticsHelper.NoData />}>
    {switch widget.chartType {
    | LineChart => {
        let payload = GenericChartRendererUtils.buildLineGraphPayload(
          ~data=chartData,
          ~xKey=primaryMetric,
          ~yKey="time_bucket",
          ~title,
        )
        let options = LineGraphUtils.getLineGraphOptions(payload)
        <LineGraph options className="mr-3" />
      }
    | BarChart => {
        let payload = GenericChartRendererUtils.buildBarGraphPayload(
          ~data=rawData,
          ~xKey=primaryMetric,
          ~yKey=widgetConfig.groupBy->Array.get(0)->Option.getOr("time_bucket"),
          ~title,
        )
        let options = BarGraphUtils.getBarGraphOptions(payload)
        <BarGraph options className="mr-3" />
      }
    | ColumnChart => {
        let payload = GenericChartRendererUtils.buildLineGraphPayload(
          ~data=chartData,
          ~xKey=primaryMetric,
          ~yKey="time_bucket",
          ~title,
        )
        let options = LineGraphUtils.getLineGraphOptions(payload)
        <LineGraph options className="mr-3" />
      }
    | PieChart | StackedBarChart | SankeyChart | FunnelChart => {
        let payload = GenericChartRendererUtils.buildBarGraphPayload(
          ~data=rawData,
          ~xKey=primaryMetric,
          ~yKey=widgetConfig.groupBy->Array.get(0)->Option.getOr("time_bucket"),
          ~title,
        )
        let options = BarGraphUtils.getBarGraphOptions(payload)
        <BarGraph options className="mr-3" />
      }
    }}
  </PageLoaderWrapper>
}
