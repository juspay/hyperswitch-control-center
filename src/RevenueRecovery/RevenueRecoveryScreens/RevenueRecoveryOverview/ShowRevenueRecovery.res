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
    <div className="flex flex-col mb-6  w-full">
      <ShowOrderDetails
        data=order
        getHeading=getHeadingForSummary
        getCell=getCellForSummary
        detailsFields=[OrderAmount, Created, PaymentId, ProductName]
        isButtonEnabled=true
      />
      <ShowOrderDetails
        data=order
        getHeading=getHeadingForAboutPayment
        getCell=getCellForAboutPayment
        detailsFields=[Connector, ProfileId, PaymentMethodType, CardNetwork, MandateId]
      />
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
    <div className="border rounded-lg w-full h-fit p-5">
      <div className="font-bold text-lg mb-5 px-4"> {"Attempts History"->React.string} </div>
      <div className="p-5 flex flex-col gap-10">
        {order.attempts
        ->Array.mapWithIndex((item, index) => {
          <div className="flex gap-5">
            <div> {`#${index->Int.toString}`->React.string} </div>
            <div className="border rounded-full w-10 h-10 border-[#D99530]" />
            <div className="border rounded-lg w-full px-2">
              <ShowOrderDetails
                data=item
                getHeading=getAttemptHeading
                getCell=getAttemptCell
                detailsFields=[Connector, Status, ErrorMessage]
              />
            </div>
          </div>
        })
        ->React.array}
      </div>
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

      let ordersUrl = `https://integ-api.hyperswitch.io/v2/payments/${id}` //getURL(~entityName=V2(V2_ORDERS_LIST), ~methodType=Get, ~id=Some(id))
      //let res = await fetchDetails(ordersUrl)

      let res = {
        "invoice_id": "12345_pay_0195271cac557080822f14a168ff70f2",
        "payment_id": "",
        "merchant_id": "",
        "net_amount": 0,
        "order_amount": 100,
        "status": "succeeded",
        "amount": 0,
        "amount_capturable": 0,
        "amount_received": 0,
        "created": "2025-02-21T06:05:45.445Z",
        "last_updated": "",
        "currency": "",
        "customer_id": "",
        "description": "",
        "setup_future_usage": "",
        "capture_method": "",
        "payment_method": "",
        "payment_method_type": "card",
        "payment_token": "",
        "shipping": "Karwar, Karnataka, 581301.",
        "shippingEmail": "example@example.com",
        "shippingPhone": " NA",
        "email": "",
        "name": "",
        "phone": " NA",
        "return_url": "https://google.com/success",
        "authentication_type": "no_three_ds",
        "statement_descriptor_name": "",
        "statement_descriptor_suffix": "",
        "next_action": "",
        "cancellation_reason": "",
        "error_code": "",
        "error_message": "",
        "connector": "stripe",
        "order_quantity": "",
        "product_name": "",
        "card_brand": "",
        "payment_experience": "",
        "frm_message": {
          "frm_name": "",
          "frm_transaction_id": "",
          "frm_transaction_type": "",
          "frm_status": "",
          "frm_score": 0,
          "frm_reason": "",
          "frm_error": "",
        },
        "connector_transaction_id": "pi_3QupMuD5R7gDAGff0pixKJm2",
        "merchant_connector_id": "mca_Gj55f0UYrVIQUClz4fhG",
        "merchant_decision": "",
        "profile_id": "",
        "disputes": [],
        "attempts": [
          {
            "id": "",
            "status": "charged",
            "amount": 10000,
            "currency": "",
            "connector": "moneris",
            "error_message": "",
            "payment_method": "card",
            "connector_reference_id": "",
            "capture_method": "automatic",
            "authentication_type": "no_three_ds",
            "cancellation_reason": "",
            "mandate_id": "",
            "error_code": "",
            "payment_token": "",
            "connector_metadata": "",
            "payment_experience": "",
            "payment_method_type": "credit",
            "reference_id": "pi0001JNQPNBESNE73J6J75NP55QKY",
            "client_source": "Payment",
            "client_version": "0.117.1",
            "attempt_amount": 0,
          },
        ],
        "merchant_order_reference_id": "",
        "attempt_count": 0,
        "connector_label": "NA",
        "attempt_amount": 100,
      }->Identity.genericTypeToJson

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
          <PageUtils.PageHeading title="Invoice summary" />
        </div>
        <div className="flex gap-2 ">
          <ACLButton
            text="Stop Recovery"
            customButtonStyle="!w-fit"
            buttonType={Primary}
            buttonState={Disabled}
          />
        </div>
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
      <Attempts order={revenueRecoveryData} />
    </div>
  </div>
}
