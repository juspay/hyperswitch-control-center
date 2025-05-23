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
      <OverallRetryStrategyAnalytics
        entity={overallRetryStrategysEntity} chartEntity={overallRetryStrategyChartEntity}
      />
    </div>
  </div>
}
