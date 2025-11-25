open RevenueRecoveryEntity
open LogicUtils
open RecoveryInvoicesHelper

module DisplayValues = {
  open Typography

  @react.component
  let make = (
    ~heading: Table.header,
    ~value: Table.cell,
    ~isInHeader=false,
    ~customDateStyle="",
    ~wordBreak=true,
    ~textColor="",
  ) => {
    <AddDataAttributes attributes=[("data-label", heading.title)]>
      <div className="grid grid-cols-10">
        <div className="flex items-center col-span-3">
          <div className={`${body.sm.medium} text-nd_gray-500`}>
            {heading.title->React.string}
          </div>
        </div>
        <div
          className={`flex-1 flex justify-left ml-4 ${body.md.semibold} text-nd_gray-800 col-span-7`}>
          <Table.TableCell
            cell=value
            textAlign=Table.Right
            fontBold=false
            customMoneyStyle="!font-normal"
            labelMargin="!py-0"
            customDateStyle
          />
        </div>
      </div>
    </AddDataAttributes>
  }
}

module OrderDetailsCard = {
  open RevenueRecoveryOrderTypes

  @react.component
  let make = (
    ~order: order,
    ~getHeading: colType => Table.header,
    ~getCell: (order, colType) => Table.cell,
    ~detailsFields: array<colType>,
  ) => {
    <div
      className="bg-white border border-nd_gray-200 rounded-xl px-7 py-6 ml-6 flex flex-col gap-6">
      {detailsFields
      ->Array.mapWithIndex((colType, i) => {
        <div key={i->Int.toString}>
          <DisplayValues heading={getHeading(colType)} value={getCell(order, colType)} />
        </div>
      })
      ->React.array}
    </div>
  }
}

module RecoveryAmountStatus = {
  open RevenueRecoveryOrderTypes
  open RevenueRecoveryOrderUtils
  open Typography
  open InvoiceDetailsPageUtils

