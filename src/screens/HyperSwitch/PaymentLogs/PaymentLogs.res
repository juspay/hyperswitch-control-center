@module("js-sha256") external sha256: string => string = "sha256"

open PaymentLogsTypes
let getLogType = dict => {
  if dict->Dict.get("connector_name")->Option.isSome {
    CONNECTOR
  } else if dict->Dict.get("request_id")->Option.isSome {
    PAYMENTS
  } else if dict->Dict.get("component")->Option.isSome {
    SDK
  } else {
    WEBHOOKS
  }
}

module PrettyPrintJson = {
  open LogicUtils
  @react.component
  let make = (
    ~jsonToDisplay,
    ~headerText=None,
    ~maxHeightClass="max-h-25-rem",
    ~overrideBackgroundColor="bg-hyperswitch_background",
  ) => {
    let showToast = ToastState.useShowToast()
    let (isTextVisible, setIsTextVisible) = React.useState(_ => false)
    let (parsedJson, setParsedJson) = React.useState(_ => "")
    let parseJsonValue = () => {
      try {
        let parsedValue = jsonToDisplay->JSON.parseExn->JSON.stringifyWithIndent(3)
        setParsedJson(_ => parsedValue)
      } catch {
      | _ => setParsedJson(_ => jsonToDisplay)
      }
    }
    React.useEffect1(() => {
      parseJsonValue()->ignore
      None
    }, [jsonToDisplay])

    let handleOnClickCopy = (~parsedValue) => {
      Clipboard.writeText(parsedValue)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
    }

    let copyParsedJson =
      <div onClick={_ => handleOnClickCopy(~parsedValue=parsedJson)} className="cursor-pointer">
        <Icon name="copy-code" />
      </div>

    <div className="flex flex-col gap-2">
      <UIUtils.RenderIf condition={parsedJson->isNonEmptyString}>
        {<>
          <UIUtils.RenderIf condition={headerText->Option.isSome}>
            <div className="flex justify-between items-center">
              <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
                {headerText->Option.getOr("")->React.string}
              </p>
              {copyParsedJson}
            </div>
          </UIUtils.RenderIf>
          <div
            className={isTextVisible
              ? "overflow-visible "
              : `overflow-clip  h-fit ${maxHeightClass}`}>
            <ReactSyntaxHighlighter.SyntaxHighlighter
              style={ReactSyntaxHighlighter.lightfair}
              language="json"
              showLineNumbers={true}
              lineNumberContainerStyle={{
                paddingLeft: "0px",
                backgroundColor: "red",
                padding: "100px",
              }}
              customStyle={{
                backgroundColor: "transparent",
                lineHeight: "1.7rem",
                fontSize: "0.875rem",
                padding: "5px",
              }}>
              {parsedJson}
            </ReactSyntaxHighlighter.SyntaxHighlighter>
          </div>
          <Button
            text={isTextVisible ? "Hide" : "See more"}
            customButtonStyle="h-6 w-8 flex flex-1 justify-center m-1"
            onClick={_ => setIsTextVisible(_ => !isTextVisible)}
          />
        </>}
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={parsedJson->isEmptyString}>
        <div className="flex flex-col justify-start items-start gap-2 h-25-rem">
          <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
            {headerText->Option.getOr("")->React.string}
          </p>
          <p className="font-normal text-fs-14 text-jp-gray-900 text-opacity-50">
            {"Failed to load!"->React.string}
          </p>
        </div>
      </UIUtils.RenderIf>
    </div>
  }
}

