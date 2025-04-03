module ShowOrderDetails = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-full",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~isButtonEnabled=false,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~customFlex="flex-wrap",
    ~isHorizontal=false,
    ~isModal=false,
  ) => {
    <FormRenderer.DesktopRow itemWrapperClass="">
      <div
        className={`grid grid-cols-2 dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border `}>
        {detailsFields
        ->Array.mapWithIndex((colType, i) => {
          <div className=widthClass key={i->Int.toString}>
            <ReconReportsHelper.DisplayKeyValueParams
              heading={getHeading(colType)}
              value={getCell(data, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overiddingHeadingStyles=" flex text-nd_gray-400 text-sm font-medium"
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
  let make = (~reportDetails, ~isModal) => {
    <div className="w-full mb-6 ">
      <ShowOrderDetails
        data=reportDetails
        getHeading={ReportsTableEntity.getHeading}
        getCell={ReportsTableEntity.getCell}
        detailsFields=[
          OrderId,
          TransactionId,
          PaymentGateway,
          PaymentMethod,
          TxnAmount,
          SettlementAmount,
          TransactionDate,
        ]
        isButtonEnabled=true
        isModal
      />
    </div>
  }
}
@react.component
let make = (~isModal, ~setShowModal, ~selectedId) => {
  open ReconReportUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let showToast = ToastState.useShowToast()
  let (reconReport, setReconReport) = React.useState(_ =>
    Dict.make()->ReconReportUtils.getAllReportPayloadType
  )
  let handleAboutPaymentsClick = () => {
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url=`/v2/recon/reports/${reconReport.transaction_id}`),
    )
  }

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)
      setReconReport(_ => selectedId)
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

  switch reconReport.recon_status->getReconStatusTypeFromString {
  | Reconciled =>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col px-6">
        <OrderInfo reportDetails=reconReport isModal />
      </div>
      <Button
        text="OK"
        buttonType=Primary
        onClick={_ => setShowModal(_ => false)}
        customButtonStyle="w-full"
      />
    </PageLoaderWrapper>
  | Unreconciled =>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col px-6">
        <OrderInfo reportDetails=reconReport isModal />
        <div className="gap-6 border-t">
          <div className="flex flex-col gap-2 my-6">
            <p className="text-nd_gray-400  text-sm font-medium"> {"Reason"->React.string} </p>
            <p className="text-base font-medium text-nd_gray-600">
              {"Missing (Payment Gateway processed payment, but no bank settlement found."->React.string}
            </p>
          </div>
        </div>
      </div>
      <Button
        text="More Details "
        buttonType=Primary
        onClick={_ => handleAboutPaymentsClick()}
        customButtonStyle="w-full"
      />
    </PageLoaderWrapper>
  | Missing =>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col px-6">
        <OrderInfo reportDetails=reconReport isModal />
        <div className="gap-6 border-t">
          <div className="flex flex-col gap-2 my-6">
            <p className="text-nd_gray-400  text-sm font-medium"> {"Reason"->React.string} </p>
            <p className="text-base font-medium text-nd_gray-600">
              {"Missing (Payment Gateway processed payment, but no bank settlement found."->React.string}
            </p>
          </div>
        </div>
      </div>
      <Button
        text="OK"
        buttonType=Primary
        onClick={_ => setShowModal(_ => false)}
        customButtonStyle="w-full"
      />
    </PageLoaderWrapper>
  }
}
