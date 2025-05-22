@react.component
let make = () => {
  open RevenueRecoveryAnalyticsEntity
  let customTitleStyle = "py-0 !pt-0"

  <div className={`flex flex-col mx-auto h-full w-full gap-7`}>
    <div className="flex justify-between items-center mb-5">
      <PageUtils.PageHeading
        title="Overview" subTitle="Viewing data of: April, 2025" customTitleStyle
      />
    </div>
    <div className="flex flex-col gap-10">
      <div className="flex flex-col gap-5">
        <AuthRateSummary entity={authRateSummaryEntity} chartEntity={authRateSummaryChartEntity} />
        <RetryStrategiesAnalytics entity={retryStrategiesEntity} />
      </div>
      <OverallRetryStrategyAnalytics entity={overallRetryStrategysEntity} />
      <RetriesComparisionAnalytics entity={retriesComparisionEntity} />
      <SmartRetryStrategyAnalytics entity={smartRetryStrategyEntity} />
    </div>
  </div>
}
