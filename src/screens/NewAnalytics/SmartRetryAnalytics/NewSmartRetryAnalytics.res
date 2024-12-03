@react.component
let make = () => {
  open NewSmartRetryAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <SuccessfulSmartRetryDistribution
      entity={successfulSmartRetryDistributionEntity}
      chartEntity={successfulSmartRetryDistributionChartEntity}
    />
    <FailureSmartRetryDistribution
      entity={failedSmartRetryDistributionEntity}
      chartEntity={failedSmartRetryDistributionChartEntity}
    />
    // smart retry proccesed amount
  </div>
}
