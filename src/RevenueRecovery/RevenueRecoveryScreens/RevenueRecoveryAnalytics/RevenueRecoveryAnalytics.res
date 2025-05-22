@react.component
let make = () => {
  open RevenueRecoveryAnalyticsEntity
  let customTitleStyle = "py-0 !pt-0"

  <div className={`flex flex-col mx-auto h-full w-full min-h-[50vh] gap-7`}>
    <div className="flex justify-between items-center mb-5">
      <PageUtils.PageHeading
        title="Overview" subTitle="Viewing data of: April, 2025" customTitleStyle
      />
    </div>
    <AuthRateSummary entity={authRateSummaryEntity} />
    <RetryStrategiesAnalytics entity={retryStrategiesEntity} />
  </div>
}
