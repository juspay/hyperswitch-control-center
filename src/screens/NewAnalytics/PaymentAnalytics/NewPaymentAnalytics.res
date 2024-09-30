@react.component
let make = () => {
  open NewPaymentAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <PaymentsLifeCycle
      entity={paymentsLifeCycleEntity} chartEntity={paymentsLifeCycleChartEntity}
    />
    <PaymentsProcessed
      entity={paymentsProcessedEntity} chartEntity={paymentsProcessedChartEntity}
    />
    <PaymentsSuccessRate
      entity={paymentsSuccessRateEntity} chartEntity={paymentsSuccessRateChartEntity}
    />
    <PaymentsDistribution
      entity={paymentsDistributionEntity} chartEntity={paymentsDistributionChartEntity}
    />
  </div>
}
