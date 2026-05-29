type logType = SDK | API_EVENTS | WEBHOOKS | CONNECTOR | ROUTING

type pageType = [#PAYMENT | #REFUND | #DISPUTE | #PAYOUT]

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

type trailSummary = {
  finalStatus: string,
  connector: string,
  totalDurationMs: float,
  stepCount: int,
}

let tabkeys: array<eventLogs> = [Logdetails, Request, Response]

let getLogType = dict => {
  if dict->Dict.get("routing_engine")->Option.isSome {
    ROUTING
  } else if dict->Dict.get("connector_name")->Option.isSome {
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
  | ROUTING => "ROUTING"
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
  | WEBHOOKS =>
    switch key {
    | Logdetails => "Log Details"
    | Request => "Event Data"
    | Response => "Response"
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
  | "Event Data"
  | "Request" =>
    Request
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
  | ROUTING => {
      let request = initialData->getString("request", "")
      let response = initialData->getString("response", "")
      setLogDetails(_ => {
        response,
        request,
        data: initialData,
      })
      setSelectedOption(_ => {
        value: 0,
        optionType: ROUTING,
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
      let request = initialData->getString("content", "")
      let response = initialData->getString("outgoing_webhook_event_type", "")
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

let getTrailSummary = (logs): trailSummary => {
  open LogicUtils
  let getCreatedMs = dict => dict->getString("created_at", "")->Date.fromString->Date.getTime

  let (minStart, maxEnd) = logs->Array.reduce((None, None), (acc, log) => {
    let (minS, maxE) = acc
    let dict = log->getDictFromJsonObject
    let endMs = dict->getCreatedMs
    let startMs = endMs -. dict->getFloat("latency", 0.0)
    let newMin = switch minS {
    | Some(m) => startMs < m ? startMs : m
    | None => startMs
    }
    let newMax = switch maxE {
    | Some(m) => endMs > m ? endMs : m
    | None => endMs
    }
    (Some(newMin), Some(newMax))
  })
  let totalDurationMs = switch (minStart, maxEnd) {
  | (Some(minS), Some(maxE)) => maxE > minS ? maxE -. minS : 0.0
  | _ => 0.0
  }

  let (finalStatus, _) = logs->Array.reduce(("", 0.0), (acc, log) => {
    let (_, ms) = acc
    let dict = log->getDictFromJsonObject
    switch dict->getLogType {
    | API_EVENTS => {
        let createdMs = dict->getCreatedMs
        let respStatus =
          dict->getString("response", "")->safeParse->getDictFromJsonObject->getString("status", "")
        respStatus->isNonEmptyString && createdMs >= ms ? (respStatus, createdMs) : acc
      }
    | _ => acc
    }
  })

  let (connector, _) = logs->Array.reduce(("", 0.0), (acc, log) => {
    let (_, ms) = acc
    let dict = log->getDictFromJsonObject
    let createdMs = dict->getCreatedMs
    let candidate = switch dict->getLogType {
    | CONNECTOR => dict->getString("connector_name", "")
    | API_EVENTS =>
      dict->getString("response", "")->safeParse->getDictFromJsonObject->getString("connector", "")
    | _ => ""
    }
    candidate->isNonEmptyString && createdMs >= ms ? (candidate, createdMs) : acc
  })

  {finalStatus, connector, totalDurationMs, stepCount: logs->Array.length}
}

let collapseWebhookRetries = logs => {
  open LogicUtils
  logs->Array.reduce([], (acc, log) => {
    let dict = log->getDictFromJsonObject
    let isWebhook = dict->getLogType == WEBHOOKS
    let eventType = dict->getString("event_type", "")
    let isError = dict->getBool("is_error", false)
    switch acc->Array.get(acc->Array.length - 1) {
    | Some(prev) => {
        let prevDict = prev->getDictFromJsonObject
        let prevIsWebhook = prevDict->getLogType == WEBHOOKS
        let prevEventType = prevDict->getString("event_type", "")
        let prevIsError = prevDict->getBool("is_error", false)
        if isWebhook && prevIsWebhook && eventType == prevEventType && isError == prevIsError {
          let merged = dict->Dict.copy
          merged->Dict.set("retry_count", (prevDict->getInt("retry_count", 1) + 1)->JSON.Encode.int)
          if (
            merged->getString("content", "")->isEmptyString &&
              prevDict->getString("content", "")->isNonEmptyString
          ) {
            merged->Dict.set("content", prevDict->getString("content", "")->JSON.Encode.string)
          }
          acc
          ->Array.slice(~start=0, ~end=acc->Array.length - 1)
          ->Array.concat([merged->JSON.Encode.object])
        } else {
          acc->Array.concat([log])
        }
      }
    | None => acc->Array.concat([log])
    }
  })
}