  @react.component
  let make = (~order: order, ~processTracker: Dict.t<JSON.t>) => {
    let orderAmount = order.order_amount
    let amountCaptured = order.amount_captured
    let status: RevenueRecoveryOrderTypes.recoveryInvoiceStatus = order.status->statusVariantMapper

    let scheduledTime = if !(processTracker->isEmptyDict) {
      let scheduleTime = processTracker->getString("schedule_time_for_payment", "")
      scheduleTime->isNonEmptyString ? Some(scheduleTime) : None
    } else {
      None
    }

    switch status {
    | Recovered =>
      <div
        className="bg-nd_green-150 border border-nd_green-500 rounded-xl p-4 flex items-start gap-3">
        <Icon name="nd-check-circle-outline" size=20 className="mt-0.5" />
        <div className="flex-1">
          <div className={`${heading.xs.semibold} text-nd_gray-800 mb-1`}>
            {"Fully recovered"->React.string}
          </div>
          <div className={`${body.md.regular} text-nd_gray-600`}>
            {"This invoice was successfully recovered."->React.string}
          </div>
        </div>
      </div>
    | Scheduled | Processing | PartiallyCapturedAndProcessing =>
      <div className="bg-white border border-nd_gray-200 rounded-xl p-6">
        <div className="flex items-center justify-between mb-4">
          <div className={`${heading.md.semibold} text-nd_gray-900`}>
            {`${amountCaptured->formatCurrency} / ${orderAmount->formatCurrency} `->React.string}
            <span className={`${body.lg.regular} ml-1`}> {"Recovered"->React.string} </span>
          </div>
        </div>
        <div className="mb-4">
          <SegmentedProgressBar orderAmount amountCaptured className="w-fit" />
        </div>
        {switch scheduledTime {
        | Some(time) =>
          let convertedTime = time->RevenueRecoveryOrderUtils.convertScheduleTimeToUTC
          <>
            <div className="border-t-2 border-nd_gray-200 my-5" />
            <div className={`flex items-center gap-2 ${body.md.regular}`}>
              <div className="w-2 h-2 bg-nd_orange-300 rounded-full mx-1" />
              <span className="text-nd_gray-500 flex gap-1">
                {`Retry to recover ${(orderAmount -. amountCaptured)
                    ->formatCurrency} is scheduled for `->React.string}
                {<Table.DateCell timestamp=convertedTime isCard=true />}
              </span>
            </div>
          </>
        | None => React.null
        }}
      </div>
    | Queued | NoPicked =>
      <div
        className="bg-nd_gray-100 border border-nd_gray-300 rounded-xl p-4 flex items-start gap-3">
        <Icon name="nd-payment-queued" size=20 className="text-nd_gray-600 mt-0.5" />
        <div className="flex-1">
          <div className={`${heading.xs.semibold} text-nd_gray-800 mb-1`}>
            {"Recovery not started"->React.string}
          </div>
          <div className={`${body.md.regular} text-nd_gray-600`}>
            {"This invoice is queued. Retries will begin soon."->React.string}
          </div>
        </div>
      </div>
    | Terminated =>
      if amountCaptured > 0.0 {
        <div
          className="bg-nd_orange-150 border border-nd_orange-200 rounded-xl p-4 flex items-start gap-3">
          <Icon name="nd-payment-partial-captured" size=20 className="text-nd_orange-600 mt-0.5" />
          <div className="flex-1">
            <div className={`${heading.xs.semibold} text-nd_gray-800 mb-1`}>
              {"Partially recovered invoice"->React.string}
            </div>
            <div className={`${body.md.regular} text-nd_gray-600`}>
              {`${amountCaptured->formatCurrency} recovered out of ${orderAmount->formatCurrency}.`->React.string}
            </div>
          </div>
        </div>
      } else {
        <div
          className="bg-nd_red-50 border border-nd_red-600 rounded-xl p-4 flex items-start gap-3">
          <Icon name="nd-payment-terminal" size=20 className="text-nd_red-600 mt-0.5" />
          <div className="flex-1">
            <div className={`${heading.xs.semibold} text-nd_gray-800 mb-1`}>
              {"Unable to Recover Invoice"->React.string}
            </div>
            <div className={`${body.md.regular} text-nd_gray-600`}>
              {"This invoice couldn't be recovered."->React.string}
            </div>
          </div>
        </div>
      }
    | PartiallyRecovered =>
      <div
        className="bg-nd_orange-150 border border-nd_orange-200 rounded-xl p-4 flex items-start gap-3">
        <Icon name="nd-payment-partial-captured" size=20 className="text-nd_orange-600 mt-0.5" />
        <div className="flex-1">
          <div className={`${heading.xs.semibold} text-nd_gray-800 mb-1`}>
            {"Partially recovered invoice"->React.string}
          </div>
          <div className={`${body.md.regular} text-nd_gray-600`}>
            {`${amountCaptured->formatCurrency} recovered out of ${orderAmount->formatCurrency}.`->React.string}
          </div>
        </div>
      </div>
    | Monitoring | Other(_) =>
      <div className="bg-white border border-nd_gray-200 rounded-xl p-6">
        <div className="flex items-center justify-between mb-4">
          <div className={`${heading.md.semibold} text-nd_gray-900`}>
            {`${amountCaptured->formatCurrency} / ${orderAmount->formatCurrency} `->React.string}
            <span className={`${body.lg.regular} ml-1`}> {"Recovered"->React.string} </span>
          </div>
        </div>
        <div className="mb-4">
          <SegmentedProgressBar orderAmount amountCaptured className="w-fit" />
        </div>
      </div>
    }
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  open RevenueRecoveryOrderUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ =>
    Dict.make()->RevenueRecoveryEntity.itemToObjMapper
  )
  let (processTrackerData, setProcessTrackerData) = React.useState(_ => Dict.make())
  let showToast = ToastState.useShowToast()
  let (attemptsList, setAttemptsList) = React.useState(_ => [])

