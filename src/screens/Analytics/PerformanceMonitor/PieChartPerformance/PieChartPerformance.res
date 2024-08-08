// @react.component
// let make = () => {
// let options = {
//   "chart": {
//     "type": "pie",
//   },
//   "title": {
//     "text": "Egg Yolk Composition",
//   },
//   "tooltip": {
//     "valueSuffix": `%`,
//   },
//   "subtitle": {
//     "text": "Source",
//   },
//   "plotOptions": {
//     "pie": {
//       "allowPointSelect": true,
//       "cursor": `pointer`,
//       "dataLabels": {
//         "enabled": true,
//         "distance": -15, // Set distance for the label inside the slice
//         "format": `{point.percentage:.0f}%`,
//       },
//       "showInLegend": true,
//     },
//   },
//   "series": [
//     {
//       "name": "Registrations",
//       "colorByPoint": true,
//       "innerSize": "75%",
//       "data": [
//         {
//           "name": "EV",
//           "y": 23.9,
//         },
//         {
//           "name": "Hybrids",
//           "y": 12.6,
//         },
//         {
//           "name": "Diesel",
//           "y": 37.0,
//         },
//         {
//           "name": "Petrol",
//           "y": 26.4,
//         },
//       ],
//     },
//   ],
// }->Identity.genericTypeToJson
//   <>
//     <HighchartPieChart.RawPieChart options={options} />
//   </>
// }

@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~dimensions,
  ~entity: PerformanceMonitorTypes.entity<'t>,
) => {
  open APIUtils
  open LogicUtils
  let domain = "payments"
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (options, setBarOptions) = React.useState(_ => JSON.Encode.null)
  let chartFetch = async () => {
    try {
      let metricsUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))
      let body = entity.getBody(
        ~dimensions,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupBy=entity.requestBodyConfig.groupBy,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )
      let res = await updateDetails(metricsUrl, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
      let configData = entity.getChartData(~array=arr, ~config=entity.configRequiredForChartData)
      let options = PieChartPerformanceUtils.getDontchartOptions(entity.chartConfig, configData)
      setBarOptions(_ => options)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      chartFetch()->ignore
    }
    None
  }, [dimensions])
  <>
    <HighchartPieChart.RawPieChart options={options} />
  </>
}
