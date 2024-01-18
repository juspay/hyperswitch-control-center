open OrderUtils
open APIUtils
open LogicUtils
@module("js-sha256") external sha256: string => string = "sha256"

type logType = Sdk | Payment | Webhooks

type logDetails = {
  response: string,
  request: string,
}

type selectedObj = {
  value: string,
  optionType: logType,
}

let filteredKeys = [
  "value",
  "merchant_id",
  "created_at_precise",
  "component",
  "platform",
  "version",
]

module PrettyPrintJson = {
  @react.component
  let make = (
    ~jsonToDisplay,
    ~headerText=None,
    ~maxHeightClass="max-h-25-rem",
    ~maxVisibleLines=5,
    ~overrideBackgroundColor="bg-hyperswitch_background",
  ) => {
    let showToast = ToastState.useShowToast()
    let (showExpand, setShowExpand) = React.useState(_ => true)
    let (isTextVisible, setIsTextVisible) = React.useState(_ => false)
    let (parsedJson, setParsedJson) = React.useState(_ => "")

    React.useEffect1(() => {
      let flag =
        Js.Array2.fromMap(parsedJson->Js.String2.castToArrayLike, x => x)
        ->Js.Array2.filter(str => str == "\n")
        ->Js.Array2.length > maxVisibleLines
      setShowExpand(_ => flag)
      None
    }, [parsedJson])

    let parseJsonValue = () => {
      try {
        let parsedValue = jsonToDisplay->Js.Json.parseExn->Js.Json.stringifyWithSpace(3)
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
        <img src={`/assets/CopyToClipboard.svg`} className="w-9 h-5" />
      </div>

    <div className="flex flex-col gap-2  my-2">
      <UIUtils.RenderIf condition={parsedJson->String.length > 0}>
        {<>
          <UIUtils.RenderIf condition={headerText->Belt.Option.isSome}>
            <div className="flex justify-between items-center">
              <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
                {headerText->Belt.Option.getWithDefault("")->React.string}
              </p>
            </div>
          </UIUtils.RenderIf>
          <div className="flex items-start justify-between">
            <pre
              className={`${overrideBackgroundColor} p-3 text-jp-gray-900 dark:bg-jp-gray-950 dark:bg-opacity-100 ${isTextVisible
                  ? "overflow-visible "
                  : `overflow-clip  h-fit ${maxHeightClass}`} text-fs-13 text font-medium`}>
              {parsedJson->React.string}
            </pre>
            {copyParsedJson}
          </div>
          <UIUtils.RenderIf condition={showExpand}>
            <Button
              text={isTextVisible ? "Hide" : "See more"}
              customButtonStyle="h-6 w-8 flex flex-1 justify-center m-1"
              onClick={_ => setIsTextVisible(_ => !isTextVisible)}
            />
          </UIUtils.RenderIf>
        </>}
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={parsedJson->String.length === 0}>
        <div className="flex flex-col justify-start items-start gap-2 h-25-rem">
          <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
            {headerText->Belt.Option.getWithDefault("")->React.string}
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
  @react.component
  let make = (
    ~paymentDetailsValue,
    ~setLogDetails,
    ~setSelectedOption,
    ~currentSelected,
    ~paymentId,
    ~index,
    ~logsDataLength,
  ) => {
    let headerStyle = "text-fs-13 font-medium text-grey-700 break-all"
    let logType = if paymentDetailsValue->Dict.get("request_id")->Belt.Option.isSome {
      Payment
    } else if paymentDetailsValue->Dict.get("component")->Belt.Option.isSome {
      Sdk
    } else {
      Webhooks
    }
    let apiName = switch logType {
    | Payment => paymentDetailsValue->getString("api_flow", "default value")->camelCaseToTitle
    | Sdk => paymentDetailsValue->getString("event_name", "default value")
    | Webhooks => paymentDetailsValue->getString("outgoing_webhook_event_type", "default value")
    }->PaymentUtils.nameToURLMapper(~payment_id=paymentId, ())
    let createdTime = paymentDetailsValue->getString("created_at", "00000")
    let requestId = switch logType {
    | Payment => paymentDetailsValue->getString("request_id", "")
    | Sdk => paymentDetailsValue->getString("event_id", "")
    | Webhooks => paymentDetailsValue->getString("event_id", "")
    }

    let requestObject = switch logType {
    | Payment => paymentDetailsValue->getString("request", "")
    | Sdk =>
      paymentDetailsValue
      ->Dict.toArray
      ->Array.filter(entry => {
        let (key, _) = entry
        filteredKeys->Array.includes(key)->not
      })
      ->Dict.fromArray
      ->Js.Json.object_
      ->Js.Json.stringify
    | Webhooks => paymentDetailsValue->getString("outgoing_webhook_event_type", "")
    }

    let responseObject = switch logType {
    | Payment => paymentDetailsValue->getString("response", "")
    | Sdk => {
        let isErrorLog = paymentDetailsValue->getString("log_type", "") === "ERROR"
        isErrorLog ? paymentDetailsValue->getString("value", "") : ""
      }
    | Webhooks => paymentDetailsValue->getString("content", "")
    }

    let statusCode = switch logType {
    | Payment => paymentDetailsValue->getInt("status_code", 200)->Belt.Int.toString
    | Sdk => paymentDetailsValue->getString("log_type", "INFO")
    | Webhooks => paymentDetailsValue->getBool("is_error", false) ? "200" : "500"
    }

    let method = switch logType {
    | Payment => paymentDetailsValue->getString("http_method", "")
    | Sdk => ""
    | Webhooks => "POST"
    }

    let apiPath = switch logType {
    | Payment => paymentDetailsValue->getString("url_path", "")
    | Webhooks =>
      paymentDetailsValue->getString("outgoing_webhook_event_type", "")->String.toLocaleUpperCase
    | Sdk => ""
    }

    let background_color = switch logType {
    | Sdk =>
      switch statusCode {
      | "INFO" => "blue-700"
      | "WARNING" => "yellow-800"
      | "ERROR" => "red-800"
      | _ => "grey-700 opacity-50"
      }
    | Webhooks =>
      switch statusCode {
      | "200" => "green-700"
      | "500" | _ => "grey-700 opacity-50"
      }
    | Payment =>
      switch statusCode {
      | "200" => "green-700"
      | "500" => "grey-700 opacity-50"
      | "400" => "yellow-800"
      | _ => "grey-700 opacity-50"
      }
    }

    open HSwitchUtils
    let stepColor =
      !(currentSelected->isEmptyString) && currentSelected === requestId
        ? background_color
        : "gray-300 "
    let boxShadowOnSelection =
      !(currentSelected->isEmptyString) && currentSelected === requestId
        ? "border border-blue-700 rounded-md shadow-paymentLogsShadow"
        : "border border-transparent"

    <div className="flex items-start gap-4">
      <div className="flex flex-col items-center h-full">
        <div className={`w-fit h-fit p-1.5  border rounded-full bg-${stepColor} border-gray-300`} />
        <UIUtils.RenderIf condition={index !== logsDataLength}>
          <div className={`h-full bg-${stepColor} w-0.5 my-1`} />
        </UIUtils.RenderIf>
      </div>
      <div
        className={`flex gap-6 items-start w-full p-4 cursor-pointer ${boxShadowOnSelection} -mt-8 mb-8`}
        key={currentSelected}
        onClick={_ => {
          setLogDetails(_ => {
            response: responseObject,
            request: requestObject,
          })
          setSelectedOption(_ => {
            value: requestId,
            optionType: logType,
          })
        }}>
        <div className="flex flex-col gap-1">
          <div className=" flex gap-2">
            <p className={`text-${background_color} font-bold `}> {statusCode->React.string} </p>
            {switch logType {
            | Sdk => <p className=headerStyle> {apiName->React.string} </p>
            | Payment | Webhooks =>
              <p className=headerStyle>
                <span className="font-bold mr-2"> {method->String.toUpperCase->React.string} </span>
                <span> {apiPath->React.string} </span>
              </p>
            }}
          </div>
          <div className={`${headerStyle} opacity-50`}>
            {createdTime->Js.Date.fromString->Js.Date.toUTCString->React.string}
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~paymentId, ~createdAt) => {
  open HSwitchUtils
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let fetchPostDetils = useUpdateMethod()
  let logs = React.useMemo0(() => {ref([])})
  let (logDetails, setLogDetails) = React.useState(_ => {
    response: "",
    request: "",
  })
  let (selectedOption, setSelectedOption) = React.useState(_ => {
    value: "",
    optionType: Payment,
  })
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchPaymentLogsData = async _ => {
    try {
      let paymentLogsUrl = APIUtils.getURL(
        ~entityName=PAYMENT_LOGS,
        ~methodType=Get,
        ~id=Some(paymentId),
        (),
      )
      let paymentLogsArray = (await fetchDetails(paymentLogsUrl))->getArrayFromJson([])
      logs.contents = logs.contents->Array.concat(paymentLogsArray)

      PageLoaderWrapper.Success
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let fetchWebhooksLogsData = async _ => {
    try {
      let webhooksLogsUrl = APIUtils.getURL(
        ~entityName=CONNECTOR_EVENT_LOGS,
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
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let fetchSdkLogsData = async _ => {
    let sourceMapper = source => {
      switch source {
      | "ORCA-LOADER" => "HYPERLOADER"
      | "ORCA-PAYMENT-PAGE"
      | "STRIPE_PAYMENT_SHEET" => "PAYMENT_SHEET"
      | other => other
      }
    }

    try {
      let url = APIUtils.getURL(
        ~entityName=SDK_EVENT_LOGS,
        ~methodType=Post,
        ~id=Some(paymentId),
        (),
      )
      let startTime = createdAt->Js.Date.fromString->Js.Date.getTime -. 1000. *. 60. *. 5.
      let startTime = startTime->Js.Date.fromFloat->Js.Date.toISOString

      let endTime = createdAt->Js.Date.fromString->Js.Date.getTime +. 1000. *. 60. *. 60. *. 3.
      let endTime = endTime->Js.Date.fromFloat->Js.Date.toISOString
      let body =
        [
          ("paymentId", paymentId->Js.Json.string),
          (
            "timeRange",
            [("startTime", startTime->Js.Json.string), ("endTime", endTime->Js.Json.string)]
            ->Dict.fromArray
            ->Js.Json.object_,
          ),
        ]
        ->Dict.fromArray
        ->Js.Json.object_
      let sdkLogsArray =
        (await fetchPostDetils(url, body, Post))
        ->getArrayFromJson([])
        ->Array.map(event => {
          let eventDict = event->getDictFromJsonObject
          let eventName = eventDict->getString("event_name", "")
          let timestamp = eventDict->getString("created_at_precise", "")
          let logType = eventDict->getString("log_type", "")
          let updatedEventName =
            logType === "INFO" ? eventName->String.replace("Call", "Response") : eventName
          eventDict->Dict.set("event_name", updatedEventName->Js.Json.string)
          eventDict->Dict.set("event_id", sha256(updatedEventName ++ timestamp)->Js.Json.string)
          eventDict->Dict.set(
            "source",
            eventDict->getString("source", "")->sourceMapper->Js.Json.string,
          )
          eventDict->Dict.set(
            "checkout_platform",
            eventDict->getString("component", "")->Js.Json.string,
          )
          eventDict->Dict.set(
            "customer_device",
            eventDict->getString("platform", "")->Js.Json.string,
          )
          eventDict->Dict.set("sdk_version", eventDict->getString("version", "")->Js.Json.string)
          eventDict->Dict.set(
            "event_name",
            updatedEventName
            ->snakeToTitle
            ->titleToSnake
            ->snakeToCamel
            ->capitalizeString
            ->Js.Json.string,
          )
          eventDict->Dict.set("created_at", timestamp->Js.Json.string)
          eventDict->Js.Json.object_
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
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      PageLoaderWrapper.Error(err)
    }
  }

  let getDetails = async () => {
    if !(paymentId->HSwitchOrderUtils.isTestPayment) {
      let screenState = switch (
        await fetchPaymentLogsData(),
        await fetchSdkLogsData(),
        await fetchWebhooksLogsData(),
      ) {
      | (PageLoaderWrapper.Error(_), PageLoaderWrapper.Error(_), PageLoaderWrapper.Error(_)) =>
        PageLoaderWrapper.Error("Failed to Fetch!")
      | _ => PageLoaderWrapper.Success
      }
      setScreenState(_ => screenState)
    } else {
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let sortByCreatedAt = (log1: Js.Json.t, log2: Js.Json.t) => {
    let getKey = dict =>
      dict->getDictFromJsonObject->getString("created_at", "")->Js.Date.fromString
    let keyA = log1->getKey
    let keyB = log2->getKey
    if keyA < keyB {
      1
    } else if keyA > keyB {
      -1
    } else {
      0
    }
  }

  let screenState = React.useMemo1(() => {
    logs.contents = logs.contents->Js.Array2.sortInPlaceWith(sortByCreatedAt)

    switch logs.contents->Array.get(0) {
    | Some(value) => {
        let initialData = value->getDictFromJsonObject
        if initialData->Dict.get("request_id")->Belt.Option.isSome {
          // payment
          let request = initialData->getString("request", "")
          let response = initialData->getString("response", "")
          setLogDetails(_ => {
            response,
            request,
          })
          setSelectedOption(_ => {
            value: initialData->getString("request_id", ""),
            optionType: Payment,
          })
        } else if initialData->Dict.get("component")->Belt.Option.isSome {
          Js.log2(">>", initialData)
          // sdk
          let request =
            initialData
            ->Dict.toArray
            ->Array.filter(entry => {
              let (key, _) = entry
              filteredKeys->Array.includes(key)->not
            })
            ->Dict.fromArray
            ->Js.Json.object_
            ->Js.Json.stringify
          let response =
            initialData->getString("log_type", "") === "ERROR"
              ? initialData->getString("value", "")
              : ""
          setLogDetails(_ => {
            response,
            request,
          })
          setSelectedOption(_ => {
            value: initialData->getString("event_id", ""),
            optionType: Sdk,
          })
        } else {
          // webhooks
          let request = initialData->getString("outgoing_webhook_event_type", "")
          let response = initialData->getString("content", "")
          setLogDetails(_ => {
            response,
            request,
          })
          setSelectedOption(_ => {
            value: initialData->getString("event_id", ""),
            optionType: Webhooks,
          })
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
        customCssClass={`bg-white dark:bg-jp-gray-lightgray_background rounded-md pt-2 pb-4 px-10 flex gap-16 justify-between h-48-rem !max-h-50-rem !min-w-[55rem] max-w-[72rem] overflow-scroll`}>
        <div className="flex flex-col w-1/2 gap-12 overflow-y-scroll">
          <p className="text-lightgray_background font-semibold text-fs-16">
            {"Audit Trail"->React.string}
          </p>
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
        <UIUtils.RenderIf
          condition={logDetails.response->String.length > 0 ||
            logDetails.request->String.length > 0}>
          <div
            className="flex flex-col gap-4 bg-hyperswitch_background rounded show-scrollbar scroll-smooth overflow-scroll px-8 py-4 w-1/2">
            <UIUtils.RenderIf
              condition={!(logDetails.request->isEmptyString) &&
              selectedOption.optionType !== Webhooks}>
              <PrettyPrintJson
                jsonToDisplay=logDetails.request
                headerText={Some(selectedOption.optionType === Payment ? "Request body" : "Event")}
                maxHeightClass={logDetails.response->String.length > 0 ? "max-h-25-rem" : ""}
                maxVisibleLines=22
              />
            </UIUtils.RenderIf>
            <UIUtils.RenderIf condition={!(logDetails.response->isEmptyString)}>
              {
                let headerText = switch selectedOption.optionType {
                | Payment => "Response body"
                | Webhooks => "Request body"
                | Sdk => "Metadata"
                }->Some
                <PrettyPrintJson maxVisibleLines=22 jsonToDisplay=logDetails.response headerText />
              }
            </UIUtils.RenderIf>
          </div>
        </UIUtils.RenderIf>
      </Section>
    }}
  </PageLoaderWrapper>
}
