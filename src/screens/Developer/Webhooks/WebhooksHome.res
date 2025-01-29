@react.component
let make = (~id) => {
  open APIUtils
  open LogicUtils
  open WebhooksUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (data, setData) = React.useState(_ => JSON.Encode.null)
  let (retryData, setRetryData) = React.useState(_ => JSON.Encode.null)
  let (offset, setOffset) = React.useState(_ => 0)
  let (selectedEvent, setSelectedEvent) = React.useState(_ =>
    Dict.make()->itemToObjectMapperAttempts
  )
  let (requestBody, setRequestBody) = React.useState(_ => "")
  let (responseBody, setResponseBody) = React.useState(_ => "")

  let fetchWebhooksEventDetails = async () => {
    try {
      let url = getURL(~entityName=WEBHOOK_EVENTS_ATTEMPTS, ~methodType=Get, ~id=Some(id))
      let response = await fetchDetails(url)
      setData(_ => response)
    } catch {
    | Exn.Error(_) => showToast(~message="Failed to fetch data", ~toastType=ToastError)
    }
  }

  let retryWebhook = async () => {
    try {
      let url = getURL(
        ~entityName=WEBHOOKS_EVENTS_RETRY,
        ~methodType=Post,
        ~id=Some(selectedEvent.eventId),
      )
      let response = await updateDetails(url, Dict.make()->JSON.Encode.object, Post)
      setRetryData(_ => response)
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
  }, [retryData])

  React.useEffect(() => {
    let item =
      data
      ->getArrayDataFromJson(itemToObjectMapperAttempts)
      ->Array.find(field => {
        field.eventId == id
      })
    switch item {
    | Some(item) => setSelectedEvent(_ => item)
    | None => ()
    }
    None
  }, (id, data))

  React.useEffect(() => {
    setRequestBody(_ => selectedEvent.request->getDictFromJsonObject->getString("body", ""))
    setResponseBody(_ => selectedEvent.response->getDictFromJsonObject->getString("body", ""))
    None
  }, [selectedEvent])

  let attemptTableArr = data->getArrayDataFromJson(itemToObjectMapperAttemptsTable)

  let table =
    <LoadedTable
      title=" "
      hideTitle=true
      actualData={attemptTableArr->Array.map(Nullable.make)}
      totalResults={attemptTableArr->Array.length}
      resultsPerPage=20
      entity={WebhooksHomeTableEntity.webhooksDetailsEntity()}
      onEntityClick={val => handleClickItem(val)}
      offset
      setOffset
      currrentFetchCount={attemptTableArr->Array.map(Nullable.make)->Array.length}
      collapseTableRow=false
      showSerialNumber=true
    />

  let details =
    <div className="p-2 divide-y">
      <div>
        <HelperComponents.CopyTextCustomComp
          displayValue="Request" copyValue={Some(requestBody)} customTextCss="text-nowrap m-2"
        />
        <RenderIf condition={requestBody->isNonEmptyString}>
          <PrettyPrintJson jsonToDisplay=requestBody />
        </RenderIf>
        <RenderIf condition={requestBody->isEmptyString}>
          <div> {"No Request"->React.string} </div>
        </RenderIf>
      </div>
      <div>
        <HelperComponents.CopyTextCustomComp
          displayValue="Response" copyValue={Some(responseBody)} customTextCss="text-nowrap m-2"
        />
        <RenderIf condition={responseBody->isNonEmptyString}>
          <RenderIf condition={responseBody->String.includes("404")}>
            <div className="text-center"> {"No Response"->React.string} </div>
          </RenderIf>
          <RenderIf condition={!(responseBody->String.includes("404"))}>
            <PrettyPrintJson jsonToDisplay=responseBody />
          </RenderIf>
        </RenderIf>
        <RenderIf condition={responseBody->isEmptyString}>
          <div> {"No Response"->React.string} </div>
        </RenderIf>
      </div>
    </div>

  <div className="flex flex-col gap-4">
    <PageUtils.PageHeading title="Webhooks" subTitle="" />
    <BreadCrumbNavigation
      path=[{title: "Webhooks", link: "/webhooks"}]
      currentPageTitle="Webhooks home"
      cursorStyle="cursor-pointer"
    />
    <div className="grid grid-cols-2 ">
      <div> {table} </div>
      <div className="border border-grey-300 bg-white">
        <RenderIf condition={!(selectedEvent.deliveryAttempt->LogicUtils.isEmptyString)}>
          <div className="flex justify-between items-center mx-5 my-4">
            <TableUtils.LabelCell
              labelColor=LabelDarkGreen
              text={selectedEvent.deliveryAttempt->LogicUtils.snakeToTitle}
            />
            <Button text="Retry Webhook" onClick={_ => retryWebhook()->ignore} buttonSize=XSmall />
          </div>
        </RenderIf>
        <div> {details} </div>
      </div>
    </div>
  </div>
}
