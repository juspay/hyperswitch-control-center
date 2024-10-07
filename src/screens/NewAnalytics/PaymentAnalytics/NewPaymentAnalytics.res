@react.component
let make = () => {
  open NewPaymentAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <NewPaymentsOverviewSection entity={overviewSectionEntity} />
    <PaymentsLifeCycle
      entity={paymentsLifeCycleEntity} chartEntity={paymentsLifeCycleChartEntity}
    />
    <PaymentsProcessed
      entity={paymentsProcessedEntity} chartEntity={paymentsProcessedChartEntity}
    />
    <PaymentsSuccessRate
      entity={paymentsSuccessRateEntity} chartEntity={paymentsSuccessRateChartEntity}
    />
    <SuccessfulPaymentsDistribution
      entity={successfulPaymentsDistributionEntity}
      chartEntity={successfulPaymentsDistributionChartEntity}
    />
    <FailedPaymentsDistribution
      entity={failedPaymentsDistributionEntity} chartEntity={failedPaymentsDistributionChartEntity}
    />
  </div>
}
