open LogicUtils
open LogTypes

let sortByStartTime = (log1, log2) => {
  let getStartMs = log => {
    let dict = log->getDictFromJsonObject
    let endMs = dict->getString("created_at", "")->Date.fromString->Date.getTime
    let latencyMs = dict->getFloat("latency", 0.0)
    endMs -. latencyMs
  }
  compareLogic(log2->getStartMs, log1->getStartMs)
}

let reorderLogs = logs => {
  // Find the index of the log with "PaymentsCreate" in the "api_flow" field
  let index =
    logs->Array.findIndex(item =>
      item->getDictFromJsonObject->getString("api_flow", "") == "PaymentsCreate"
    )

  switch index {
  | 0 // If it's already at the first position, return the logs as is
  | -1 => logs // If not found, return the logs as is
  | _ => {
      // If found but not at the first position, move it to the front
      let element = logs->Array.find(item => {
        item->getDictFromJsonObject->getString("api_flow", "") == "PaymentsCreate"
      })

      switch element {
      | Some(val) => {
          let arr = logs->Array.filter(item => item != val)
          [val]->Array.concat(arr)
        }
      | _ => logs
      }
    }
  }
}

type flowType =
  | PaymentsCancel
  | PaymentsCapture
  | PaymentsConfirm
  | PaymentsCreate
  | PaymentsStart
  | PaymentsUpdate
  | RefundsCreate
  | RefundsUpdate
  | DisputesEvidenceSubmit
  | AttachDisputeEvidence
  | RetrieveDisputeEvidence
  | IncomingWebhookReceive
  | NotDefined

let itemToObjMapper = flowString => {
  switch flowString {
  | "PaymentsCancel" => PaymentsCancel
  | "PaymentsCapture" => PaymentsCapture
  | "PaymentsConfirm" => PaymentsConfirm
  | "PaymentsCreate" => PaymentsCreate
  | "PaymentsStart" => PaymentsStart
  | "PaymentsUpdate" => PaymentsUpdate
  | "RefundsCreate" => RefundsCreate
  | "RefundsUpdate" => RefundsUpdate
  | "DisputesEvidenceSubmit" => DisputesEvidenceSubmit
  | "AttachDisputeEvidence" => AttachDisputeEvidence
  | "RetrieveDisputeEvidence" => RetrieveDisputeEvidence
  | "IncomingWebhookReceive" => IncomingWebhookReceive
  | _ => NotDefined
  }
}

// will be removed once the backend does the URl mapping
let nameToURLMapper = (~id, ~merchantId) => {
  urlName =>
    switch urlName->itemToObjMapper {
    | PaymentsCancel => `/payments/${id}/cancel`
    | PaymentsCapture => `/payments/${id}/capture`
    | PaymentsConfirm => `/payments/${id}/confirm`
    | PaymentsCreate => "/payments"
    | PaymentsStart => `/payments/redirect/${id}/${merchantId}`
    | PaymentsUpdate => `/payments/${id}`
    | RefundsCreate => "/refunds"
    | RefundsUpdate => `/refunds/${id}`
    | DisputesEvidenceSubmit | AttachDisputeEvidence => "/disputes/evidence"
    | RetrieveDisputeEvidence => `/disputes/evidence/${id}`
    | IncomingWebhookReceive | NotDefined => urlName
    }
}

let filteredKeys = [
  "value",
  "merchant_id",
  "created_at_precise",
  "component",
  "platform",
  "version",
]

let detailsSectionFilterKeys = [
  "content",
  "created_at",
  "event_type",
  "flow_type",
  "api_flow",
  "request",
  "response",
  "user_agent",
  "ip_addr",
  "flow",
  "masked_response",
  "http_method",
  "hs_latency",
  "latency",
  "status_code",
  "api_auth_type",
  "url_path",
  "error",
]

