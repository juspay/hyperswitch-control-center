@react.component
let make = (~paymentId, ~disputeId, ~data: DisputeTypes.disputes) => {
  open LogTypes

  let disputesLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/api_event_logs?type=Dispute&payment_id=${paymentId}&dispute_id=${disputeId}`
  let webhooksLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/outgoing_webhook_event_logs?&payment_id=${paymentId}&dispute_id=${disputeId}`
  let connectorLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/connector_event_logs?payment_id=${paymentId}&dispute_id=${disputeId}`

  let urls = [
    {
      url: disputesLogsUrl,
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

  <AuditLogUI id={paymentId} urls logType={#DISPUTE} />
}
