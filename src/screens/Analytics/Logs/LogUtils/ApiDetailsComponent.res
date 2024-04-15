open LogicUtils
open LogTypes
@react.component
let make = (
  ~dataDict,
  ~setLogDetails,
  ~setSelectedOption,
  ~currentSelected: int,
  ~index,
  ~logsDataLength,
  ~getLogType,
  ~nameToURLMapper,
  ~filteredKeys=[],
) => {
  let {globalUIConfig: {border: {borderColor}}} = React.useContext(ConfigContext.configContext)
  let headerStyle = "text-sm font-medium text-gray-700 break-all"
  let logType = dataDict->getLogType
  let apiName = switch logType {
  | API_EVENTS => dataDict->getString("api_flow", "default value")->camelCaseToTitle
  | SDK => dataDict->getString("event_name", "default value")
  | CONNECTOR => dataDict->getString("flow", "default value")->camelCaseToTitle
  | WEBHOOKS => dataDict->getString("event_type", "default value")->snakeToTitle
  }->nameToURLMapper
  let createdTime = dataDict->getString("created_at", "00000")
  let requestObject = switch logType {
  | API_EVENTS | CONNECTOR => dataDict->getString("request", "")
  | SDK =>
    dataDict
    ->Dict.toArray
    ->Array.filter(entry => {
      let (key, _) = entry
      filteredKeys->Array.includes(key)->not
    })
    ->getJsonFromArrayOfJson
    ->JSON.stringify
  | WEBHOOKS => dataDict->getString("outgoing_webhook_event_type", "")
  }

  let responseObject = switch logType {
  | API_EVENTS => dataDict->getString("response", "")
  | CONNECTOR => dataDict->getString("masked_response", "")
  | SDK => {
      let isErrorLog = dataDict->getString("log_type", "") === "ERROR"
      isErrorLog ? dataDict->getString("value", "") : ""
    }
  | WEBHOOKS => dataDict->getString("content", "")
  }

  let statusCode = switch logType {
  | API_EVENTS | CONNECTOR => dataDict->getInt("status_code", 200)->Int.toString
  | SDK => dataDict->getString("log_type", "INFO")
  | WEBHOOKS => dataDict->getBool("is_error", false) ? "500" : "200"
  }

  let method = switch logType {
  | API_EVENTS => dataDict->getString("http_method", "")
  | CONNECTOR => dataDict->getString("method", "")
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
    | "200" => "green-700"
    | "500" | _ => "gray-700 opacity-50"
    }
  | API_EVENTS | CONNECTOR =>
    switch statusCode {
    | "200" => "green-700"
    | "500" => "gray-700 opacity-50"
    | "400" => "yellow-800"
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
    | "200" => "green-200"
    | "500" | _ => "gray-100"
    }
  | API_EVENTS | CONNECTOR =>
    switch statusCode {
    | "200" => "green-200"
    | "500" => "gray-100"
    | "400" => "orange-100"
    | _ => "gray-100"
    }
  }

  let isSelected = currentSelected === index

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
      | API_EVENTS | CONNECTOR =>
        switch statusCode {
        | "200" => "green-700"
        | "500" => "gray-700 opacity-50"
        | "400" => "yellow-300"
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
        | "500" | _ => "gray-600"
        }
      | API_EVENTS | CONNECTOR =>
        switch statusCode {
        | "200" => "green-700"
        | "500" => "gray-600"
        | "400" => "orange-500"
        | _ => "gray-600"
        }
      }
    : "gray-200"

  let borderClass = isSelected
    ? `${borderColor.primaryNormal} rounded-md`
    : "border border-transparent"

  <div className="flex items-start gap-4">
    <div className="flex flex-col items-center h-full">
      <div className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-gray-300`} />
      <UIUtils.RenderIf condition={index !== logsDataLength}>
        <div
          className={`h-full border-${stepperBorderColor} border-dashed rounded divide-x-2 border-2 my-1`}
        />
      </UIUtils.RenderIf>
    </div>
    <div
      className={`flex gap-6 items-start w-full py-3 px-3 cursor-pointer ${borderClass} -mt-5 mb-8`}
      key={currentSelected->Int.toString}
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
        <div className=" flex gap-3">
          <div className={`bg-${statusCodeBg} h-fit w-fit px-2 py-1 rounded-md`}>
            <p className={`text-${statusCodeTextColor} text-sm opacity-100  font-bold `}>
              {statusCode->React.string}
            </p>
          </div>
          {switch logType {
          | SDK =>
            <p className={`${headerStyle} mt-1 ${isSelected ? "" : "opacity-80"}`}>
              {apiName->String.toLowerCase->snakeToTitle->React.string}
            </p>
          | API_EVENTS | WEBHOOKS | CONNECTOR =>
            <p className={`${headerStyle} ${isSelected ? "" : "opacity-80"}`}>
              <span className="mr-3 border-2 px-1 py-0.5 rounded text-sm">
                {method->String.toUpperCase->React.string}
              </span>
              <span className="leading-7"> {apiName->React.string} </span>
            </p>
          }}
        </div>
        <div className={`${headerStyle} opacity-40 flex gap-1`}>
          {createdTime->Js.Date.fromString->Js.Date.toUTCString->React.string}
          <span> {`, [ ${logType->getTagName} ]`->React.string} </span>
        </div>
      </div>
    </div>
  </div>
}
