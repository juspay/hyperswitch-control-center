open OrderUtils
open APIUtils
open LogicUtils
@module("js-sha256") external sha256: string => string = "sha256"
module PrettyPrintJson = {
  @react.component
  let make = (
    ~jsonToDisplay,
    ~headerText,
    ~maxHeightClass="max-h-25-rem",
    ~overrideBackgroundColor="bg-hyperswitch_background",
  ) => {
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let showToast = ToastState.useShowToast()
    let url = RescriptReactRouter.useUrl()
    let (isTextVisible, setIsTextVisible) = React.useState(_ => false)
    let (parsedJson, setParsedJson) = React.useState(_ => "")

    let parseJsonValue = () => {
      try {
        let parsedValue = Window.getParsedJson(jsonToDisplay)->Js.Json.stringifyWithSpace(3)
        setParsedJson(_ => parsedValue)
      } catch {
      | _ => setParsedJson(_ => "")
      }
    }
    React.useEffect1(() => {
      parseJsonValue()->ignore
      None
    }, [jsonToDisplay])

    let handleOnClickCopy = (~parsedValue) => {
      Clipboard.writeText(parsedValue)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
      hyperswitchMixPanel(
        ~pageName=`${url.path->getListHead}`,
        ~contextName=`${headerText->toCamelCase}`,
        ~actionName="copied",
        (),
      )
    }

    <div className="flex flex-col gap-2  my-2">
      <UIUtils.RenderIf condition={parsedJson->Js.String2.length > 0}>
        {<>
          <div className="flex justify-between items-center">
            <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
              {headerText->React.string}
            </p>
            <div
              onClick={_ => handleOnClickCopy(~parsedValue=parsedJson)} className="cursor-pointer">
              <img src={`/assets/CopyToClipboard.svg`} />
            </div>
          </div>
          <pre
            className={`${overrideBackgroundColor} p-3 text-jp-gray-900 dark:bg-jp-gray-950 dark:bg-opacity-100 ${isTextVisible
                ? "overflow-visible "
                : `overflow-clip  h-fit ${maxHeightClass}`} text-fs-13 text font-medium`}>
            {parsedJson->React.string}
          </pre>
          <Button
            text={isTextVisible ? "Hide" : "See more"}
            customButtonStyle="h-6 w-8 flex flex-1 justify-center m-1"
            onClick={_ => setIsTextVisible(_ => !isTextVisible)}
          />
        </>}
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={parsedJson->Js.String2.length === 0}>
        <div className="flex flex-col justify-start items-start gap-2 h-25-rem">
          <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
            {headerText->React.string}
          </p>
          <p className="font-normal text-fs-14 text-jp-gray-900 text-opacity-50">
            {"Failed to load!"->React.string}
          </p>
        </div>
      </UIUtils.RenderIf>
    </div>
  }
}

type logType = Sdk | Payment