  let getPTDetails = async (~orderData: RevenueRecoveryOrderTypes.order) => {
    try {
      let processTrackerUrl = getURL(
        ~entityName=V2(PROCESS_TRACKER),
        ~methodType=Get,
        ~id=Some(orderData.id),
      )
      let processTrackerData = await fetchDetails(processTrackerUrl, ~version=V2)

      let processTrackerDataDict = processTrackerData->getDictFromJsonObject
      setProcessTrackerData(_ => processTrackerDataDict)
      let processTrackeStatus = processTrackerDataDict->getString("status", "")

      let orderDetails = if (
        processTrackerDataDict->Dict.keysToArray->Array.length > 0 &&
          processTrackeStatus != Finish->schedulerStatusStringMapper
      ) {
        {
          ...orderData,
          status: Scheduled->statusStringMapper,
        }
      } else {
        orderData
      }
      setRevenueRecoveryData(_ => orderDetails)
    } catch {
    | Exn.Error(_) => setRevenueRecoveryData(_ => orderData)
    }
  }

  let fetchOrderAttemptListDetails = async _ => {
    try {
      let url = getURL(~entityName=V2(V2_ATTEMPTS_LIST), ~methodType=Get, ~id=Some(id))
      let data = await fetchDetails(url, ~version=V2)

      let array =
        data
        ->getDictFromJsonObject
        ->getArrayFromDict("payment_attempt_list", [])
        ->JSON.Encode.array
        ->getAttempts
        ->Array.filter(item => item.status !== "started")

      array->Array.reverse

      setAttemptsList(_ => array)
    } catch {
    | _ => ()
    }
  }

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      let url = getURL(~entityName=V2(V2_RECOVERY_INVOICES_LIST), ~methodType=Get, ~id=Some(id))
      let data = await fetchDetails(url, ~version=V2)

      let orderData =
        data
        ->getDictFromJsonObject
        ->RevenueRecoveryEntity.itemToObjMapperForIntents

      if orderData.status->RevenueRecoveryOrderUtils.statusVariantMapper == Scheduled {
        await getPTDetails(~orderData)
      } else {
        setRevenueRecoveryData(_ => orderData)
      }

      fetchOrderAttemptListDetails()->ignore

      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("HE_02") {
          setScreenState(_ => Custom)
        } else {
          showToast(~message="Failed to Fetch!", ~toastType=ToastState.ToastError)
          setScreenState(_ => Error("Failed to Fetch!"))
        }

      | None => setScreenState(_ => Error("Failed to Fetch!"))
      }
    }
  }

  React.useEffect(() => {
    fetchOrderDetails()->ignore
    None
  }, [])

  <div className="flex flex-col gap-8">
    <BreadCrumbNavigation
      path=[{title: "Invoices", link: "/v2/recovery/invoices"}]
      currentPageTitle=id
      cursorStyle="cursor-pointer"
      customTextClass="text-nd_gray-400"
      titleTextClass="text-nd_gray-600 font-medium"
      fontWeight="font-medium"
      dividerVal=Slash
      childGapClass="gap-2"
    />
    <div className="flex flex-col gap-10">
      <div className="flex flex-row justify-between items-center">
        <div className="flex gap-2 items-center">
          <PageUtils.PageHeading title="Invoice Recovery Details" />
        </div>
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="Payment does not exists in out record" renderType=NotFound
        />}>
        <div className="w-full grid grid-cols-10">
          <div className="w-full h-full col-span-7 flex flex-col gap-7">
            <RecoveryAmountStatus order={revenueRecoveryData} processTracker={processTrackerData} />
            <AttemptsHistory
              order={revenueRecoveryData} attemptsList processTracker={processTrackerData->Some}
            />
          </div>
          <div className="w-full h-full col-span-3">
            <OrderDetailsCard
              order=revenueRecoveryData
              getHeading
              getCell
              detailsFields=[Id, Created, OrderAmount, Status, Connector]
            />
          </div>
        </div>
      </PageLoaderWrapper>
    </div>
  </div>
}
