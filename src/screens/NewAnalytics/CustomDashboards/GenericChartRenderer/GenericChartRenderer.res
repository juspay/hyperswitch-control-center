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
  let responseField = WidgetConfiguratorUtils.getResponseFieldName(primaryMetric)
  let groupByKey = widgetConfig.groupBy->Array.get(0)->Option.getOr("time_bucket")
  let isTimeSeries = WidgetConfiguratorUtils.needsTimeSeries(widget.chartType)
  let chartHeightPx = Math.Int.max(120, widget.position.h * 80 - 60)

  let fetchData = async () => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setScreenState(_ => Loading)
      try {
        let entityName = CustomDashboardUtils.getDomainApiEntity(
          widgetConfig.domain,
          ~metrics=widgetConfig.metrics,
        )
        let idParam = switch widgetConfig.domain {
        | AuthEvents => None
        | _ => Some(CustomDashboardUtils.getDomainString(widgetConfig.domain))
        }
        let url = getURL(~entityName, ~methodType=Post, ~id=idParam)

        // Type-safe conversion of metric strings to polyvariants
        // Uses explicit mapping instead of Obj.magic for type safety
        let metrics = CustomDashboardUtils.metricsStringsToPolyvariants(widgetConfig.metrics)

        let groupByNames = if widgetConfig.groupBy->Array.length > 0 {
          Some(widgetConfig.groupBy)
        } else {
          None
        }

        let body = switch widgetConfig.granularity {
        | Some(g) if isTimeSeries =>
          requestBody(
            ~startTime=startTimeVal,
            ~endTime=endTimeVal,
            ~metrics,
            ~groupByNames,
            ~granularity=Some(g),
            ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
          )
        | _ =>
          requestBody(
            ~startTime=startTimeVal,
            ~endTime=endTimeVal,
            ~metrics,
            ~groupByNames,
            ~filter=generateFilterObject(~globalFilters=filterValueJson)->Some,
          )
        }
        let response = await updateDetails(url, body, Post)
        let queryData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

        if queryData->Array.length > 0 {
          setRawData(_ => queryData)

          if isTimeSeries {
            let sortedData = queryData->NewAnalyticsUtils.sortQueryDataByDate
            let filledData = [sortedData]->Array.map(data => {
              fillMissingDataPoints(
                ~data,
                ~startDate=startTimeVal,
                ~endDate=endTimeVal,
                ~timeKey="time_bucket",
                ~defaultValue={"time_bucket": startTimeVal}->Identity.genericTypeToJson,
                ~granularity=widgetConfig.granularity->Option.getOr("G_ONEDAY"),
                ~isoStringToCustomTimeZone,
                ~granularityEnabled=featureFlag.granularity,
              )
            })
            setChartData(_ => filledData->Identity.genericTypeToJson)
          } else {
            setChartData(_ => queryData->Identity.genericTypeToJson)
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
  }, (startTimeVal, endTimeVal, filterValueJson, primaryMetric, groupByKey, (widget.chartType :> string)))

  let containerStyle = ReactDOM.Style.make(
    ~height=`${chartHeightPx->Int.toString}px`,
    ~width="100%",
    (),
  )

  <div style={containerStyle}>
    <PageLoaderWrapper
      screenState
      customLoader={<InsightsHelper.Shimmer layoutId=title />}
      customUI={<NewAnalyticsHelper.NoData />}>
      {
        switch widget.chartType {
        | LineChart => {
            let payload = GenericChartRendererUtils.buildLineGraphPayload(
              ~data=chartData,
              ~xKey=responseField,
              ~yKey="time_bucket",
              ~title,
              ~chartHeight=chartHeightPx,
            )
            let options = LineGraphUtils.getLineGraphOptions(payload)
            <LineGraph options />
          }
        | BarChart => {
            let payload = GenericChartRendererUtils.buildBarGraphPayload(
              ~data=rawData,
              ~xKey=responseField,
              ~yKey=groupByKey,
              ~title,
            )
            let options = BarGraphUtils.getBarGraphOptions(payload)
            <BarGraph options />
          }
        | ColumnChart => {
            let payload = GenericChartRendererUtils.buildColumnGraphPayload(
              ~data=rawData,
              ~xKey=responseField,
              ~yKey=groupByKey,
              ~title,
            )
            let options = ColumnGraphUtils.getColumnGraphOptions(payload)
            <ColumnGraph options />
          }
        | StackedBarChart => {
            let payload = GenericChartRendererUtils.buildStackedBarGraphPayload(
              ~data=rawData,
              ~xKey=responseField,
              ~yKey=groupByKey,
              ~_title=title,
            )
            let options = StackedBarGraphUtils.getStackedBarGraphOptions(
              payload,
              ~yMax=100,
              ~labelItemDistance=20,
            )
            <StackedBarGraph options />
          }
        | FunnelChart => {
            let payload = GenericChartRendererUtils.buildFunnelData(
              ~data=rawData,
              ~xKey=responseField,
              ~yKey=groupByKey,
              ~title,
            )
            let options = ColumnGraphUtils.getColumnGraphOptions(payload)
            <ColumnGraph options />
          }
        | SankeyChart => {
            let payload = GenericChartRendererUtils.buildSankeyGraphPayload(
              ~data=rawData,
              ~xKey=responseField,
              ~yKey=groupByKey,
              ~title,
            )
            let options = SankeyGraphUtils.getSankyGraphOptions(payload)
            <SankeyGraph options />
          }
        | PieChart => {
            let filteredData = rawData->Array.filter(item => {
              let dict = item->getDictFromJsonObject
              let val = dict->getString(groupByKey, "")
              val->isNonEmptyString
            })
            let payload = GenericChartRendererUtils.buildPieGraphPayload(
              ~data=filteredData,
              ~xKey=responseField,
              ~yKey=groupByKey,
              ~title,
            )
            let options = PieGraphUtils.getPieChartOptions(payload)
            <div className="flex items-center justify-center h-full overflow-hidden">
              <PieGraph options />
            </div>
          }
        // ── Table View ──
        | Table => {
            let columns = if rawData->Array.length > 0 {
              rawData
              ->Array.get(0)
              ->Option.map(item => item->getDictFromJsonObject->Dict.keysToArray)
              ->Option.getOr([])
              ->Array.filter(key =>
                // Filter out null-only columns and internal fields
                key !== "time_range" &&
                rawData->Array.some(row =>
                  row->getDictFromJsonObject->Dict.get(key)->Option.map(v =>
                    v !== JSON.Encode.null
                  )->Option.getOr(false)
                )
              )
            } else {
              []
            }
            <div className="overflow-auto h-full">
              <table className="w-full text-sm text-left">
                <thead className="text-xs text-gray-500 uppercase bg-gray-50 dark:bg-jp-gray-950 sticky top-0">
                  <tr>
                    {columns
                    ->Array.map(col =>
                      <th key={col} className="px-4 py-3 font-medium border-b">
                        {React.string(col->LogicUtils.snakeToTitle)}
                      </th>
                    )
                    ->React.array}
                  </tr>
                </thead>
                <tbody>
                  {rawData
                  ->Array.mapWithIndex((row, rowIdx) => {
                    let dict = row->getDictFromJsonObject
                    <tr
                      key={rowIdx->Int.toString}
                      className="border-b hover:bg-gray-50 dark:hover:bg-jp-gray-950">
                      {columns
                      ->Array.map(col => {
                        let val = dict->Dict.get(col)->Option.getOr(JSON.Encode.null)
                        let display = switch val->JSON.Classify.classify {
                        | String(s) => s->LogicUtils.snakeToTitle
                        | Number(n) =>
                          if n->Float.toInt->Int.toFloat === n {
                            n->Float.toInt->Int.toString
                          } else {
                            n->Js.Float.toFixedWithPrecision(~digits=2)
                          }
                        | Bool(b) => b ? "Yes" : "No"
                        | Null => "-"
                        | _ => "-"
                        }
                        <td key={col} className="px-4 py-3 text-gray-700 dark:text-gray-300">
                          {React.string(display)}
                        </td>
                      })
                      ->React.array}
                    </tr>
                  })
                  ->React.array}
                </tbody>
              </table>
            </div>
          }
        // ── Stat Number (big single value) ──
        | StatNumber => {
            // Get the first data point's value for the primary metric
            let value = rawData
              ->Array.get(0)
              ->Option.map(item => item->getDictFromJsonObject->getFloat(responseField, 0.0))
              ->Option.getOr(0.0)
            let isRate = primaryMetric->Js.String2.includes("rate") || primaryMetric->Js.String2.includes("pct")
            let displayValue = if isRate {
              `${value->Js.Float.toFixedWithPrecision(~digits=1)}%`
            } else if value > 1000000.0 {
              `${(value /. 1000000.0)->Js.Float.toFixedWithPrecision(~digits=2)}M`
            } else if value > 1000.0 {
              `${(value /. 1000.0)->Js.Float.toFixedWithPrecision(~digits=1)}K`
            } else if value->Float.toInt->Int.toFloat === value {
              value->Float.toInt->Int.toString
            } else {
              value->Js.Float.toFixedWithPrecision(~digits=2)
            }
            <div className="flex flex-col items-center justify-center h-full gap-2">
              <p className="text-5xl font-bold text-jp-gray-900 dark:text-white">
                {React.string(displayValue)}
              </p>
              <p className="text-sm text-gray-400">
                {React.string(title)}
              </p>
            </div>
          }
        // ── Gauge (percentage dial) ──
        | Gauge => {
            let value = rawData
              ->Array.get(0)
              ->Option.map(item => item->getDictFromJsonObject->getFloat(responseField, 0.0))
              ->Option.getOr(0.0)
            // Clamp to 99.9 at 100% to avoid degenerate SVG arc (start == end point)
            let clampedValue = if value >= 100.0 {
              99.9
            } else {
              Js.Math.max_float(0.0, value)
            }
            let angle = clampedValue /. 100.0 *. 180.0
            let displayStr = if value >= 100.0 {
              "100%"
            } else {
              `${clampedValue->Js.Float.toFixedWithPrecision(~digits=1)}%`
            }
            // SVG gauge arc
            <div className="flex flex-col items-center justify-center h-full gap-2">
              <svg width="180" height="110" viewBox="0 0 180 110">
                // Background arc (gray)
                <path
                  d="M 10 100 A 80 80 0 0 1 170 100"
                  fill="none"
                  stroke="#e5e7eb"
                  strokeWidth="16"
                  strokeLinecap="round"
                />
                // Value arc (colored)
                {
                  // Calculate end point of the arc based on value
                  let rad = (180.0 -. angle) *. Math.Constants.pi /. 180.0
                  let endX = 90.0 -. 80.0 *. Math.cos(rad)
                  let endY = 100.0 -. 80.0 *. Math.sin(rad)
                  let largeArc = if angle > 90.0 { "1" } else { "0" }
                  let color = if clampedValue >= 80.0 {
                    "#10b981"
                  } else if clampedValue >= 50.0 {
                    "#f59e0b"
                  } else {
                    "#ef4444"
                  }
                  <path
                    d={`M 10 100 A 80 80 0 ${largeArc} 1 ${endX->Js.Float.toFixedWithPrecision(~digits=1)} ${endY->Js.Float.toFixedWithPrecision(~digits=1)}`}
                    fill="none"
                    stroke={color}
                    strokeWidth="16"
                    strokeLinecap="round"
                  />
                }
                // Center text
                <text
                  x="90"
                  y="95"
                  textAnchor="middle"
                  className="text-2xl font-bold"
                  fill="#1f2937"
                  fontSize="24">
                  {React.string(displayStr)}
                </text>
              </svg>
              <p className="text-sm text-gray-400 -mt-2">
                {React.string(title)}
              </p>
            </div>
          }
        }
      }
    </PageLoaderWrapper>
  </div>
}