module ApiDetailsComponent = {
  open LogicUtils
  open PaymentLogsUtils
  @react.component
  let make = (
    ~paymentDetailsValue,
    ~setLogDetails,
    ~setSelectedOption,
    ~currentSelected: int,
    ~paymentId,
    ~index,
    ~logsDataLength,
  ) => {
    let headerStyle = "text-sm font-medium text-gray-700 break-all"
    let logType = paymentDetailsValue->getLogType
    let apiName = switch logType {
    | PAYMENTS => paymentDetailsValue->getString("api_flow", "default value")->camelCaseToTitle
    | SDK => paymentDetailsValue->getString("event_name", "default value")
    | CONNECTOR => paymentDetailsValue->getString("flow", "default value")->camelCaseToTitle
    | WEBHOOKS => paymentDetailsValue->getString("outgoing_webhook_event_type", "default value")
    }->nameToURLMapper(~payment_id=paymentId, ())
    let createdTime = paymentDetailsValue->getString("created_at", "00000")
    let requestObject = switch logType {
    | PAYMENTS | CONNECTOR => paymentDetailsValue->getString("request", "")
    | SDK =>
      paymentDetailsValue
      ->Dict.toArray
      ->Array.filter(entry => {
        let (key, _) = entry
        filteredKeys->Array.includes(key)->not
      })
      ->getJsonFromArrayOfJson
      ->JSON.stringify
    | WEBHOOKS => paymentDetailsValue->getString("outgoing_webhook_event_type", "")
    }

    let responseObject = switch logType {
    | PAYMENTS | CONNECTOR => paymentDetailsValue->getString("response", "")
    | SDK => {
        let isErrorLog = paymentDetailsValue->getString("log_type", "") === "ERROR"
        isErrorLog ? paymentDetailsValue->getString("value", "") : ""
      }
    | WEBHOOKS => paymentDetailsValue->getString("content", "")
    }

    let statusCode = switch logType {
    | PAYMENTS | CONNECTOR => paymentDetailsValue->getInt("status_code", 200)->Int.toString
    | SDK => paymentDetailsValue->getString("log_type", "INFO")
    | WEBHOOKS => paymentDetailsValue->getBool("is_error", false) ? "500" : "200"
    }

    let method = switch logType {
    | PAYMENTS => paymentDetailsValue->getString("http_method", "")
    | CONNECTOR => paymentDetailsValue->getString("method", "")
    | SDK => ""
    | WEBHOOKS => "POST"
    }

    let apiPath = switch logType {
    | PAYMENTS => paymentDetailsValue->getString("url_path", "")
    | CONNECTOR => paymentDetailsValue->getString("flow", "")
    | WEBHOOKS =>
      paymentDetailsValue->getString("outgoing_webhook_event_type", "")->String.toLocaleUpperCase
    | SDK => ""
    }

    let statusCodeTextColor = switch logType {
    | SDK =>
      switch statusCode {
      | "INFO" => "blue-700"
      | "ERROR" => "red-400"
      | "WARNING" => "yellow-800"
      | _ => "gray-700 opacity-50"
      }
    | WEBHOOKS =>
      switch statusCode {
      | "200" => "green-700"
      | "500" | _ => "gray-700 opacity-50"
      }
    | PAYMENTS | CONNECTOR =>
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
      | "ERROR" => "red-200"
      | "WARNING" => "yellow-100"
      | _ => "gray-100"
      }
    | WEBHOOKS =>
      switch statusCode {
      | "200" => "green-200"
      | "500" | _ => "gray-100"
      }
    | PAYMENTS | CONNECTOR =>
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
          | "INFO" => "blue-700"
          | "ERROR" => "red-400"
          | "WARNING" => "yellow-300"
          | _ => "gray-700 opacity-50"
          }
        | WEBHOOKS =>
          switch statusCode {
          | "200" => "green-700"
          | "500" | _ => "gray-700 opacity-50"
          }
        | PAYMENTS | CONNECTOR =>
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
          | "INFO" => "blue-700"
          | "ERROR" => "red-400"
          | "WARNING" => "orange-500"
          | _ => "gray-600"
          }
        | WEBHOOKS =>
          switch statusCode {
          | "200" => "green-700"
          | "500" | _ => "gray-600"
          }
        | PAYMENTS | CONNECTOR =>
          switch statusCode {
          | "200" => "green-700"
          | "500" => "gray-600"
          | "400" => "orange-500"
          | _ => "gray-600"
          }
        }
      : "gray-200"

    let borderClass = isSelected ? "border border-blue-700 rounded-md" : "border border-transparent"

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
        key={currentSelected->string_of_int}
        onClick={_ => {
          setLogDetails(_ => {
            response: responseObject,
            request: requestObject,
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
                {apiName->camelCaseToTitle->React.string}
              </p>
            | PAYMENTS | WEBHOOKS | CONNECTOR =>
              <p className={`${headerStyle} ${isSelected ? "" : "opacity-80"}`}>
                <span className="mr-3 border-2 px-1 py-0.5 rounded text-sm">
                  {method->String.toUpperCase->React.string}
                </span>
                <span className="leading-7"> {apiPath->React.string} </span>
              </p>
            }}
          </div>
          <div className={`${headerStyle} opacity-40`}>
            {createdTime->Date.fromString->Js.Date.toUTCString->React.string}
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~paymentId, ~createdAt) => {
  open APIUtils
  open LogicUtils
  open PaymentLogsUtils
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let fetchPostDetils = useUpdateMethod()
  let logs = React.useMemo0(() => {ref([])})
  let (logDetails, setLogDetails) = React.useState(_ => {
    response: "",
    request: "",
  })
  let (selectedOption, setSelectedOption) = React.useState(_ => {
    value: 0,
    optionType: PAYMENTS,
  })
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchPaymentLogsData = async _ => {
    try {
      let paymentLogsUrl = getURL(
        ~entityName=PAYMENT_LOGS,
        ~methodType=Get,
        ~id=Some(paymentId),
        (),
      )
      let paymentLogsArray = (await fetchDetails(paymentLogsUrl))->getArrayFromJson([])
      logs.contents = logs.contents->Array.concat(paymentLogsArray)

      PageLoaderWrapper.Success
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let fetchWebhooksLogsData = async _ => {
    try {
      let webhooksLogsUrl = getURL(
        ~entityName=WEBHOOKS_EVENT_LOGS,
        ~methodType=Get,
        ~id=Some(paymentId),
        (),
      )
      let webhooksLogsArray = (await fetchDetails(webhooksLogsUrl))->getArrayFromJson([])
      switch webhooksLogsArray->Array.get(0) {
      | Some(val) => logs.contents = logs.contents->Array.concat([val])
      | _ => ()
      }

      PageLoaderWrapper.Success
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let fetchConnectorLogsData = async _ => {
    try {
      let connectorLogsUrl = getURL(
        ~entityName=CONNECTOR_EVENT_LOGS,
        ~methodType=Get,
        ~id=Some(paymentId),
        (),
      )
      let connectorLogsArray = (await fetchDetails(connectorLogsUrl))->getArrayFromJson([])
      logs.contents = logs.contents->Array.concat(connectorLogsArray)

      PageLoaderWrapper.Success
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let fetchSdkLogsData = async _ => {
    let sourceMapper = source => {
      switch source {
      | "ORCA-LOADER" => "HYPERLOADER"
      | "ORCA-PAYMENTS-PAGE"
      | "STRIPE_PAYMENT_SHEET" => "PAYMENT_SHEET"
      | other => other
      }
    }

    try {
      let url = getURL(~entityName=SDK_EVENT_LOGS, ~methodType=Post, ~id=Some(paymentId), ())
      let startTime = createdAt->Date.fromString->Js.Date.getTime -. 1000. *. 60. *. 5.
      let startTime = startTime->Js.Date.fromFloat->Js.Date.toISOString

      let endTime = createdAt->Date.fromString->Js.Date.getTime +. 1000. *. 60. *. 60. *. 3.
      let endTime = endTime->Js.Date.fromFloat->Js.Date.toISOString
      let body =
        [
          ("paymentId", paymentId->JSON.Encode.string),
          (
            "timeRange",
            [("startTime", startTime->JSON.Encode.string), ("endTime", endTime->JSON.Encode.string)]
            ->Dict.fromArray
            ->JSON.Encode.object,
          ),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object
      let sdkLogsArray =
        (await fetchPostDetils(url, body, Post, ()))
        ->getArrayFromJson([])
        ->Array.map(event => {
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
          eventDict->Dict.set(
            "customer_device",
            eventDict->getString("platform", "")->JSON.Encode.string,
          )
          eventDict->Dict.set(
            "sdk_version",
            eventDict->getString("version", "")->JSON.Encode.string,
          )
          eventDict->Dict.set(
            "event_name",
            updatedEventName
            ->snakeToTitle
            ->titleToSnake
            ->snakeToCamel
            ->capitalizeString
            ->JSON.Encode.string,
          )
          eventDict->Dict.set("created_at", timestamp->JSON.Encode.string)
          eventDict->JSON.Encode.object
        })
      let logsArr = sdkLogsArray->Array.filter(sdkLog => {
        let eventDict = sdkLog->getDictFromJsonObject
        let eventName = eventDict->getString("event_name", "")
        let filteredEventNames = ["StripeElementsCalled"]
        filteredEventNames->Array.includes(eventName)->not
      })
      logs.contents = logs.contents->Array.concat(logsArr)

      PageLoaderWrapper.Success
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let getDetails = async () => {
    if !(paymentId->HSwitchOrderUtils.isTestPayment) {
      let apiLogsStatus = await fetchPaymentLogsData()
      let sdkLogsStatus = await fetchSdkLogsData()
      let webhooksStatus = await fetchWebhooksLogsData()
      let connectorStatus = await fetchConnectorLogsData()

      let screenState = switch (apiLogsStatus, sdkLogsStatus, webhooksStatus, connectorStatus) {
      | (
          PageLoaderWrapper.Error(_),
          PageLoaderWrapper.Error(_),
          PageLoaderWrapper.Error(_),
          PageLoaderWrapper.Error(_),
        ) =>
        PageLoaderWrapper.Error("Failed to Fetch!")
      | _ => PageLoaderWrapper.Success
      }
      setScreenState(_ => screenState)
    } else {
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let screenState = React.useMemo1(() => {
    logs.contents = logs.contents->Js.Array2.sortInPlaceWith(sortByCreatedAt)

    switch logs.contents->Array.get(0) {
    | Some(value) => {
        let initialData = value->getDictFromJsonObject
        switch initialData->getLogType {
        | PAYMENTS => {
            let request = initialData->getString("request", "")
            let response = initialData->getString("response", "")
            setLogDetails(_ => {
              response,
              request,
            })
            setSelectedOption(_ => {
              value: 0,
              optionType: PAYMENTS,
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
    | _ => ()
    }

    screenState
  }, [screenState])

  React.useEffect0(() => {
    getDetails()->ignore
    None
  })

  let headerText = switch selectedOption.optionType {
  | PAYMENTS | CONNECTOR => "Response body"
  | WEBHOOKS => "Request body"
  | SDK => "Metadata"
  }->Some

  let timeLine =
    <div className="flex flex-col w-2/5 overflow-y-scroll pt-7 pl-5">
      <div className="flex flex-col">
        {logs.contents
        ->Array.mapWithIndex((paymentDetailsValue, index) => {
          <ApiDetailsComponent
            key={index->string_of_int}
            paymentDetailsValue={paymentDetailsValue->getDictFromJsonObject}
            setLogDetails
            setSelectedOption
            currentSelected=selectedOption.value
            paymentId
            index
            logsDataLength={logs.contents->Array.length - 1}
          />
        })
        ->React.array}
      </div>
    </div>

  let requestHeader = switch selectedOption.optionType {
  | PAYMENTS | CONNECTOR => "Request body"
  | SDK => "Event"
  | WEBHOOKS => ""
  }

  let codeBlock =
    <UIUtils.RenderIf
      condition={logDetails.response->isNonEmptyString || logDetails.request->isNonEmptyString}>
      <div
        className="flex flex-col gap-4 border-l-1 border-border-light-grey show-scrollbar scroll-smooth overflow-scroll px-5 py-3 w-3/5">
        <UIUtils.RenderIf
          condition={logDetails.request->isNonEmptyString &&
            selectedOption.optionType !== WEBHOOKS}>
          <PrettyPrintJson
            jsonToDisplay=logDetails.request
            headerText={requestHeader->Some}
            maxHeightClass={logDetails.response->String.length > 0 ? "max-h-25-rem" : ""}
          />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={logDetails.response->isNonEmptyString}>
          <PrettyPrintJson jsonToDisplay={logDetails.response} headerText />
        </UIUtils.RenderIf>
      </div>
    </UIUtils.RenderIf>

  open OrderUtils
  <PageLoaderWrapper
    screenState customUI={<NoDataFound message="No logs available for this payment" />}>
    {if paymentId->HSwitchOrderUtils.isTestPayment || logs.contents->Array.length === 0 {
      <div
        className="flex items-center gap-2 bg-white w-full border-2 p-3 !opacity-100 rounded-lg text-md font-medium">
        <Icon name="info-circle-unfilled" size=16 />
        <div className={`text-lg font-medium opacity-50`}>
          {"No logs available for this payment"->React.string}
        </div>
      </div>
    } else {
      <Section
        customCssClass={`bg-white dark:bg-jp-gray-lightgray_background rounded-md pt-2 pb-4 flex gap-7 justify-between h-48-rem !max-h-50-rem !min-w-[55rem] max-w-[72rem] overflow-scroll`}>
        {timeLine}
        {codeBlock}
      </Section>
    }}
  </PageLoaderWrapper>
}
