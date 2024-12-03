@react.component
let make = () => {
  open NewSmartRetryAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <SmartRetryPaymentsProcessed
      entity={smartRetryPaymentsProcessedEntity}
      chartEntity={smartRetryPaymentsProcessedChartEntity}
    />
    <SuccessfulSmartRetryDistribution
      entity={successfulSmartRetryDistributionEntity}
      chartEntity={successfulSmartRetryDistributionChartEntity}
    />
    <FailureSmartRetryDistribution
      entity={failedSmartRetryDistributionEntity}
      chartEntity={failedSmartRetryDistributionChartEntity}
    />
  </div>
}
