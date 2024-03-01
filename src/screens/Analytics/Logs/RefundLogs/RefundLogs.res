@react.component
let make = (~refundId, ~paymentId, ~data: RefundEntity.refunds) => {
  open LogTypes

  let refundsLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/api_event_logs?type=Refund&payment_id=${paymentId}&refund_id=${refundId}`
  let webhooksLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/outgoing_webhook_event_logs?&payment_id=${paymentId}&refund_id=${refundId}`
  let connectorLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/connector_event_logs?payment_id=${paymentId}&refund_id=${refundId}`

  let urls = [
    {
      url: refundsLogsUrl,
      apiMethod: Get,
    },
    {
      url: webhooksLogsUrl,
      apiMethod: Get,
    },
  ]

  switch data.connector->ConnectorUtils.getConnectorNameTypeFromString() {
  | Processors(connector) =>
    if LogUtils.responseMaskingSupportedConectors->Array.includes(connector) {
      urls
      ->Array.concat([
        {
          url: connectorLogsUrl,
          apiMethod: Get,
        },
      ])
      ->ignore
    }
  | _ => ()
  }

  <AuditLogUI id={paymentId} urls logType={#REFUND} />
}
