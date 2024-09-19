@react.component
let make = () => {
  open OverViewAnalyticsEntity

  <div className="flex flex-col gap-5 mt-5">
    <PaymentsProcessed
      entity={paymentsProcessedEntity} chartEntity={paymentsProcessedChartEntity}
    />
  </div>
}
