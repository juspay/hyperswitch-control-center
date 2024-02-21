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

let getTagName = tag => {
  switch tag {
  | SDK => "SDK"
  | API_EVENTS => "API"
  | WEBHOOKS => "WEBHOOKS"
  | CONNECTOR => "CONNECTOR"
  }
}

let setDefaultValue = (initialData, setLogDetails, setSelectedOption) => {
  open LogicUtils
  switch initialData->getLogType {
  | API_EVENTS => {
      let request = initialData->getString("request", "")
      let response = initialData->getString("response", "")
      setLogDetails(_ => {
        response,
        request,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: API_EVENTS,
      })
    }
  | SDK => {
      let request =
        initialData
        ->Dict.toArray
        ->Array.filter(entry => {
          let (key, _) = entry
          PaymentLogsUtils.filteredKeys->Array.includes(key)->not
        })
        ->getJsonFromArrayOfJson
        ->JSON.stringify
      let response =
        initialData->getString("log_type", "") === "ERROR"
          ? initialData->getString("value", "")
          : ""
      setLogDetails(_ => {
        response,
        request,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: SDK,
      })
    }
  | CONNECTOR => {
      let request = initialData->getString("request", "")
      let response = initialData->getString("response", "")
      setLogDetails(_ => {
        response,
        request,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: CONNECTOR,
      })
    }
  | WEBHOOKS => {
      let request = initialData->getString("outgoing_webhook_event_type", "")
      let response = initialData->getString("content", "")
      setLogDetails(_ => {
        response,
        request,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: WEBHOOKS,
      })
    }
  }
}
