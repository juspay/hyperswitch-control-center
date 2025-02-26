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
            <ReconReportsHelper.DisplayKeyValueParams
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
  let make = (~exceptionReportDetails) => {
    open ReportsExceptionTableEntity

    <div className="w-full mb-6 ">
      <ShowOrderDetails
        data=exceptionReportDetails
        getHeading
        getCell
        detailsFields=[TransactionId, OrderId, PaymentGateway, PaymentMethod]
        isButtonEnabled=true
      />
    </div>
  }
}
@react.component
let make = () => {
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let showToast = ToastState.useShowToast()
  let (offset, setOffset) = React.useState(_ => 0)
  let (reconExceptionReport, setReconExceptionReport) = React.useState(_ =>
    Dict.make()->ReportsExceptionTableEntity.getExceptionReportPayloadType
  )
  let (attemptData, setAttemptData) = React.useState(_ => [])

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      // let res = await fetchDetails(url)
      let res = {
        {
          "transaction_id": "1234",
          "order_id": "Ord_5678",
          "payment_gateway": "Stripe",
          "payment_method": "Credit Card",
          "txn_amount": 324.0,
          "recon_status": "Unreconciled",
          "mismatch_amount": 93.0,
          "exception_status": "Under Review",
          "exception_type": "Status Mismatch",
          "last_updated": "Jan 22, 2025 03:25PM",
          "actions": "View",
        }
      }->Identity.genericTypeToJson
      let orderForAttempts = ReportsExceptionTableEntity.getArrayOfReportsAttemptsListPayloadType(
        res->getArrayFromJson([]),
      )
      let order = ReportsExceptionTableEntity.getExceptionReportPayloadType(
        res->getDictFromJsonObject,
      )
      setAttemptData(_ => orderForAttempts)
      setReconExceptionReport(_ => order)
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
  let statusUI = ReportsExceptionTableEntity.useGetStatus(reconExceptionReport)
  <div className="flex flex-col gap-8">
    <BreadCrumbNavigation
      path=[{title: "Recon", link: `/v2/recon/reports`}]
      currentPageTitle="Exceptions Summary"
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
          <PageUtils.PageHeading title={`${reconExceptionReport.transaction_id}`} />
          {statusUI}
        </div>
        <div className="flex gap-2 ">
          <ACLButton text="Contact Processor" customButtonStyle="!w-fit" buttonType={Secondary} />
          <ACLButton text="Resolve" customButtonStyle="!w-fit" buttonType={Primary} />
        </div>
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="Payment does not exists in out record" renderType=NotFound
        />}>
        <OrderInfo exceptionReportDetails=reconExceptionReport />
        <LoadedTable
          title="Exception Matrix"
          actualData={attemptData->Array.map(Nullable.make)}
          entity={ReportsExceptionTableEntity.exceptionAttemptsEntity()}
          totalResults={attemptData->Array.length}
          resultsPerPage=20
          offset
          setOffset
          currrentFetchCount={attemptData->Array.length}
        />
      </PageLoaderWrapper>
    </div>
  </div>
}
