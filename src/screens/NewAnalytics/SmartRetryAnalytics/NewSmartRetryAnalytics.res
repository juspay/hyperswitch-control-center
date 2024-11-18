@react.component
let make = () => {
  open NewSmartRetryAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <SuccessfulPaymentsDistribution
      entity={successfulSmartRetryDistributionEntity}
      chartEntity={successfulSmartRetryDistributionChartEntity}
    />
    // <FailedPaymentsDistribution
    //   entity={failedPaymentsDistributionEntity} chartEntity={failedPaymentsDistributionChartEntity}
    // />
  </div>
}
