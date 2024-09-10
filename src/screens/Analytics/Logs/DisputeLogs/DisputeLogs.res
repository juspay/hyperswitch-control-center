@react.component
let make = (~paymentId, ~disputeId) => {
  open LogTypes
  open APIUtils
  let getURL = useGetURL()
  let webhookLogsUrl = getURL(
    ~entityName=WEBHOOKS_EVENT_LOGS,
    ~methodType=Get,
    ~queryParamerters=Some(`payment_id=${paymentId}&dispute_id=${disputeId}`),
  )
  let disputesLogsUrl = getURL(
    ~entityName=API_EVENT_LOGS,
    ~methodType=Get,
    ~queryParamerters=Some(`type=Dispute&payment_id=${paymentId}&dispute_id=${disputeId}`),
  )
  let connectorLogsUrl = getURL(
    ~entityName=CONNECTOR_EVENT_LOGS,
    ~methodType=Get,
    ~queryParamerters=Some(`payment_id=${paymentId}&dispute_id=${disputeId}`),
  )
  let urls = [
    {
      url: disputesLogsUrl,
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

  <AuditLogUI id={paymentId} urls logType={#DISPUTE} />
}
