open RevenueRecoveryEntity
open LogicUtils
open RecoveryOverviewHelper
open RevenueRecoveryOrderTypes
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
    let headingStyles = "font-bold text-lg mb-5 px-4"

    <div className="flex flex-col mb-10 ">
      <div className="w-full mb-6 ">
        <ShowOrderDetails
          data=order
          getHeading=getHeadingForSummary
          getCell=getCellForSummary
          detailsFields=[OrderAmount, Created, PaymentId, ProductName]
          isButtonEnabled=true
        />
      </div>
      <div className="w-full">
        <div className={`${headingStyles}`}> {"Payment Details"->React.string} </div>
        <ShowOrderDetails
          data=order
          getHeading=getHeadingForAboutPayment
          getCell=getCellForAboutPayment
          detailsFields=[Connector, ProfileId, PaymentMethodType, CardNetwork, MandateId]
        />
      </div>
    </div>
  }
}
module AttemptsSection = {
  @react.component
  let make = (~data: attempts) => {
    let widthClass = "w-1/3"
    <div className="flex flex-row flex-wrap">
      <div className="w-full p-2">
        <Details
          heading=String("Attempt Details")
          data
          detailsFields=attemptDetailsField
          getHeading=getAttemptHeading
          getCell=getAttemptCell
          widthClass
        />
      </div>
    </div>
  }
}
module Attempts = {
  @react.component
  let make = (~order) => {
    let expand = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])

    React.useEffect(() => {
      if expand != -1 {
        setExpandedRowIndexArray(_ => [expand])
      }
      None
    }, [expand])

    let onExpandClick = idx => {
      setExpandedRowIndexArray(_ => {
        [idx]
      })
    }

    let collapseClick = idx => {
      let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
      setExpandedRowIndexArray(_ => {
        let array = expandedRowIndexArray->Array.map(item => item)
        array->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])

        array
      })
    }

    let onExpandIconClick = (isCurrentRowExpanded, rowIndex) => {
      if isCurrentRowExpanded {
        collapseClick(rowIndex)
      } else {
        onExpandClick(rowIndex)
      }
    }

    let attemptsData = order.attempts->Array.toSorted((a, b) => {
      let rowValue_a = a.id
      let rowValue_b = b.id

      rowValue_a <= rowValue_b ? 1. : -1.
    })

    let heading = attemptsColumns->Array.map(getAttemptHeading)

    let rows = attemptsData->Array.map(item => {
      attemptsColumns->Array.map(colType => getAttemptCell(item, colType))
    })

    let getRowDetails = rowIndex => {
      switch attemptsData[rowIndex] {
      | Some(data) => <AttemptsSection data />
      | None => React.null
      }
    }

    <div className="flex flex-col gap-4">
      <p className="font-bold text-fs-16 text-jp-gray-900"> {"Payment Attempts"->React.string} </p>
      <CustomExpandableTable
        title="Attempts"
        heading
        rows
        onExpandIconClick
        expandedRowIndexArray
        getRowDetails
        showSerial=true
      />
    </div>
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
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      let ordersUrl = getURL(~entityName=V2(V2_ORDERS_LIST), ~methodType=Get, ~id=Some(id))
      let res = await fetchDetails(ordersUrl)

      let order = RevenueRecoveryEntity.itemToObjMapper(res->getDictFromJsonObject)
      setRevenueRecoveryData(_ => order)
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
  let statusUI = getStatus(revenueRecoveryData, primaryColor)

  <div className="flex flex-col gap-8">
    <BreadCrumbNavigation
      path=[{title: "Overview", link: "/v2/recovery/overview"}]
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
          <PageUtils.PageHeading title={`${revenueRecoveryData.invoice_id}`} />
          {statusUI}
        </div>
        //Todo: Enable Stop recovery and refund amount buttons when needed"
        // <div className="flex gap-2 ">
        //   <ACLButton text="Stop Recovery" customButtonStyle="!w-fit" buttonType={Secondary} />
        //   <ACLButton text="Refund Amount" customButtonStyle="!w-fit" buttonType={Primary} />
        // </div>
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="Payment does not exists in out record" renderType=NotFound
        />}>
        <div className="grid grid-cols-4  ">
          <div className="col-span-3">
            <OrderInfo order=revenueRecoveryData />
          </div>
          <div className="col-span-1">
            <div className="border rounded-lg rounded-b-none bg-nd_gray-100 px-4 py-2">
              <p className="text-nd_gray-700 text-base font-semibold px-2 ">
                {"Amount Details"->React.string}
              </p>
            </div>
            <div className="border border-t-none rounded-t-none rounded-lg bg-nd_gray-100 p-2">
              <ShowOrderDetails
                data=revenueRecoveryData
                widthClass="w-full"
                getHeading=getHeadingForAboutPayment
                getCell=getCellForAboutPayment
                detailsFields=[AmountCapturable, AmountReceived, AuthenticationType]
                isButtonEnabled=true
                customFlex="flex-col"
                isHorizontal=true
              />
            </div>
          </div>
        </div>
      </PageLoaderWrapper>
    </div>
    <div className="overflow-scroll">
      <Attempts order={revenueRecoveryData} />
    </div>
  </div>
}
