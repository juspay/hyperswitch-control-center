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
    ~isModal=false,
  ) => {
    <FormRenderer.DesktopRow>
      <div
        className={`${isModal
            ? "grid grid-cols-2"
            : "flex ${customFlex} ${justifyClassName}"} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border `}>
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
            // {CustomModalCellUtils.getHeadingForModal(colType)->React.string}
            // {CustomModalCellUtils.colTypeMapper(~report=data, ~colType)->React.string}
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
        detailsFields=[TransactionId, OrderId, PaymentGateway, PaymentMethod]
        isButtonEnabled=true
        isModal
      />
    </div>
  }
}
@react.component
let make = (~isModal, ~setShowModal) => {
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let showToast = ToastState.useShowToast()
  let (reconReport, setReconReport) = React.useState(_ =>
    Dict.make()->ReportsTableEntity.getAllReportPayloadType
  )
  let handleAboutPaymentsClick = () => {
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url=`/v2/recon/reports/${reconReport.transaction_id}`),
    )
  }
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: _ => (),
    onFocus: _ => (),
    value: Null,
    checked: true,
  }
  let assigneeDropdown = ["Jim", "Harry"]
  let assigneeOptions = assigneeDropdown->Array.map((op): SelectBox.dropdownOption => {
    {value: (op :> string), label: (op :> string)}
  })
  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      // let res = await fetchDetails(url)
      let res = {
        {
          "transaction_id": "Txn_1234",
          "order_id": "Ord_5678",
          "payment_gateway": "Stripe",
          "payment_method": "Credit Card",
          "txn_amount": 324.0,
          "settlement_amount": 324.0,
          "recon_status": "unreconciled",
          "transaction_date": "Jan 22, 2025 03:25PM",
          "actions": "",
        }
      }->Identity.genericTypeToJson

      let order = res->getDictFromJsonObject->ReportsTableEntity.getAllReportPayloadType
      setReconReport(_ => order)
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
  if reconReport.recon_status == "Reconciled" {
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      //   <div className="flex gap-2 items-center">
      //     <PageUtils.PageHeading title={`${reconExceptionReport.transaction_id}`} />
      //     // {statusUI}
      //   </div>
      <div className="flex flex-col h-[87vh] justify-between">
        <OrderInfo reportDetails=reconReport isModal />
        <Button
          text="Done"
          buttonType=Primary
          onClick={_ => setShowModal(_ => false)}
          customButtonStyle="w-full"
        />
      </div>
    </PageLoaderWrapper>
  } else {
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      //   <div className="flex gap-2 items-center">
      //     <PageUtils.PageHeading title={`${reconExceptionReport.transaction_id}`} />
      //     // {statusUI}
      //   </div>
      <div className="flex flex-col h-[87vh] justify-between ">
        <OrderInfo reportDetails=reconReport isModal />
        <div>
          <p> {"Add Assignee"->React.string} </p>
          <SelectBox.BaseDropdown
            options=assigneeOptions
            buttonText="Select Assignee"
            allowMultiSelect=false
            input
            hideMultiSelectButtons=true
            customButtonStyle="w-full"
          />
        </div>
        <div>
          <p> {"Add Note"->React.string} </p>
          <div className="border rounded-md h-12.5-rem ">
            // <p className="p-4"> {"You Can Log Comments"->React.string} </p>
            // <input placeholder="You Can Log Comments" maxLength=12 className="hover:none" />
            <input
              className="w-full border-none focus:outline-none p-2"
              placeholder="You Can Log Comments"
            />
          </div>
        </div>
        <Button
          text="More Details "
          buttonType=Primary
          onClick={_ => handleAboutPaymentsClick()}
          customButtonStyle="w-full"
        />
      </div>
    </PageLoaderWrapper>
  }
}
