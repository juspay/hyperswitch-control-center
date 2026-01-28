@react.component
let make = (~payoutId) => {
  open LogTypes
  open APIUtils
  let getURL = useGetURL()
  let apiLogsUrl = getURL(
    ~entityName=V1(API_EVENT_LOGS),
    ~methodType=Get,
    ~queryParameters=Some(`type=Payout&payout_id=${payoutId}`),
  )

  let webhookLogsUrl = getURL(
    ~entityName=V1(WEBHOOKS_EVENT_LOGS),
    ~methodType=Get,
    ~queryParameters=Some(`payout_id=${payoutId}`),
  )
  let connectorLogsUrl = getURL(
    ~entityName=V1(CONNECTOR_EVENT_LOGS),
    ~methodType=Get,
    ~queryParameters=Some(`type=Payout&payout_id=${payoutId}`),
  )

  let urls = [
    {
      url: apiLogsUrl,
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

  <AuditLogUI id={payoutId} urls logType={#PAYOUT} />
}
