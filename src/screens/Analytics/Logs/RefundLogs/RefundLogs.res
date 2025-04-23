@react.component
let make = (~refundId, ~paymentId) => {
  open LogTypes
  open APIUtils
  let getURL = useGetURL()
  let webhookLogsUrl = getURL(
    ~entityName=V1(WEBHOOKS_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`payment_id=${paymentId}&refund_id=${refundId}`),
  )
  let refundsLogsUrl = getURL(
    ~entityName=V1(API_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`type=Refund&payment_id=${paymentId}&refund_id=${refundId}`),
  )
  let connectorLogsUrl = getURL(
    ~entityName=V1(CONNECTOR_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`payment_id=${paymentId}&refund_id=${refundId}`),
  )
  let urls = [
    {
      url: refundsLogsUrl,
      apiMethod: Get,
    },
    {
      url: webhookLogsUrl,
      apiMethod: Get,
    },
    {
      url: connectorLogsUrl,
      apiMethod: Get,
    },
  ]

  <AuditLogUI id={paymentId} urls logType={#REFUND} />
}
