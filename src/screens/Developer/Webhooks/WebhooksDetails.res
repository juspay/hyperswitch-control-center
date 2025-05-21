module TabDetails = {
  @react.component
  let make = (~activeTab: WebhooksTypes.tabs, ~selectedEvent: WebhooksTypes.attemptType) => {
    open LogicUtils

    let keyTextClass = HSwitchUtils.getTextClass((P1, Medium))
    let valTextClass = HSwitchUtils.getTextClass((P1, Regular))

    let requestBody = selectedEvent.request.body
    let responseBody = selectedEvent.response.body
    let requestHeaders = selectedEvent.request.headers
    let responseHeaders = selectedEvent.response.headers
    let statusCode = selectedEvent.response.statusCode
    let errorMessage = selectedEvent.response.errorMessage

    let noResponse = statusCode === 404

    let headerKeyValUI = header => {
      let item = index => {
        let val = header->getValueFromArray(index, "")
        if val->String.length > 30 {
          <HelperComponents.EllipsisText displayValue=val endValue=20 expandText=false />
        } else {
          val->React.string
        }
      }

      <div className="flex flex-col lg:flex-row">
        <span className={keyTextClass}> {item(0)} </span>
        <span className="hidden lg:inline-block"> {":"->React.string} </span>
        <span className="lg:whitespace-pre"> {"   "->React.string} </span>
        <span className={valTextClass}> {item(1)} </span>
      </div>
    }

    let headersValues = headers => {
      let headersArray = headers->getArrayFromJson([])

      let headerDataItem = headersArray->Array.map(header => {
        header
        ->getStrArryFromJson
        ->headerKeyValUI
      })

      <div> {headerDataItem->React.array} </div>
    }

    <div className="h-[44rem] !max-h-[72rem] overflow-scroll mt-4">
      {switch activeTab {
      | Request =>
        <div className="flex flex-col gap-1 w-[98%] pl-3">
          <div> {"Headers"->React.string} </div>
          <div className="m-3 p-3 border border-grey-300 rounded-md max-w-[90%]">
            {headersValues(requestHeaders)}
          </div>
          <div className="flex justify-between">
            <div className=" mt-2"> {"Body"->React.string} </div>
            <HelperComponents.CopyTextCustomComp
              displayValue=Some("") copyValue={Some(requestBody)} customTextCss="text-nowrap"
            />
          </div>
          <RenderIf condition={requestBody->isNonEmptyString}>
            <PrettyPrintJson jsonToDisplay=requestBody />
          </RenderIf>
          <RenderIf condition={requestBody->isEmptyString}>
            <div> {"No Request"->React.string} </div>
          </RenderIf>
        </div>
      | Response =>
        <div className="pl-4">
          <div className="flex items-center gap-2 mb-2">
            <div> {"Status Code: "->React.string} </div>
            <TableUtils.LabelCell
              labelColor={WebhooksUtils.labelColor(statusCode)} text={statusCode->Int.toString}
            />
          </div>
          <div> {"Headers"->React.string} </div>
          <div className="m-3 p-3 border border-grey-300 rounded-md max-w-[40rem]">
            {headersValues(responseHeaders)}
          </div>
          <RenderIf condition={errorMessage->Option.isSome}>
            <div className="flex gap-2">
              <div> {"Error Message:"->React.string} </div>
              <div> {errorMessage->Option.getOr("")->React.string} </div>
            </div>
          </RenderIf>
          <div className="flex justify-between mr-2">
            <div className="mt-2"> {"Body"->React.string} </div>
            <RenderIf condition={!noResponse}>
              <HelperComponents.CopyTextCustomComp
                displayValue=Some("") copyValue={Some(responseBody)} customTextCss="text-nowrap"
              />
            </RenderIf>
          </div>
          <RenderIf condition={responseBody->isEmptyString}>
            <div> {"No Response"->React.string} </div>
          </RenderIf>
          <RenderIf condition={responseBody->isNonEmptyString}>
            <RenderIf condition={noResponse}>
              <div className="text-center"> {"No Response"->React.string} </div>
            </RenderIf>
            <RenderIf condition={!noResponse}>
              <PrettyPrintJson jsonToDisplay=responseBody />
            </RenderIf>
          </RenderIf>
        </div>
      }}
    </div>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  open LogicUtils
  open WebhooksUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => JSON.Encode.null)
  let (offset, setOffset) = React.useState(_ => 0)
  let (selectedEvent, setSelectedEvent) = React.useState(_ =>
    Dict.make()->itemToObjectMapperAttempts
  )

  let fetchWebhooksEventDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let url = getURL(~entityName=V1(WEBHOOK_EVENTS_ATTEMPTS), ~methodType=Get, ~id=Some(id))
      let response = await fetchDetails(url)
      let item =
        response
        ->getArrayDataFromJson(itemToObjectMapperAttempts)
        ->Array.find(field => {
          field.eventId == id
        })
      switch item {
      | Some(item) => setSelectedEvent(_ => item)
      | None => ()
      }
      setData(_ => response)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) => {
          let errorCode = message->safeParse->getDictFromJsonObject->getString("code", "")
          let errorMessage = message->safeParse->getDictFromJsonObject->getString("message", "")

          switch errorCode->CommonAuthUtils.errorSubCodeMapper {
          | HE_02 => showToast(~message=errorMessage, ~toastType=ToastError)
          | _ =>
            showToast(~message="Failed to fetch data", ~toastType=ToastError)
            setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data"))
          }
        }
      | None => {
          showToast(~message="Failed to fetch data", ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data"))
        }
      }
    }
  }

  let retryWebhook = async () => {
    try {
      let url = getURL(
        ~entityName=V1(WEBHOOKS_EVENTS_RETRY),
        ~methodType=Post,
        ~id=Some(selectedEvent.eventId),
      )
      let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Post)
      fetchWebhooksEventDetails()->ignore
    } catch {
    | Exn.Error(_) => showToast(~message="Failed to retry webhook", ~toastType=ToastError)
    }
  }

  let handleClickItem = (val: WebhooksTypes.attemptTable) => {
    let item =
      data
      ->getArrayDataFromJson(itemToObjectMapperAttempts)
      ->Array.find(field => {
        field.eventId == val.eventId
      })
      ->Option.getOr(Dict.make()->itemToObjectMapperAttempts)
    setSelectedEvent(_ => item)
  }

  React.useEffect(() => {
    fetchWebhooksEventDetails()->ignore
    None
  }, [])

  let attemptTableArr = data->getArrayDataFromJson(itemToObjectMapperAttemptsTable)

  let table =
    <LoadedTable
      title=" "
      hideTitle=true
      actualData={attemptTableArr->Array.map(Nullable.make)}
      totalResults={attemptTableArr->Array.length}
      resultsPerPage=20
      entity={WebhooksDetailsTableEntity.webhooksDetailsEntity()}
      onEntityClick={val => handleClickItem(val)}
      offset
      setOffset
      currrentFetchCount={attemptTableArr->Array.map(Nullable.make)->Array.length}
      collapseTableRow=false
      showSerialNumber=true
      highlightSelectedRow=true
    />

  let tabList: array<Tabs.tab> = [
    {
      title: "Request",
      renderContent: () => <TabDetails activeTab=Request selectedEvent />,
    },
    {
      title: "Response",
      renderContent: () => <TabDetails activeTab=Response selectedEvent />,
    },
  ]

  let details =
    <Tabs
      tabs=tabList
      showBorder=false
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      textStyle="text-blue-600"
      selectTabBottomBorderColor="bg-blue-600"
    />

  <div className="flex flex-col gap-4">
    <PageUtils.PageHeading title="Webhooks" subTitle="" />
    <BreadCrumbNavigation
      path=[{title: "Webhooks", link: "/webhooks"}]
      currentPageTitle="Webhooks home"
      cursorStyle="cursor-pointer"
    />
    <PageLoaderWrapper screenState>
      <div className="flex gap-2">
        <div> {table} </div>
        <div
          className="flex flex-col gap-2 border rounded-md bg-white max-w-full overflow-auto p-2">
          <RenderIf condition={!(selectedEvent.deliveryAttempt->LogicUtils.isEmptyString)}>
            <div className="flex justify-between items-center mx-2 mt-5">
              <div className="flex items-center gap-2  text-fs-14 border rounded-md py-1 px-2">
                <span className="text-nd_gray-400">
                  {"Delivery Attempt Type: "->React.string}
                </span>
                <span className="text-nd_gray-700">
                  {selectedEvent.deliveryAttempt->LogicUtils.snakeToTitle->React.string}
                </span>
              </div>
              <Button text="Retry Webhook" onClick={_ => retryWebhook()->ignore} buttonSize=Small />
            </div>
          </RenderIf>
          <div> {details} </div>
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
