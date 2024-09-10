@react.component
let make = () => {
  <div className="flex flex-col gap-5 mt-5">
    <LineGraph entity={NewPaymentAnalyticsEntity.paymentsProcessedEntity} />
  </div>
}
