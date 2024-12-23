@react.component
let make = () => {
  open NewRefundsAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <div className="flex gap-2">
      <NewAnalyticsFilters domain={#refunds} entityName={ANALYTICS_REFUNDS} />
    </div>
    <RefundsOverviewSection entity={overviewSectionEntity} />
    <RefundsProcessed entity={refundsProcessedEntity} chartEntity={refundsProcessedChartEntity} />
    <RefundsSuccessRate
      entity={refundsSuccessRateEntity} chartEntity={refundsSuccessRateChartEntity}
    />
    <SuccessfulRefundsDistribution
      entity={successfulRefundsDistributionEntity}
      chartEntity={successfulRefundsDistributionChartEntity}
    />
    <FailedRefundsDistribution
      entity={failedRefundsDistributionEntity} chartEntity={failedRefundsDistributionChartEntity}
    />
    <RefundsReasons entity={refundsReasonsEntity} />
    <FailureReasonsRefunds entity={failureReasonsEntity} />
  </div>
}