@module("js-sha256") external sha256: string => string = "sha256"
let parseSdkResponse = arr => {
  let sourceMapper = source => {
    switch source {
    | "ORCA-LOADER" => "HYPERLOADER"
    | "ORCA-PAYMENT-PAGE"
    | "STRIPE_PAYMENT_SHEET" => "PAYMENT_SHEET"
    | other => other
    }
  }

  let sdkLogsArray = arr->Array.map(event => {
    let eventDict = event->getDictFromJsonObject
    let eventName = eventDict->getString("event_name", "")
    let timestamp = eventDict->getString("created_at_precise", "")
    let logType = eventDict->getString("log_type", "")
    let updatedEventName =
      logType === "INFO" ? eventName->String.replace("Call", "Response") : eventName
    eventDict->Dict.set("event_name", updatedEventName->JSON.Encode.string)
    eventDict->Dict.set("event_id", sha256(updatedEventName ++ timestamp)->JSON.Encode.string)
    eventDict->Dict.set(
      "source",
      eventDict->getString("source", "")->sourceMapper->JSON.Encode.string,
    )
    eventDict->Dict.set(
      "checkout_platform",
      eventDict->getString("component", "")->JSON.Encode.string,
    )
    eventDict->Dict.set("customer_device", eventDict->getString("platform", "")->JSON.Encode.string)
    eventDict->Dict.set("sdk_version", eventDict->getString("version", "")->JSON.Encode.string)
    eventDict->Dict.set("event_name", updatedEventName->JSON.Encode.string)
    eventDict->Dict.set("created_at", timestamp->JSON.Encode.string)
    eventDict->JSON.Encode.object
  })
  let logsArr = sdkLogsArray->Array.filter(sdkLog => {
    let eventDict = sdkLog->getDictFromJsonObject
    let eventName = eventDict->getString("event_name", "")
    let filteredEventNames = ["OrcaElementsCalled"]
    filteredEventNames->Array.includes(eventName)->not
  })

  logsArr
}

