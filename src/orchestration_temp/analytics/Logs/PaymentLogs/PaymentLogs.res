@react.component
let make = (~paymentId, ~createdAt) => {
  open LogTypes
  open APIUtils
  let getURL = useGetURL()
  let apiLogsUrl = getURL(
    ~entityName=V1(API_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`type=Payment&payment_id=${paymentId}`),
  )
  let sdkLogsUrl = getURL(~entityName=V1(SDK_EVENT_LOGS), ~methodType=Post, ~id=Some(paymentId))
  let startTime = createdAt->Date.fromString->Date.getTime -. 1000. *. 60. *. 5.
  let startTime = startTime->Js.Date.fromFloat->Date.toISOString
  let endTime = createdAt->Date.fromString->Date.getTime +. 1000. *. 60. *. 60. *. 3.
  let endTime = endTime->Js.Date.fromFloat->Date.toISOString
  let sdkPostBody = [
    ("paymentId", paymentId->JSON.Encode.string),
    (
      "timeRange",
      [("startTime", startTime->JSON.Encode.string), ("endTime", endTime->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object,
    ),
  ]->LogicUtils.getJsonFromArrayOfJson
  let webhookLogsUrl = getURL(
    ~entityName=V1(WEBHOOKS_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`payment_id=${paymentId}`),
  )
  let connectorLogsUrl = getURL(
    ~entityName=V1(CONNECTOR_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`type=Payment&payment_id=${paymentId}`),
  )
  let routingLogsUrl = getURL(
    ~entityName=V1(ROUTING_EVENT_LOGS),
    ~methodType=Get,
    ~queryParamerters=Some(`type=Payment&payment_id=${paymentId}`),
  )

  let urls = [
    {
      url: apiLogsUrl,
      apiMethod: Get,
    },
    {
      url: sdkLogsUrl,
      apiMethod: Post,
      body: sdkPostBody,
    },
    {
      url: webhookLogsUrl,
      apiMethod: Get,
    },
    {
      url: connectorLogsUrl,
      apiMethod: Get,
    },
    {
      url: routingLogsUrl,
      apiMethod: Get,
    },
  ]

  <AuditLogUI id={paymentId} urls logType={#PAYMENT} />
}
