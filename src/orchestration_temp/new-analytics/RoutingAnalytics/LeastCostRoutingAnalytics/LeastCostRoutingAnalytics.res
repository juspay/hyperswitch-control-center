@react.component
let make = () => {
  <div className="flex flex-col gap-6">
    <LeastCostRoutingAnalyticsMetrics />
    <LeastCostRoutingAnalyticsDistribution />
    <LeastCostRoutingAnalyticsSummaryTable />
  </div>
}
