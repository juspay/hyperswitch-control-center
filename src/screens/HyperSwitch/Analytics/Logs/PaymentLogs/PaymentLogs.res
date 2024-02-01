@module("js-sha256") external sha256: string => string = "sha256"

let getLogType = dict => {
  open LogTypes
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

@react.component
let make = (~paymentId, ~createdAt) => {
  open APIUtils
  open LogicUtils
  open PaymentLogsUtils
  open LogTypes
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let fetchPostDetils = useUpdateMethod()
  let logs = React.useMemo0(() => {ref([])})
  let (logDetails, setLogDetails) = React.useState(_ => {
    response: "",
    request: "",
  })
  let (selectedOption, setSelectedOption) = React.useState(_ => {
    value: 0,
    optionType: API_EVENTS,
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
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
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
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
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
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
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
      let startTime = createdAt->Js.Date.fromString->Js.Date.getTime -. 1000. *. 60. *. 5.
      let startTime = startTime->Js.Date.fromFloat->Js.Date.toISOString

      let endTime = createdAt->Js.Date.fromString->Js.Date.getTime +. 1000. *. 60. *. 60. *. 3.
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
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
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
        | API_EVENTS => {
            let request = initialData->getString("request", "")
            let response = initialData->getString("response", "")
            setLogDetails(_ => {
              response,
              request,
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
  | API_EVENTS | CONNECTOR => "Response body"
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
            dataDict={paymentDetailsValue->getDictFromJsonObject}
            setLogDetails
            setSelectedOption
            currentSelected=selectedOption.value
            index
            logsDataLength={logs.contents->Array.length - 1}
            getLogType
            nameToURLMapper={nameToURLMapper(~id={paymentId})}
            filteredKeys
          />
        })
        ->React.array}
      </div>
    </div>

  let requestHeader = switch selectedOption.optionType {
  | API_EVENTS | CONNECTOR => "Request body"
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
