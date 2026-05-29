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
  let apiName = switch logType {
  | API_EVENTS => dataDict->getString("api_flow", "default value")->camelCaseToTitle
  | SDK => dataDict->getString("event_name", "default value")
  | CONNECTOR =>
    dataDict->getString("flow", "default value")->LogUtils.apiNameMapper->camelCaseToTitle
  | WEBHOOKS => dataDict->getString("event_type", "default value")->snakeToTitle
  | ROUTING =>
    dataDict
    ->getString("flow", "")
    ->String.split(" ")
    ->Array.get(1)
    ->Option.getOr("default_value")
    ->camelCaseToTitle
  }->nameToURLMapper
  let endMs = dataDict->getString("created_at", "")->Date.fromString->Date.getTime
  let latencyMs = dataDict->getFloat("latency", 0.0)
  let startTime = (endMs -. latencyMs)->Date.fromTime->Date.toISOString
  let latencyText = LogUtils.formatDuration(latencyMs)

  let responseDict = switch logType {
  | API_EVENTS => dataDict->getString("response", "")->safeParse->getDictFromJsonObject
  | _ => Dict.make()
  }
  let paymentStatus = responseDict->getString("status", "")
  let connectorName = dataDict->getString("connector_name", "")
  let retryCount = dataDict->getInt("retry_count", 1)

  let failureReason = switch logType {
  | API_EVENTS =>
    switch paymentStatus->HSwitchOrderUtils.statusVariantMapper {
    | Failed =>
      let msg = responseDict->getString("error_message", "")
      msg->isNonEmptyString ? msg : responseDict->getString("unified_message", "")
    | _ => ""
    }
  | CONNECTOR =>
    dataDict->getInt("status_code", 200) >= 400
      ? dataDict->getString("error", "")->safeParse->getDictFromJsonObject->getString("message", "")
      : ""
  | WEBHOOKS =>
    dataDict->getBool("is_error", false) ? dataDict->getString("error", "")->camelCaseToTitle : ""
  | SDK | ROUTING => ""
  }
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

  let responseObject = switch logType {
  | API_EVENTS | ROUTING => dataDict->getString("response", "")
  | CONNECTOR => dataDict->getString("masked_response", "")
  | SDK => {
      let isErrorLog = dataDict->getString("log_type", "") === "ERROR"
      isErrorLog ? dataDict->getString("value", "") : ""
    }
  | WEBHOOKS => dataDict->getString("outgoing_webhook_event_type", "")
  }

  let statusCode = switch logType {
  | API_EVENTS | CONNECTOR | ROUTING => dataDict->getInt("status_code", 200)->Int.toString
  | SDK => dataDict->getString("log_type", "INFO")
  | WEBHOOKS => dataDict->getBool("is_error", false) ? "Failed" : "Delivered"
  }

  let method = switch logType {
  | API_EVENTS => dataDict->getString("http_method", "")
  | CONNECTOR | ROUTING => dataDict->getString("method", "")
  | SDK => ""
  | WEBHOOKS => "POST"
  }

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
    | "Delivered" => "green-700"
    | "Failed" => "red-500"
    | _ => "gray-700 opacity-50"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "green-700"
    | "500" => "gray-700 opacity-50"
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
    | "Delivered" => "green-50"
    | "Failed" => "red-50"
    | _ => "gray-100"
    }
  | API_EVENTS | CONNECTOR | ROUTING =>
    switch statusCode {
    | "200" => "green-50"
    | "500" => "gray-100"
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
        | "Delivered" => "green-700"
        | "Failed" => "red-400"
        | _ => "gray-700 opacity-50"
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
        | "Delivered" => "green-700"
        | "Failed" => "red-400"
        | _ => "gray-700 opacity-50"
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
    | "Delivered" => "border border-green-700"
    | "Failed" => "border border-red-400"
    | _ => "border border-gray-700 opacity-80"
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

  let iconName = switch logType {
  | SDK => "desktop"
  | WEBHOOKS => "anchor"
  | API_EVENTS => "api-icon"
  | CONNECTOR => "connector-icon"
  | ROUTING => "routing"
  }

  <div className="flex items-start gap-4">
    <div className="flex flex-col items-center h-full my-4 relative">
      <RenderIf condition={showLogType}>
        <Icon name=iconName size=12 className="text-jp-gray-900" />
        <div
          className={`h-full border-${stepperBorderColor} border-dashed rounded  divide-x-2 border-2 my-1`}
        />
      </RenderIf>
      <div className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-gray-300`} />
      <div
        className={`h-full border-${stepperBorderColor} border-dashed rounded  divide-x-2 border-2 my-1`}
      />
      <RenderIf condition={index === logsDataLength}>
        <div className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-gray-300`} />
      </RenderIf>
    </div>
    <div className="flex flex-col gap-3 w-full">
      <RenderIf condition={showLogType}>
        <span
          className={`text-base font-bold break-all flex gap-1 leading-none my-4 text-jp-gray-900`}>
          {`${logType->getTagName}`->React.string}
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
        <div className="flex flex-col gap-1">
          <div className="flex gap-3 items-center">
            <div className={`bg-${statusCodeBg} h-fit w-fit px-2 py-0.5 rounded-md`}>
              <p className={`${body.sm.semibold} text-${statusCodeTextColor}`}>
                {statusCode->React.string}
              </p>
            </div>
            {switch logType {
            | SDK | ROUTING =>
              <p className={`${body.md.semibold} text-gray-800 ${isSelected ? "" : "opacity-80"}`}>
                {apiName->String.toLowerCase->snakeToTitle->React.string}
              </p>
            | API_EVENTS | WEBHOOKS | CONNECTOR =>
              <div
                className={`flex flex-wrap items-center gap-x-2 gap-y-1 ${isSelected
                    ? ""
                    : "opacity-80"}`}>
                <span
                  className={`${code.md.medium} text-gray-500 border border-gray-200 px-2 py-0.5 rounded`}>
                  {method->String.toUpperCase->React.string}
                </span>
                <span className={`${body.md.semibold} text-gray-800`}>
                  {apiName->React.string}
                </span>
                <RenderIf condition={logType == CONNECTOR && connectorName->isNonEmptyString}>
                  <span
                    className={`${body.sm.semibold} text-gray-600 capitalize whitespace-nowrap`}>
                    {connectorName->React.string}
                  </span>
                </RenderIf>
                <RenderIf condition={logType == WEBHOOKS && retryCount > 1}>
                  <span
                    className={`${body.xs.medium} text-gray-500 bg-gray-50 border border-gray-200 px-2 py-0.5 rounded-full whitespace-nowrap`}>
                    {`${retryCount->Int.toString} attempts`->React.string}
                  </span>
                </RenderIf>
              </div>
            }}
          </div>
          <div className={`${body.sm.regular} text-gray-400 flex gap-2 items-center`}>
            <TableUtils.DateCell timestamp=startTime />
            <RenderIf condition={latencyText->isNonEmptyString}>
              <span> {`• ${latencyText}`->React.string} </span>
            </RenderIf>
          </div>
          <RenderIf condition={failureReason->isNonEmptyString}>
            <p className={`${body.sm.medium} text-red-500 mt-1 break-words`}>
              {failureReason->React.string}
            </p>
          </RenderIf>
        </div>
      </div>
    </div>
  </div>
}