let apiNameMapper = apiName => {
  switch apiName {
  | "PSync" => "Payments Sync"
  | _ => apiName
  }
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

let isIncomingWebhook = dict =>
  dict->getLogType === API_EVENTS && dict->getString("api_flow", "") === "IncomingWebhookReceive"

let getHeadingLabel = dict => dict->isIncomingWebhook ? "WEBHOOKS" : dict->getLogType->getTagName

let getHeadingIcon = dict =>
  switch dict->getLogType {
  | _ if dict->isIncomingWebhook => "nd-webhook"
  | SDK => "desktop"
  | API_EVENTS => "api-icon"
  | WEBHOOKS => "nd-webhook"
  | CONNECTOR => "connector-icon"
  | ROUTING => "routing"
  }

let getApiName = (dict, ~nameToURLMapper) => {
  switch dict->getLogType {
  | API_EVENTS => dict->getString("api_flow", "default value")->camelCaseToTitle
  | SDK => dict->getString("event_name", "default value")
  | CONNECTOR => dict->getString("flow", "default value")->apiNameMapper->camelCaseToTitle
  | WEBHOOKS => dict->getString("event_type", "default value")->snakeToTitle
  | ROUTING =>
    dict
    ->getString("flow", "")
    ->String.split(" ")
    ->getValueFromArray(1, "default_value")
    ->camelCaseToTitle
  }->nameToURLMapper
}

let getRowTitle = (dict, ~nameToURLMapper) => {
  let apiName = dict->getApiName(~nameToURLMapper)
  switch dict->getLogType {
  | SDK | ROUTING => apiName->String.toLowerCase->snakeToTitle
  | API_EVENTS | WEBHOOKS | CONNECTOR => apiName
  }
}

let getStatusCodeString = dict => {
  switch dict->getLogType {
  | API_EVENTS | CONNECTOR | ROUTING => dict->getInt("status_code", 200)->Int.toString
  | SDK => dict->getString("log_type", "INFO")
  | WEBHOOKS => dict->getBool("is_error", false) ? "500" : "200"
  }
}

let getMethod = dict => {
  switch dict->getLogType {
  | API_EVENTS => dict->getString("http_method", "")
  | CONNECTOR | ROUTING => dict->getString("method", "")
  | SDK => ""
  | WEBHOOKS => "POST"
  }
}

let getUrlPath = dict => {
  switch dict->getLogType {
  | API_EVENTS => dict->getString("url_path", "")
  | SDK | WEBHOOKS | CONNECTOR | ROUTING => ""
  }
}

let getAuthOrigin = dict =>
  switch dict->getString("api_auth_type", "") {
  | "publishable_key" => Sdk
  | "api_key" => Backend
  | "merchant_jwt" | "jwt" => Dashboard
  | "webhook_auth" => Webhook
  | _ => UnknownAuth
  }

let getRowOrigin = dict =>
  switch dict->getLogType {
  | ROUTING | CONNECTOR => BackendOrigin
  | WEBHOOKS => WebhookOrigin
  | SDK => SdkOrigin
  | API_EVENTS =>
    dict->getString("api_flow", "") === "IncomingWebhookReceive"
      ? WebhookOrigin
      : switch dict->getAuthOrigin {
        | Sdk => SdkOrigin
        | Backend | UnknownAuth => BackendOrigin
        | Dashboard => DashboardOrigin
        | Webhook => WebhookOrigin
        }
  }

let originFilterLabel = origin =>
  switch origin {
  | AllOrigins => "All"
  | SdkOrigin => "SDK"
  | BackendOrigin => "Backend"
  | DashboardOrigin => "Dashboard"
  | WebhookOrigin => "Webhooks"
  }

let rowMatchesOrigin = (origin, dict) =>
  switch origin {
  | AllOrigins => true
  | SdkOrigin | BackendOrigin | DashboardOrigin | WebhookOrigin => dict->getRowOrigin == origin
  }

let originFromLabel = label =>
  switch label {
  | "SDK" => SdkOrigin
  | "Backend" => BackendOrigin
  | "Dashboard" => DashboardOrigin
  | "Webhooks" => WebhookOrigin
  | _ => AllOrigins
  }

let selectableOrigins = [SdkOrigin, BackendOrigin, DashboardOrigin, WebhookOrigin]

let getSdkSub = dict =>
  switch dict->getLogType {
  | SDK => dict->getString("category", "") === "API" ? SdkApiCall : SdkUserEvent
  | API_EVENTS | WEBHOOKS | CONNECTOR | ROUTING => SdkApiCall
  }

let sdkFilterLabel = filter =>
  switch filter {
  | AllSdk => "All"
  | SdkUserEvent => "User Event"
  | SdkApiCall => "API"
  }

let rowMatchesSdkFilter = (filter, dict) =>
  switch filter {
  | AllSdk => true
  | SdkUserEvent | SdkApiCall => dict->getSdkSub == filter
  }

let sdkFilterFromLabel = label =>
  switch label {
  | "User Event" => SdkUserEvent
  | "API" => SdkApiCall
  | _ => AllSdk
  }

let selectableSdkFilters = [SdkUserEvent, SdkApiCall]

let getWebhookDirection = (dict, ~logType) =>
  switch logType {
  | WEBHOOKS => Outgoing
  | API_EVENTS =>
    dict->getString("api_flow", "") === "IncomingWebhookReceive" ? Incoming : NoDirection
  | SDK | CONNECTOR | ROUTING => NoDirection
  }

let getOriginLabel = origin =>
  switch origin {
  | SdkOrigin => "SDK"
  | BackendOrigin => "Backend"
  | DashboardOrigin => "Dashboard"
  | WebhookOrigin => "Webhook"
  | AllOrigins => ""
  }

let getOriginIcon = origin =>
  switch origin {
  | SdkOrigin => "desktop"
  | BackendOrigin => "connector-icon"
  | DashboardOrigin => "group-users"
  | WebhookOrigin => "nd-webhook"
  | AllOrigins => "api-icon"
  }

let getSdkCategoryLabel = (dict, ~logType) =>
  switch logType {
  | SDK =>
    switch dict->getString("category", "") {
    | "API" => "API Call"
    | "USER_EVENT" => "User Event"
    | _ => ""
    }
  | API_EVENTS | WEBHOOKS | CONNECTOR | ROUTING => ""
  }

let formatMilliseconds = ms => `${ms->Float.toInt->Int.toString}ms`

let getLatencyText = (dict, ~logType) => {
  let latencyMs = dict->getFloat("latency", 0.0)
  switch logType {
  | API_EVENTS | CONNECTOR => latencyMs > 0.0 ? latencyMs->formatMilliseconds : ""
  | SDK | WEBHOOKS | ROUTING => ""
  }
}

let getIsFailed = (dict, ~logType) =>
  switch logType {
  | API_EVENTS | CONNECTOR => dict->getInt("status_code", 200) >= 400
  | SDK | WEBHOOKS | ROUTING => false
  }

let getRequestObject = (dict, ~logType, ~filteredKeys) =>
  switch logType {
  | API_EVENTS | CONNECTOR | ROUTING => dict->getString("request", "")
  | SDK =>
    dict
    ->Dict.toArray
    ->Array.filter(entry => {
      let (key, _) = entry
      filteredKeys->Array.includes(key)->not
    })
    ->getJsonFromArrayOfJson
    ->JSON.stringify
  | WEBHOOKS => dict->getString("content", "")
  }

let getEventCode = (requestObject, ~logType) =>
  switch logType {
  | API_EVENTS | CONNECTOR | ROUTING | WEBHOOKS =>
    let requestDict = requestObject->safeParse->getDictFromJsonObject
    [requestDict->getString("eventCode", ""), requestDict->getString("event_code", "")]
    ->Array.find(isNonEmptyString)
    ->Option.getOr("")
  | SDK => ""
  }

let getResponseObject = (dict, ~logType) =>
  switch logType {
  | API_EVENTS | ROUTING => dict->getString("response", "")
  | CONNECTOR => dict->getString("masked_response", "")
  | SDK => {
      let isErrorLog = dict->getString("log_type", "") === "ERROR"
      isErrorLog ? dict->getString("value", "") : ""
    }
  | WEBHOOKS => dict->getString("outgoing_webhook_event_type", "")
  }

let getStatusCodeTextColor = (logType, statusCode) =>
  switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => "nd_primary_blue-500"
    | "ERROR" => "nd_red-400"
    | "WARNING" => "nd_yellow-700"
    | _ => "nd_gray-700 opacity-50"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "nd_green-600"
    | "500" => "nd_red-500"
    | _ => "nd_gray-700 opacity-50"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "nd_green-600"
    | "500" => "nd_red-500"
    | "400" | "422" => "nd_orange-600"
    | _ => "nd_gray-700 opacity-50"
    }
  }

