@react.component
let make = () => {
  // open RoutingAnalyticsTrendsUtils
  open Typography
  open HSAnalyticsUtils
  let successChartEntity = DynamicChart.makeEntity(
    ~uri=String(`${Window.env.apiBaseUrl}/analytics/v1/metrics/routing`),
    ~filterKeys=["connector"],
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Time"),
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[
      {
        uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/routing`,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: [
          {
            metric_name_db: "payment_success_rate",
            metric_label: "Auth Rate",
            metric_type: Rate,
            thresholdVal: None,
            step_up_threshold: None,
            legendOption: (Current, Overall),
          },
        ],
        timeCol: "time_bucket",
        filterKeys: ["connector"],
      },
    ],
    ~moduleName="Routing Analytics",
    ~enableLoaders=true,
  )

  let volumeChartEntity = DynamicChart.makeEntity(
    ~uri=String(`${Window.env.apiBaseUrl}/analytics/v1/metrics/routing`),
    ~filterKeys=["connector"],
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Time"),
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[
      {
        uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/routing`,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: [
          {
            metric_name_db: "payment_count",
            metric_label: "Auth Rate",
            metric_type: Volume,
            thresholdVal: None,
            step_up_threshold: None,
            legendOption: (Average, Overall),
          },
        ],
        timeCol: "time_bucket",
        filterKeys: ["connector"],
      },
    ],
    ~moduleName="Routing Analytics",
    ~enableLoaders=true,
  )

  <div className="flex flex-col gap-6 w-full mt-12">
    <div className="flex flex-col gap-1 mb-2">
      <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Routing Trends"->React.string} </p>
      <p className={`${body.md.medium} text-nd_gray-400`}>
        {"Analyze the trends in routing metrics over time."->React.string}
      </p>
    </div>
    <div className="border border-nd_gray-200 rounded-xl">
      <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
        <p className={`${body.md.semibold} text-gray-800`}> {"Success Over Time"->React.string} </p>
      </div>
      <div className="p-6">
        <DynamicChart
          entity=successChartEntity
          selectedTab={Some(["connector"])}
          chartId="routing_success_rate"
          updateUrl={_ => ()}
          enableBottomChart=false
          showTableLegend=false
          showMarkers=true
          legendType=HighchartTimeSeriesChart.Points
          tabTitleMapper={Dict.make()}
          comparitionWidget=true
        />
      </div>
    </div>
    <div className="border border-nd_gray-200 rounded-xl">
      <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
        <p className={`${body.md.semibold} text-gray-800`}> {"Volume Over Time"->React.string} </p>
      </div>
      <div className="p-6">
        <DynamicChart
          entity=volumeChartEntity
          selectedTab={Some(["connector"])}
          chartId="routing_volume"
          updateUrl={_ => ()}
          enableBottomChart=false
          showTableLegend=false
          showMarkers=true
          legendType=HighchartTimeSeriesChart.Points
          tabTitleMapper={Dict.make()}
          comparitionWidget=true
        />
      </div>
    </div>
  </div>
}
