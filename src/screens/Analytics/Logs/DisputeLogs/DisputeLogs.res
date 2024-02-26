@react.component
let make = (~paymentId, ~disputeId, ~data: DisputeTypes.disputes) => {
  open APIUtils
  let fetchDetails = useGetMethod(~showErrorToast=false, ())

  let disputesLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/api_event_logs?type=Dispute&payment_id=${paymentId}&dispute_id=${disputeId}`
  let webhooksLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/outgoing_webhook_event_logs?&payment_id=${paymentId}&dispute_id=${disputeId}`
  let connectorLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/connector_event_logs?payment_id=${paymentId}&dispute_id=${disputeId}`

  let promiseArr = [fetchDetails(disputesLogsUrl), fetchDetails(webhooksLogsUrl)]

  if (
    LogUtils.responseMaskingSupportedConectors->Array.includes(
      data.connector->ConnectorUtils.getConnectorNameTypeFromString,
    )
  ) {
    promiseArr->Array.concat([fetchDetails(connectorLogsUrl)])->ignore
  }

  <AuditLogUI id={paymentId} promiseArr logType={#DISPUTE} />
}
