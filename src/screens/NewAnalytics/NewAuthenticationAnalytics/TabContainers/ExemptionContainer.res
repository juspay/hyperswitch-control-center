open NewAuthenticationAnalyticsUtils
open NewAuthenticationAnalyticsHelper
open NewAuthenticationAnalyticsEntity

@react.component
let make = (~queryData) => {
  <div className="my-8">
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
      {getMetricsData(queryData)
      ->Array.mapWithIndex((metric, index) =>
        <RenderIf condition={metric.name === "3ds_exemption_authentication"}>
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
    <SCAExemptionAnalytics entity={scaExemptionEntity} chartEntity={scaExemptionChartEntity} />
    <div className="grid grid-cols-2 gap-6 mt-6">
      <ExemptionGraphs
        entity={authenticationSuccessEntity}
        chartEntity={authenticationSuccessChartEntity}
        metricXKey="authentication_success_count"
        groupByKey="authentication_connector"
      />
      <ExemptionGraphs
        entity={userDropOffRateEntity}
        chartEntity={userDropOffRateChartEntity}
        metricXKey="user_drop_off_rate"
        groupByKey="authentication_connector"
      />
      <ExemptionGraphs
        entity={exemptionApprovalRateEntity}
        chartEntity={exemptionApprovalRateChartEntity}
        metricXKey="exemption_approval_rate"
        groupByKey=""
      />
      <ExemptionGraphs
        entity={exemptionRequestRateEntity}
        chartEntity={exemptionRequestRateChartEntity}
        metricXKey="exemption_request_rate"
        groupByKey=""
      />
    </div>
    <AuthenticationSummary entity={authenticationSummaryEntity} />
  </div>
}
