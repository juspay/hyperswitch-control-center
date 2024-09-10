type logType = SDK | API_EVENTS | WEBHOOKS | CONNECTOR

type pageType = [#PAYMENT | #REFUND | #DISPUTE]

type eventLogs = Logdetails | Request | Response | Event | Metadata | Unknown

type logDetails = {
  response: string,
  request: string,
  data: Dict.t<JSON.t>,
}

type selectedObj = {
  value: int,
  optionType: logType,
}

let tabkeys: array<eventLogs> = [Logdetails, Request, Response]

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

let getTabKeyName = (key: eventLogs, option: logType) => {
  switch option {
  | SDK =>
    switch key {
    | Logdetails => "Log Details"
    | Request => "Event"
    | Response => "Metadata"
    | _ => ""
    }
  | _ =>
    switch key {
    | Logdetails => "Log Details"
    | Request => "Request"
    | Response => "Response"
    | _ => ""
    }
  }
}

let getLogTypefromString = log => {
  switch log {
  | "Log Details" => Logdetails
  | "Request" => Request
  | "Response" => Response
  | "Event" => Event
  | "Metadata" => Metadata
  | _ => Unknown
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
        data: initialData,
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
          LogUtils.filteredKeys->Array.includes(key)->not
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
        data: initialData,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: SDK,
      })
    }
  | CONNECTOR => {
      let request = initialData->getString("request", "")
      let response = initialData->getString("masked_response", "")
      setLogDetails(_ => {
        response,
        request,
        data: initialData,
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
        data: initialData,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: WEBHOOKS,
      })
    }
  }
}

type urls = {
  url: string,
  apiMethod: Fetch.requestMethod,
  body?: JSON.t,
}
