@react.component
let make = () => {
  open Typography
  open RevenueRecoveryAnalyticsEntity
  let customTitleStyle = "py-0 !pt-0 !text-fs-24"

  <div className={`flex flex-col mx-auto h-full w-full gap-7`}>
    <PageUtils.PageHeading
      title="Overview"
      subTitle="Viewing data of: Jan 2024 - Dec 2024"
      customTitleStyle
      customSubTitleStyle={`${body.lg.medium} !mt-1`}
    />
    <div className="flex flex-col gap-10 -mt-2">
      <SingleStatsAnalytics />
      <OverallRetryStrategyAnalytics
        entity={overallRetryStrategysEntity} chartEntity={overallRetryStrategyChartEntity}
      />
      <RetriesComparisionAnalytics
        entity={retriesComparisionEntity} chartEntity={retriesComparisionChartEntity}
      />
      <SmartRetryStrategyAnalytics entity={smartRetryStrategyEntity} />
    </div>
  </div>
}