let getStatusCodeBg = (logType, statusCode) =>
  switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => "nd_primary_blue-100"
    | "ERROR" => "nd_red-100"
    | "WARNING" => "nd_yellow-100"
    | _ => "nd_gray-100"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "nd_green-50"
    | "500" => "nd_red-50"
    | _ => "nd_gray-100"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "nd_green-50"
    | "500" => "nd_red-50"
    | "400" | "422" => "nd_orange-100"
    | _ => "nd_gray-100"
    }
  }

let getStepperColor = (logType, statusCode) =>
  switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => "nd_primary_blue-500"
    | "ERROR" => "nd_red-400"
    | "WARNING" => "nd_yellow-300"
    | _ => "nd_gray-700 opacity-50"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "nd_green-500"
    | "500" => "nd_red-500"
    | _ => "nd_gray-700 opacity-50"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "nd_green-500"
    | "500" => "nd_red-500"
    | "400" | "422" => "nd_orange-300"
    | _ => "nd_gray-700 opacity-50"
    }
  }

let getStepperBorderColor = (logType, statusCode) =>
  switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => "nd_primary_blue-500"
    | "ERROR" => "nd_red-400"
    | "WARNING" => "nd_orange-300"
    | _ => "nd_gray-600"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "nd_green-500"
    | "500" | _ => "nd_gray-700 opacity-50"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "nd_green-500"
    | "500" => "nd_gray-600"
    | "400" | "422" => "nd_orange-300"
    | _ => "nd_gray-600"
    }
  }

let getStatusCodeBorderColor = (logType, statusCode, ~primaryBorder) =>
  switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => `${primaryBorder}`
    | "ERROR" => "border border-nd_red-400"
    | "WARNING" => "border border-nd_yellow-700"
    | _ => "border border-nd_gray-700 opacity-50"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "border border-nd_green-500"
    | "500" | _ => "border border-nd_gray-700 opacity-80"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "border border-nd_green-500"
    | "500" => "border border-nd_gray-700 opacity-50"
    | "400" | "422" => "border border-nd_orange-600"
    | _ => "border border-nd_gray-700 opacity-50"
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
  | _ => UnknownEvent
  }
}

let setDefaultValue = (initialData, setLogDetails, setSelectedOption) => {
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
          filteredKeys->Array.includes(key)->not
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
