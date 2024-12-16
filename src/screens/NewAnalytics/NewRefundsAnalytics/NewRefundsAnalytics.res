@react.component
let make = () => {
  open NewRefundsAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <RefundsProcessed entity={refundsProcessedEntity} chartEntity={refundsProcessedChartEntity} />
    <RefundsSuccessRate
      entity={refundsSuccessRateEntity} chartEntity={refundsSuccessRateChartEntity}
    />
  </div>
}
