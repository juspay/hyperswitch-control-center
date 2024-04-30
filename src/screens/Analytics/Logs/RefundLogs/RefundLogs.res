@react.component
let make = (~refundId, ~paymentId) => {
  open LogTypes

  let refundsLogsUrl = `${Window.env.apiBaseUrl}/analytics/v1/api_event_logs?type=Refund&payment_id=${paymentId}&refund_id=${refundId}`
  let webhooksLogsUrl = `${Window.env.apiBaseUrl}/analytics/v1/outgoing_webhook_event_logs?&payment_id=${paymentId}&refund_id=${refundId}`
  let connectorLogsUrl = `${Window.env.apiBaseUrl}/analytics/v1/connector_event_logs?payment_id=${paymentId}&refund_id=${refundId}`

  let urls = [
    {
      url: refundsLogsUrl,
      apiMethod: Get,
    },
    {
      url: webhooksLogsUrl,
      apiMethod: Get,
    },
    {
      url: connectorLogsUrl,
      apiMethod: Get,
    },
  ]

  <AuditLogUI id={paymentId} urls logType={#REFUND} />
}
