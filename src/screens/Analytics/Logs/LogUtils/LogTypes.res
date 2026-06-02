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
  dict->getLogType === API_EVENTS &&
    dict->LogicUtils.getString("api_flow", "") === "IncomingWebhookReceive"

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
  open LogicUtils
  switch dict->getLogType {
  | API_EVENTS => dict->getString("api_flow", "default value")->camelCaseToTitle
  | SDK => dict->getString("event_name", "default value")
  | CONNECTOR => dict->getString("flow", "default value")->LogUtils.apiNameMapper->camelCaseToTitle
  | WEBHOOKS => dict->getString("event_type", "default value")->snakeToTitle
  | ROUTING =>
    dict
    ->getString("flow", "")
    ->String.split(" ")
    ->Array.get(1)
    ->Option.getOr("default_value")
    ->camelCaseToTitle
  }->nameToURLMapper
}

let getRowTitle = (dict, ~nameToURLMapper) => {
  open LogicUtils
  let apiName = dict->getApiName(~nameToURLMapper)
  switch dict->getLogType {
  | SDK | ROUTING => apiName->String.toLowerCase->snakeToTitle
  | API_EVENTS | WEBHOOKS | CONNECTOR => apiName
  }
}

let getStatusCodeString = dict => {
  open LogicUtils
  switch dict->getLogType {
  | API_EVENTS | CONNECTOR | ROUTING => dict->getInt("status_code", 200)->Int.toString
  | SDK => dict->getString("log_type", "INFO")
  | WEBHOOKS => dict->getBool("is_error", false) ? "500" : "200"
  }
}

let getMethod = dict => {
  open LogicUtils
  switch dict->getLogType {
  | API_EVENTS => dict->getString("http_method", "")
  | CONNECTOR | ROUTING => dict->getString("method", "")
  | SDK => ""
  | WEBHOOKS => "POST"
  }
}

let getUrlPath = dict => {
  open LogicUtils
  switch dict->getLogType {
  | API_EVENTS => dict->getString("url_path", "")
  | SDK | WEBHOOKS | CONNECTOR | ROUTING => ""
  }
}

type authOrigin = Sdk | Backend | Dashboard | Webhook | UnknownAuth

let getAuthOrigin = dict =>
  switch dict->LogicUtils.getString("api_auth_type", "") {
  | "publishable_key" => Sdk
  | "api_key" => Backend
  | "merchant_jwt" | "jwt" => Dashboard
  | "webhook_auth" => Webhook
  | _ => UnknownAuth
  }

type originFilter = AllOrigins | SdkOrigin | BackendOrigin | DashboardOrigin | WebhookOrigin

let getRowOrigin = dict =>
  switch dict->getLogType {
  | ROUTING | CONNECTOR => BackendOrigin
  | WEBHOOKS => WebhookOrigin
  | SDK => SdkOrigin
  | API_EVENTS =>
    dict->LogicUtils.getString("api_flow", "") === "IncomingWebhookReceive"
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

type sdkFilter = AllSdk | SdkUserEvent | SdkApiCall

let getSdkSub = dict =>
  switch dict->getLogType {
  | SDK => dict->LogicUtils.getString("category", "") === "API" ? SdkApiCall : SdkUserEvent
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