module ApiDetailsComponent = {
  @react.component
  let make = (
    ~paymentDetailsValue,
    ~setRequestObject,
    ~setResponseObject,
    ~setCurrentSelected,
    ~setCurrentSelectedType,
    ~currentSelected,
    ~paymentId,
    ~index,
    ~logsDataLength,
  ) => {
    let headerStyle = "text-fs-13 font-medium text-grey-700 break-all"
    let logType = paymentDetailsValue->Js.Dict.get("request_id")->Belt.Option.isSome ? Payment : Sdk
    let apiName = switch logType {
    | Payment => paymentDetailsValue->getString("api_name", "default value")
    | Sdk => paymentDetailsValue->getString("event_name", "default value")
    }->PaymentUtils.nameToURLMapper(~payment_id=paymentId, ())
    let createdTime = paymentDetailsValue->getString("created_at", "00000")
    let requestId = switch logType {
    | Payment => paymentDetailsValue->getString("request_id", "")
    | Sdk => paymentDetailsValue->getString("event_id", "")
    }

    let filteredKeys = [
      "value",
      "merchant_id",
      "created_at_precise",
      "component",
      "platform",
      "version",
    ]
    let requestObject = switch logType {
    | Payment => paymentDetailsValue->getString("request", "")
    | Sdk =>
      paymentDetailsValue
      ->Js.Dict.entries
      ->Js.Array2.filter(entry => {
        let (key, _) = entry
        filteredKeys->Js.Array2.includes(key)->not
      })
      // ->Js.Array2.sortInPlaceWith((e1, e2) => {
      //   let (key1, _) = e1
      //   let (key2, _) = e2
      //   key1 > key2 ? 1 : key1 === key2 ? 0 : -1
      // })
      ->Js.Dict.fromArray
      ->Js.Json.object_
      ->Js.Json.stringify
    }

    let responseObject = switch logType {
    | Payment => paymentDetailsValue->getString("response", "")
    | Sdk => {
        let isErrorLog = paymentDetailsValue->getString("log_type", "") === "ERROR"
        isErrorLog ? paymentDetailsValue->getString("value", "") : ""
      }
    }

    let statusCode = switch logType {
    | Payment => paymentDetailsValue->getString("status_code", "200")
    | Sdk => paymentDetailsValue->getString("log_type", "INFO")
    }

    let background_color = switch (logType, statusCode) {
    | (Sdk, "INFO") => "blue-700"
    | (Payment, "200") => "green-700"
    | (Sdk, "WARNING")
    | (Payment, "400") => "yellow-800"
    | (Sdk, "ERROR")
    | (Payment, "500") => "red-800"
    | _ => "grey-700 opacity-50"
    }
    let stepColor =
      currentSelected->Js.String2.length > 0 && currentSelected === requestId
        ? background_color
        : "gray-300 "
    let boxShadowOnSelection =
      currentSelected->Js.String2.length > 0 && currentSelected === requestId
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
          setCurrentSelected(_ => requestId)
          setRequestObject(_ => requestObject)
          setResponseObject(_ => responseObject)
          setCurrentSelectedType(_ => logType)
        }}>
        <div className="flex flex-col gap-1">
          <div className=" flex gap-2">
            <p className={`text-${background_color} font-bold `}> {statusCode->React.string} </p>
            <p className=headerStyle> {apiName->React.string} </p>
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
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let fetchPostDetils = useUpdateMethod()
  let (paymentLogsData, setPaymentLogsData) = React.useState(_ => [])
  let (sdkLogsData, setSdkLogsData) = React.useState(_ => [])
  let (allLogsData, setAllLogsData) = React.useState(_ => [])
  let (responseObject, setResponseObject) = React.useState(_ => "")
  let (requestObject, setRequestObject) = React.useState(_ => "")
  let (currentSelected, setCurrentSelected) = React.useState(_ => "")
  let (currentSelectedType, setCurrentSelectedType) = React.useState(_ => Payment)
  let (screenState1, setScreenState1) = React.useState(_ => PageLoaderWrapper.Loading)
  let (screenState2, setScreenState2) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchPaymentLogsData = async _ => {
    try {
      setScreenState1(_ => PageLoaderWrapper.Loading)
      let paymentLogsUrl = APIUtils.getURL(
        ~entityName=PAYMENT_LOGS,
        ~methodType=Get,
        ~id=Some(paymentId),
        (),
      )
      let paymentLogsArray = (await fetchDetails(paymentLogsUrl))->getArrayFromJson([])
      setPaymentLogsData(_ => paymentLogsArray)

      // setting initial data
      let initialData =
        paymentLogsArray
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault(Js.Json.null)
        ->getDictFromJsonObject
      let intialValueRequest = initialData->getString("request", "")

      let intialValueResponse = initialData->getString("response", "")
      setRequestObject(_ => intialValueRequest)
      setResponseObject(_ => intialValueResponse)
      setCurrentSelected(_ => initialData->getString("request_id", ""))

      setScreenState1(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState1(_ => PageLoaderWrapper.Error(err))
    }
  }

  let sourceMapper = source => {
    switch source {
    | "ORCA-LOADER" => "HYPERLOADER"
    | "ORCA-PAYMENT-PAGE"
    | "STRIPE_PAYMENT_SHEET" => "PAYMENT_SHEET"
    | other => other
    }
  }

  let fetchSdkLogsData = async _ => {
    try {
      setScreenState2(_ => PageLoaderWrapper.Loading)
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
            ->Js.Dict.fromArray
            ->Js.Json.object_,
          ),
        ]
        ->Js.Dict.fromArray
        ->Js.Json.object_
      let sdkLogsArray =
        (await fetchPostDetils(url, body, Post))
        ->getArrayFromJson([])
        ->Js.Array2.map(event => {
          let eventDict = event->getDictFromJsonObject
          let eventName = eventDict->getString("event_name", "")
          let timestamp = eventDict->getString("created_at_precise", "")
          let logType = eventDict->getString("log_type", "")
          let updatedEventName =
            logType === "INFO" ? eventName->Js.String2.replace("Call", "Response") : eventName
          eventDict->Js.Dict.set("event_name", updatedEventName->Js.Json.string)
          eventDict->Js.Dict.set("event_id", sha256(updatedEventName ++ timestamp)->Js.Json.string)
          eventDict->Js.Dict.set(
            "source",
            eventDict->getString("source", "")->sourceMapper->Js.Json.string,
          )
          eventDict->Js.Dict.set(
            "sdk_platform",
            eventDict->getString("component", "")->Js.Json.string,
          )
          eventDict->Js.Dict.set(
            "user_platform",
            eventDict->getString("platform", "")->Js.Json.string,
          )
          eventDict->Js.Dict.set("sdk_version", eventDict->getString("version", "")->Js.Json.string)
          eventDict->Js.Dict.set(
            "event_name",
            updatedEventName
            ->snakeToTitle
            ->titleToSnake
            ->snakeToCamel
            ->capitalizeString
            ->Js.Json.string,
          )
          eventDict->Js.Dict.set("created_at", timestamp->Js.Json.string)
          eventDict->Js.Json.object_
        })
      setSdkLogsData(_ =>
        sdkLogsArray->Js.Array2.filter(sdkLog => {
          let eventDict = sdkLog->getDictFromJsonObject
          let eventName = eventDict->getString("event_name", "")
          let filteredEventNames = ["StripeElementsCalled"]
          filteredEventNames->Js.Array2.includes(eventName)->not
        })
      )

      // setting initial data
      let initialData =
        sdkLogsArray
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault(Js.Json.null)
        ->getDictFromJsonObject
      let intialValueRequest = initialData->getString("event_name", "")

      let intialValueResponse = initialData->getString("response", "")
      setRequestObject(_ => intialValueRequest)
      setResponseObject(_ => intialValueResponse)
      setCurrentSelected(_ => initialData->getString("event_id", ""))

      setScreenState2(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState2(_ => PageLoaderWrapper.Error(err))
    }
  }
  let getDetails = async () => {
    try {
      let _wasmResult = await Window.connectorWasmInit()
      if !(paymentId->HSwitchOrderUtils.isTestPayment) {
        fetchPaymentLogsData()->ignore
        fetchSdkLogsData()->ignore
      } else {
        setScreenState1(_ => PageLoaderWrapper.Success)
        setScreenState2(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
        setScreenState1(_ => PageLoaderWrapper.Error(err))
        setScreenState2(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let sortByCreatedAt = (log1: Js.Json.t, log2: Js.Json.t) => {
    let keyA = log1->getDictFromJsonObject->getString("created_at", "")->Js.Date.fromString
    let keyB = log2->getDictFromJsonObject->getString("created_at", "")->Js.Date.fromString
    if keyA < keyB {
      1
    } else if keyA > keyB {
      -1
    } else {
      0
    }
  }

  let screenState = React.useMemo2(() => {
    setAllLogsData(_ =>
      sdkLogsData->Js.Array.concat(paymentLogsData)->Js.Array2.sortInPlaceWith(sortByCreatedAt)
    )
    switch (screenState1, screenState2) {
    | (PageLoaderWrapper.Success, _)
    | (_, PageLoaderWrapper.Success) =>
      PageLoaderWrapper.Success
    | (PageLoaderWrapper.Loading, _)
    | (_, PageLoaderWrapper.Loading) =>
      PageLoaderWrapper.Loading
    | (PageLoaderWrapper.Error(err), PageLoaderWrapper.Error(_)) => PageLoaderWrapper.Error(err)
    | _ => PageLoaderWrapper.Loading
    }
  }, (screenState1, screenState2))

  React.useEffect0(() => {
    getDetails()->ignore
    None
  })

  <PageLoaderWrapper
    screenState customUI={<NoDataFound message="No logs available for this payment" />}>
    {if paymentId->HSwitchOrderUtils.isTestPayment {
      <div
        className="flex items-center gap-2 bg-white w-full border-2 p-3 !opacity-100 rounded-lg text-md font-medium">
        <Icon name="info-circle-unfilled" size=16 />
        <div className={`text-lg font-medium opacity-50`}>
          {"No logs available for this payment"->React.string}
        </div>
      </div>
    } else {
      <Section
        customCssClass={`border border-jp-gray-940 border-opacity-75 bg-white dark:bg-jp-gray-lightgray_background rounded-md p-10 flex gap-16 justify-between h-48-rem !max-h-50-rem !min-w-[55rem] overflow-scroll`}>
        <div className="flex flex-col w-1/2 gap-12 overflow-y-scroll">
          <p className="text-lightgray_background font-semibold text-fs-16">
            {"Audit Trail"->React.string}
          </p>
          <div className="flex flex-col">
            {allLogsData
            ->Array.mapWithIndex((paymentDetailsValue, index) => {
              <ApiDetailsComponent
                key={index->string_of_int}
                paymentDetailsValue={paymentDetailsValue->getDictFromJsonObject}
                setResponseObject
                setRequestObject
                currentSelected
                setCurrentSelected
                setCurrentSelectedType
                paymentId
                index
                logsDataLength={allLogsData->Js.Array2.length - 1}
              />
            })
            ->React.array}
          </div>
        </div>
        <UIUtils.RenderIf
          condition={responseObject->Js.String2.length > 0 || requestObject->Js.String2.length > 0}>
          <div
            className="flex flex-col gap-4 bg-hyperswitch_background rounded show-scrollbar scroll-smooth overflow-scroll px-8 py-4 w-1/2">
            <UIUtils.RenderIf condition={requestObject->Js.String2.length > 0}>
              <PrettyPrintJson
                jsonToDisplay=requestObject
                headerText={currentSelectedType === Payment ? "Request body" : "Event"}
                maxHeightClass={responseObject->Js.String2.length > 0 ? "max-h-25-rem" : ""}
              />
            </UIUtils.RenderIf>
            <UIUtils.RenderIf condition={responseObject->Js.String2.length > 0}>
              <PrettyPrintJson
                jsonToDisplay=responseObject
                headerText={currentSelectedType === Payment ? "Response body" : "Metadata"}
              />
            </UIUtils.RenderIf>
          </div>
        </UIUtils.RenderIf>
      </Section>
    }}
  </PageLoaderWrapper>
}
