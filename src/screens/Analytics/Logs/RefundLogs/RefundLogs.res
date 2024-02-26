@react.component
let make = (~refundId, ~paymentId, ~data: RefundEntity.refunds) => {
  open APIUtils
  let fetchDetails = useGetMethod(~showErrorToast=false, ())

  let refundsLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/api_event_logs?type=Refund&payment_id=${paymentId}&refund_id=${refundId}`
  let webhooksLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/outgoing_webhook_event_logs?&payment_id=${paymentId}&refund_id=${refundId}`
  let connectorLogsUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/connector_event_logs?payment_id=${paymentId}&refund_id=${refundId}`

  let promiseArr = [fetchDetails(refundsLogsUrl), fetchDetails(webhooksLogsUrl)]

  if (
    LogUtils.responseMaskingSupportedConectors->Array.includes(
      data.connector->ConnectorUtils.getConnectorNameTypeFromString,
    )
  ) {
    promiseArr->Array.concat([fetchDetails(connectorLogsUrl)])->ignore
  }

  <AuditLogUI id={paymentId} promiseArr logType={#REFUND} />
}
