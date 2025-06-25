open NewAuthenticationAnalyticsUtils
open NewAuthenticationAnalyticsHelper
@react.component
let make = (~queryData, ~funnelData, ~metrics, ~funnelRenderCondition) => {
  <div className="my-8">
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
      {getMetricsData(queryData)
      ->Array.mapWithIndex((metric, index) =>
        <RenderIf condition={metric.name === "authentication"}>
          <StatCard
            key={index->Int.toString}
            title={metric.title}
            value={metric.value}
            valueType={metric.valueType}
            description={metric.tooltip_description}
          />
        </RenderIf>
      )
      ->React.array}
    </div>
    <RenderIf condition={funnelRenderCondition}>
      <div className="border border-gray-200 mt-5 rounded-lg">
        <FunnelChart
          data={getFunnelChartData(funnelData)}
          metrics={metrics}
          moduleName="Authentication Funnel"
          description=Some("Breakdown of ThreeDS 2.0 Journey")
        />
      </div>
    </RenderIf>
    <Insights />
  </div>
}
