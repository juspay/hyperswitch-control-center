@react.component
let make = (~paymentId, ~createdAt) => {
  open LogTypes
  open APIUtils
  let getURL = useGetURL()
  let apiLogsUrl = getURL(~entityName=PAYMENT_LOGS, ~methodType=Get, ~id=Some(paymentId), ())
  let sdkLogsUrl = getURL(~entityName=SDK_EVENT_LOGS, ~methodType=Post, ~id=Some(paymentId), ())
  let startTime = createdAt->Date.fromString->Date.getTime -. 1000. *. 60. *. 5.
  let startTime = startTime->Js.Date.fromFloat->Date.toISOString
  let endTime = createdAt->Date.fromString->Date.getTime +. 1000. *. 60. *. 60. *. 3.
  let endTime = endTime->Js.Date.fromFloat->Date.toISOString
  let sdkPostBody =
    [
      ("paymentId", paymentId->JSON.Encode.string),
      (
        "timeRange",
        [("startTime", startTime->JSON.Encode.string), ("endTime", endTime->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]->LogicUtils.getJsonFromArrayOfJson
  let webhookLogsUrl = getURL(
    ~entityName=WEBHOOKS_EVENT_LOGS,
    ~methodType=Get,
    ~id=Some(paymentId),
    (),
  )
  let connectorLogsUrl = getURL(
    ~entityName=CONNECTOR_EVENT_LOGS,
    ~methodType=Get,
    ~id=Some(paymentId),
    (),
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
  ]

  <AuditLogUI id={paymentId} urls logType={#PAYMENT} />
}
