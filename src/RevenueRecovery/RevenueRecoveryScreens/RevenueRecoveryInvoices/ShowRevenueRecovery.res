open RevenueRecoveryEntity
open LogicUtils
open RecoveryInvoicesHelper

module ShowOrderDetails = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-1/3",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~isButtonEnabled=false,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~customFlex="flex-wrap",
    ~isHorizontal=false,
  ) => {
    <FormRenderer.DesktopRow>
      <div
        className={`flex ${customFlex} ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border `}>
        {detailsFields
        ->Array.mapWithIndex((colType, i) => {
          <div className=widthClass key={i->Int.toString}>
            <DisplayKeyValueParams
              heading={getHeading(colType)}
              value={getCell(data, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overiddingHeadingStyles="text-nd_gray-400 text-sm font-medium"
              isHorizontal
            />
          </div>
        })
        ->React.array}
      </div>
    </FormRenderer.DesktopRow>
  }
}
module OrderInfo = {
  @react.component
  let make = (~order) => {
    <div className="flex flex-col mb-6  w-full">
      <ShowOrderDetails
        data=order
        getHeading
        getCell
        detailsFields=[Id, Status, OrderAmount, Connector, PaymentMethodType]
        isButtonEnabled=true
      />
    </div>
  }
}

module Attempts = {
  @react.component
  let make = (~id) => {
    open APIUtils
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (attemptsList, setAttemptsList) = React.useState(_ => [])
    let (nextScheduleTime, setNextScheduleTime) = React.useState(_ => JSON.Encode.string(""))

    let getStyle = status => {
      let orderStatus = status->HSwitchOrderUtils.refundStatusVariantMapper

      switch orderStatus {
      | Success => ("green-status", "nd-check")
      | Failure => ("red-status", "nd-alert-triangle-outline")
      | _ => ("orange-status", "nd-calender")
      }
    }

    let fetchProcessTrackerDetails = async _ => {
      try {
        let url = getURL(~entityName=V2(PROCESS_TRACKER), ~methodType=Get, ~id=Some(id))
        let data = await fetchDetails(url, ~version=V2)

        setNextScheduleTime(_ => data)
      } catch {
      | _ => ()
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

    React.useEffect(() => {
      fetchOrderAttemptListDetails()->ignore
      fetchProcessTrackerDetails()->ignore
      None
    }, [])

    let scheduleTimeComponent = {
      let (border, icon) = ""->getStyle

      let dict = nextScheduleTime->getDictFromJsonObject

      <RenderIf
        condition={dict->Dict.keysToArray->Array.length > 0 &&
          dict->getString("status", "") != "finish"}>
        <div className="grid grid-cols-12 gap-5">
          <div className="col-span-2 flex flex-col gap-1">
            <div className="w-full flex justify-end font-semibold">
              {`#${(attemptsList->Array.length + 1)->Int.toString}`->React.string}
            </div>
            <div className="w-full flex justify-end text-xs opacity-50">
              {<Table.DateCell
                timestamp={dict->getString("schedule_time_for_payment", "")} isCard=true
              />}
            </div>
          </div>
          <div className="relative ml-7">
            <div
              className={`absolute left-0 -ml-0.5 top-0 border-1.5 p-2 rounded-full h-fit w-fit border-${border} bg-white z-10`}>
              <Icon name=icon className={`w-5 h-5 text-${border}`} />
            </div>
            <div className="ml-4 mt-10 border-l-2 border-gray-200 h-full w-1 z-20" />
          </div>
          <div className="border col-span-9 rounded-lg px-5">
            <div className="flex justify-start">
              <div className="w-1/3">
                <DisplayKeyValueParams
                  heading={getAttemptHeading(AttemptTriggeredBy)}
                  value={Text("Internal")}
                  customMoneyStyle="!font-normal !text-sm"
                  labelMargin="!py-0 mt-2"
                  overiddingHeadingStyles="text-nd_gray-400 text-sm font-medium"
                  isHorizontal=false
                />
              </div>
              <div className="w-1/3">
                <DisplayKeyValueParams
                  heading={getAttemptHeading(Status)}
                  value={Label({
                    title: dict->getString("status", "")->String.toUpperCase,
                    color: LabelBlue,
                  })}
                  customMoneyStyle="!font-normal !text-sm"
                  labelMargin="!py-0 mt-2"
                  overiddingHeadingStyles="text-nd_gray-400 text-sm font-medium"
                  isHorizontal=false
                />
              </div>
            </div>
          </div>
        </div>
      </RenderIf>
    }

    <RenderIf condition={attemptsList->Array.length > 0}>
      <div className="border rounded-lg w-full h-fit p-5">
        <div className="font-bold text-lg mb-5 px-4"> {"Attempts History"->React.string} </div>
        <div className="p-5 flex flex-col gap-11 ">
          {scheduleTimeComponent}
          {attemptsList
          ->Array.mapWithIndex((item: RevenueRecoveryOrderTypes.attempts, index) => {
            let (border, icon) = item.status->getStyle

            <div className="grid grid-cols-12 gap-5" key={index->Int.toString}>
              <div className="col-span-2 flex  flex-col gap-1 ">
                <div className="w-full flex justify-end font-semibold">
                  {`#${(attemptsList->Array.length - index)->Int.toString}`->React.string}
                </div>
                <div className="w-full flex justify-end text-xs opacity-50">
                  {<Table.DateCell timestamp={item.created} isCard=true />}
                </div>
              </div>
              <div className="relative ml-7">
                <div
                  className={`absolute left-0 -ml-0.5 top-0 border-1.5 p-2 rounded-full h-fit w-fit border-${border} bg-white z-10`}>
                  <Icon name=icon className={`w-5 h-5 text-${border}`} />
                </div>
                <RenderIf condition={index != attemptsList->Array.length - 1}>
                  <div className="ml-4 mt-10 border-l-2 border-gray-200 h-full w-1 z-20" />
                </RenderIf>
              </div>
              <div className="border col-span-9 rounded-lg px-2">
                <ShowOrderDetails
                  data=item
                  getHeading=getAttemptHeading
                  getCell=getAttemptCell
                  detailsFields=[AttemptTriggeredBy, Status, Error]
                />
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </RenderIf>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ =>
    Dict.make()->RevenueRecoveryEntity.itemToObjMapper
  )
  let showToast = ToastState.useShowToast()

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      let url = getURL(~entityName=V2(V2_ORDERS_LIST), ~methodType=Get, ~id=Some(id))
      let data = await fetchDetails(url, ~version=V2)

      setRevenueRecoveryData(_ =>
        data
        ->getDictFromJsonObject
        ->RevenueRecoveryEntity.itemToObjMapperForIntents
      )

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

  let (isExpanded, setIsExpanded) = React.useState(_ => false)

  let fetchProcessTrackerDetails = async _ => {
    try {
      let url = `${Window.env.apiBaseUrl}/v2/process_tracker/revenue_recovery_workflow/${id}/stop`
      let _ = await fetchDetails(url, ~version=V2)
      setIsExpanded(_ => false)
      showToast(~message="Success", ~toastType=ToastState.ToastError)
    } catch {
    | _ => showToast(~message="Failed to Stop the Scheduler", ~toastType=ToastState.ToastError)
    }
  }

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
          <PageUtils.PageHeading title="Invoice summary" />
        </div>
        <Button
          buttonType={Primary}
          text="Stop Recovery"
          buttonSize=Small
          onClick={_ => setIsExpanded(_ => true)}
          showBorder={true}
        />
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="Payment does not exists in out record" renderType=NotFound
        />}>
        <div className="w-full">
          <OrderInfo order=revenueRecoveryData />
        </div>
      </PageLoaderWrapper>
    </div>
    <div className="overflow-scroll">
      <Attempts id />
    </div>
    <Modal
      showModal=isExpanded
      closeOnOutsideClick=false
      setShowModal=setIsExpanded
      childClass="p-0"
      borderBottom=true
      modalClass="w-full !max-w-lg mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      <div className="fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-20">
        <div className="bg-white rounded-xl shadow-lg w-full max-w-xl p-8 relative">
          <button
            className="absolute top-6 right-6 text-gray-400 hover:text-gray-600 text-2xl font-light"
            onClick={_ => setIsExpanded(_ => false)}>
            {"X"->React.string}
          </button>
          <div className="text-2xl font-semibold text-gray-900 mb-4">
            {"Stop Recovery"->React.string}
          </div>
          <div className="text-gray-500 text-lg mb-8">
            {"Are you sure you want to stop retrying this payment? The invoice amount will remain unrecovered."->React.string}
          </div>
          <div className="flex justify-end gap-4">
            <button
              className="px-6 py-2 rounded-lg border border-gray-200 text-gray-700 font-medium bg-white hover:bg-gray-50">
              {"Cancel"->React.string}
            </button>
            <button
              className="px-6 py-2 rounded-lg bg-blue-600 text-white font-medium hover:bg-blue-700"
              onClick={_ => fetchProcessTrackerDetails()->ignore}>
              {"Confirm"->React.string}
            </button>
          </div>
        </div>
      </div>
    </Modal>
  </div>
}
