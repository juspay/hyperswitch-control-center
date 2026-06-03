open LogicUtils
open LogTypes
open Typography
@react.component
let make = (
  ~dataDict,
  ~setLogDetails,
  ~selectedOption,
  ~setSelectedOption,
  ~index,
  ~logsDataLength,
  ~getLogType,
  ~nameToURLMapper,
  ~filteredKeys=[],
  ~showLogType=true,
) => {
  let {globalUIConfig: {border: {borderColor}}} = React.useContext(ThemeProvider.themeContext)
  let logType = dataDict->getLogType
  let endMs = dataDict->getString("created_at", "")->Date.fromString->Date.getTime
  let latencyMs = dataDict->getFloat("latency", 0.0)
  let startTime = (endMs -. latencyMs)->Date.fromTime->Date.toISOString
  let requestObject = switch logType {
  | API_EVENTS | CONNECTOR | ROUTING => dataDict->getString("request", "")
  | SDK =>
    dataDict
    ->Dict.toArray
    ->Array.filter(entry => {
      let (key, _) = entry
      filteredKeys->Array.includes(key)->not
    })
    ->getJsonFromArrayOfJson
    ->JSON.stringify
  | WEBHOOKS => dataDict->getString("content", "")
  }

  let eventCode = switch logType {
  | API_EVENTS | CONNECTOR | ROUTING | WEBHOOKS =>
    let requestDict = requestObject->safeParse->getDictFromJsonObject
    [requestDict->getString("eventCode", ""), requestDict->getString("event_code", "")]
    ->Array.find(isNonEmptyString)
    ->Option.getOr("")
  | SDK => ""
  }

  let responseObject = switch logType {
  | API_EVENTS | ROUTING => dataDict->getString("response", "")
  | CONNECTOR => dataDict->getString("masked_response", "")
  | SDK => {
      let isErrorLog = dataDict->getString("log_type", "") === "ERROR"
      isErrorLog ? dataDict->getString("value", "") : ""
    }
  | WEBHOOKS => dataDict->getString("outgoing_webhook_event_type", "")
  }

  let statusCode = dataDict->getStatusCodeString

  let method = dataDict->getMethod

  let statusCodeTextColor = switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => "blue-500"
    | "ERROR" => "red-400"
    | "WARNING" => "yellow-800"
    | _ => "gray-700 opacity-50"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "green-700"
    | "500" => "red-700"
    | _ => "gray-700 opacity-50"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "green-700"
    | "500" => "red-700"
    | "400" | "422" => "orange-950"
    | _ => "gray-700 opacity-50"
    }
  }

  let statusCodeBg = switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => "blue-100"
    | "ERROR" => "red-100"
    | "WARNING" => "yellow-100"
    | _ => "gray-100"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "green-50"
    | "500" => "red-50"
    | _ => "gray-100"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "green-50"
    | "500" => "red-50"
    | "400" | "422" => "orange-100"
    | _ => "gray-100"
    }
  }

  let isSelected = selectedOption.value === index

  let stepperColor = isSelected
    ? switch logType {
      | SDK =>
        switch statusCode {
        | "INFO" => "blue-500"
        | "ERROR" => "red-400"
        | "WARNING" => "yellow-300"
        | _ => "gray-700 opacity-50"
        }
      | WEBHOOKS =>
        switch statusCode {
        | "200" => "green-700"
        | "500" | _ => "gray-700 opacity-50"
        }
      | API_EVENTS | CONNECTOR | ROUTING =>
        switch statusCode {
        | "200" => "green-700"
        | "500" => "gray-700 opacity-50"
        | "400" | "422" => "orange-950"
        | _ => "gray-700 opacity-50"
        }
      }
    : "gray-200"
  let stepperBorderColor = isSelected
    ? switch logType {
      | SDK =>
        switch statusCode {
        | "INFO" => "blue-500"
        | "ERROR" => "red-400"
        | "WARNING" => "orange-500"
        | _ => "gray-600"
        }
      | WEBHOOKS =>
        switch statusCode {
        | "200" => "green-700"
        | "500" | _ => "gray-700 opacity-50"
        }
      | API_EVENTS | CONNECTOR | ROUTING =>
        switch statusCode {
        | "200" => "green-700"
        | "500" => "gray-600"
        | "400" | "422" => "orange-950"
        | _ => "gray-600"
        }
      }
    : "gray-200"

  let statusCodeBorderColor = switch logType {
  | SDK =>
    switch statusCode {
    | "INFO" => `${borderColor.primaryNormal}`
    | "ERROR" => "border border-red-400"
    | "WARNING" => "border border-yellow-800"
    | _ => "border border-gray-700 opacity-50"
    }
  | WEBHOOKS =>
    switch statusCode {
    | "200" => "border border-green-700"
    | "500" | _ => "border border-gray-700 opacity-80"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "border border-green-700"
    | "500" => "border border-gray-700 opacity-50"
    | "400" | "422" => "border border-orange-950"
    | _ => "border border-gray-700 opacity-50"
    }
  }

  let borderClass = isSelected ? `${statusCodeBorderColor} rounded-md` : "border border-transparent"

  let rowOrigin = dataDict->getRowOrigin

  let originLabel = switch rowOrigin {
  | SdkOrigin => "SDK"
  | BackendOrigin => "Backend"
  | DashboardOrigin => "Dashboard"
  | WebhookOrigin => "Webhook"
  | AllOrigins => ""
  }

  let originIcon = switch rowOrigin {
  | SdkOrigin => "desktop"
  | BackendOrigin => "connector-icon"
  | DashboardOrigin => "group-users"
  | WebhookOrigin => "nd-webhook"
  | AllOrigins => "api-icon"
  }

  let webhookDirection = switch logType {
  | WEBHOOKS => "Outgoing"
  | API_EVENTS =>
    switch dataDict->getString("api_flow", "") {
    | "IncomingWebhookReceive" => "Incoming"
    | _ => ""
    }
  | SDK | CONNECTOR | ROUTING => ""
  }

  let urlPath = dataDict->getUrlPath

  let sdkCategoryLabel = switch logType {
  | SDK =>
    switch dataDict->getString("category", "") {
    | "API" => "API Call"
    | "USER_EVENT" => "User Event"
    | _ => ""
    }
  | API_EVENTS | WEBHOOKS | CONNECTOR | ROUTING => ""
  }

  let formatMilliseconds = ms => `${ms->Float.toInt->Int.toString}ms`

  let latencyText = switch logType {
  | API_EVENTS | CONNECTOR => latencyMs > 0.0 ? latencyMs->formatMilliseconds : ""
  | SDK | WEBHOOKS | ROUTING => ""
  }

  let isFailed = switch logType {
  | API_EVENTS | CONNECTOR => dataDict->getInt("status_code", 200) >= 400
  | SDK | WEBHOOKS | ROUTING => false
  }

  let title = dataDict->getRowTitle(~nameToURLMapper)

  let (qualifierLabel, qualifierIcon) = if webhookDirection->isNonEmptyString {
    (webhookDirection, webhookDirection === "Incoming" ? "arrow-down" : "arrow-up")
  } else if sdkCategoryLabel->isNonEmptyString {
    (sdkCategoryLabel, sdkCategoryLabel === "API Call" ? "api-icon" : "user")
  } else {
    ("", "")
  }

  <div className="flex items-start gap-4">
    <div className="flex flex-col items-center h-full my-4 relative">
      <RenderIf condition={showLogType}>
        <Icon name={dataDict->getHeadingIcon} size=12 className="text-nd_gray-800" />
        <div
          className={`h-full border-${stepperBorderColor} border-dashed rounded  divide-x-2 border-2 my-1`}
        />
      </RenderIf>
      <div className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-nd_gray-300`} />
      <div
        className={`h-full border-${stepperBorderColor} border-dashed rounded  divide-x-2 border-2 my-1`}
      />
      <RenderIf condition={index === logsDataLength}>
        <div
          className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-nd_gray-300`}
        />
      </RenderIf>
    </div>
    <div className="flex flex-col gap-3 w-full min-w-0">
      <RenderIf condition={showLogType}>
        <span className={`${body.lg.bold} break-all flex gap-1 leading-none my-4 text-nd_gray-800`}>
          {dataDict->getHeadingLabel->React.string}
        </span>
      </RenderIf>
      <div
        className={`flex gap-6 items-start w-full py-3 px-3 cursor-pointer ${borderClass} mb-6
        `}
        key={selectedOption.value->Int.toString}
        onClick={_ => {
          setLogDetails(_ => {
            response: responseObject,
            request: requestObject,
            data: dataDict,
          })
          setSelectedOption(_ => {
            value: index,
            optionType: logType,
          })
        }}>
        <div className="flex flex-col gap-1.5 w-full min-w-0">
          <div className="flex items-start justify-between gap-3 w-full">
            <div className="flex items-center gap-2 flex-wrap">
              <div className={`bg-${statusCodeBg} h-fit w-fit px-2 py-0.5 rounded-md`}>
                <p className={`text-${statusCodeTextColor} ${body.md.bold}`}>
                  {statusCode->React.string}
                </p>
              </div>
              <p
                className={`${body.md.semibold} text-nd_gray-800 break-all ${isSelected
                    ? ""
                    : "opacity-90"}`}>
                {title->React.string}
              </p>
            </div>
            <RenderIf condition={latencyText->isNonEmptyString}>
              <p
                className={`${code.md.regular} whitespace-nowrap pt-1 ${isFailed
                    ? `text-${statusCodeTextColor}`
                    : "text-nd_gray-400"}`}>
                {latencyText->React.string}
              </p>
            </RenderIf>
          </div>
          <RenderIf condition={method->isNonEmptyString || urlPath->isNonEmptyString}>
            <div className="flex items-center gap-2 w-full min-w-0">
              <RenderIf condition={method->isNonEmptyString}>
                <span
                  className={`flex-none border border-nd_gray-300 text-nd_gray-500 px-1 py-0.5 rounded ${code.md.regular}`}>
                  {method->String.toUpperCase->React.string}
                </span>
              </RenderIf>
              <RenderIf condition={urlPath->isNonEmptyString}>
                <div className="min-w-0 overflow-hidden">
                  <ToolTipBinding
                    side=ToolTipBinding.Top
                    content={<span className={`${code.md.regular} break-all`}>
                      {urlPath->React.string}
                    </span>}>
                    <span
                      className={`inline-block max-w-full align-middle truncate ${code.md.regular} text-nd_gray-600 bg-nd_gray-50 border border-nd_gray-200 px-1.5 py-0.5 rounded cursor-default`}>
                      {urlPath->React.string}
                    </span>
                  </ToolTipBinding>
                </div>
              </RenderIf>
            </div>
          </RenderIf>
          <div
            className={`flex items-center flex-wrap gap-y-1 gap-x-1.5 ${body.sm.medium} text-nd_gray-500`}>
            <RenderIf condition={eventCode->isNonEmptyString}>
              <span
                className={`inline-flex items-center border border-nd_gray-300 text-nd_gray-600 px-1.5 py-0.5 rounded ${code.md.regular}`}>
                {eventCode->React.string}
              </span>
              <span className="text-nd_gray-300"> {"·"->React.string} </span>
            </RenderIf>
            <RenderIf condition={originLabel->isNonEmptyString}>
              <span className="inline-flex items-center gap-1">
                <Icon name=originIcon size=12 className="text-nd_gray-400" />
                {originLabel->React.string}
              </span>
            </RenderIf>
            <RenderIf condition={qualifierLabel->isNonEmptyString}>
              <span className="text-nd_gray-300"> {"·"->React.string} </span>
              <span className="inline-flex items-center gap-1">
                <Icon name=qualifierIcon size=12 className="text-nd_gray-400" />
                {qualifierLabel->React.string}
              </span>
            </RenderIf>
            <span className="text-nd_gray-300"> {"·"->React.string} </span>
            <TableUtils.DateCell timestamp=startTime />
          </div>
        </div>
      </div>
    </div>
  </div>
}
