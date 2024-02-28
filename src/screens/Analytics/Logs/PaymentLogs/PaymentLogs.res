@react.component
let make = (~paymentId, ~createdAt, ~data: OrderTypes.order) => {
  open APIUtils
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let fetchPostDetils = useUpdateMethod()
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
    ]->getJsonFromArrayOfJson
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

  let promiseArr = [
    fetchDetails(apiLogsUrl),
    fetchPostDetils(sdkLogsUrl, sdkPostBody, Post, ()),
    fetchDetails(webhookLogsUrl),
  ]

  switch data.connector->ConnectorUtils.getConnectorNameTypeFromString() {
  | Processors(connector) =>
    if LogUtils.responseMaskingSupportedConectors->Array.includes(connector) {
      promiseArr->Array.concat([fetchDetails(connectorLogsUrl)])->ignore
    }
  | _ => ()
  }

  <AuditLogUI id={paymentId} promiseArr logType={#PAYMENT} />
}
