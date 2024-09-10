@react.component
let make = () => {
  let startTimeVal = "2024-09-02T18:30:00Z"
  let endTimeVal = "2024-09-10T09:16:00Z"

  <div className="flex flex-col gap-5 mt-5">
    <LineGraph entity={NewPaymentAnalyticsEntity.paymentsProcessedEntity} startTimeVal endTimeVal />
  </div>
}
