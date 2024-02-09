type logType = SDK | API_EVENTS | WEBHOOKS | CONNECTOR

type pageType = [#PAYMENT | #REFUND]

type logDetails = {
  response: string,
  request: string,
}

type selectedObj = {
  value: int,
  optionType: logType,
}

let getLogType = dict => {
  if dict->Dict.get("connector_name")->Option.isSome {
    CONNECTOR
  } else if dict->Dict.get("request_id")->Option.isSome {
    API_EVENTS
  } else if dict->Dict.get("component")->Option.isSome {
    SDK
  } else {
    WEBHOOKS
  }
}
