open RevenueRecoveryEntity
open LogicUtils
open RecoveryOverviewHelper
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
          detailsFields=[OrderAmount, Created, LastUpdated, PaymentId, ProductName]
          isButtonEnabled=true
        />
      </div>
      <div className="w-full">
        <div className={`${headingStyles}`}> {"Payment Details"->React.string} </div>
        <ShowOrderDetails
          data=order
          getHeading=getHeadingForAboutPayment
          getCell=getCellForAboutPayment
          detailsFields=[Connector, ProfileId, PaymentMethod, CardNetwork, MandateId]
        />
      </div>
    </div>
  }
}

@react.component
let make = (~id) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ =>
    Dict.make()->RevenueRecoveryEntity.itemToObjMapper
  )
  let showToast = ToastState.useShowToast()
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      // let res = await fetchDetails(url)
      let res = {
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "merchant_id": "merchant_1668273825",
          "profile_id": "<string>",
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "payment_method_id": "<string>",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "created": "2022-09-10T10:11:12Z",
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector": "adyen",
          "merchant_connector_id": "<string>",
          "customer": {
            "id": "cus_y3oqhf46pyzuxjbcn2giaqnb44",
            "name": "John Doe",
            "email": "johntest@test.com",
            "phone": "9123456789",
            "phone_country_code": "+1",
          },
          "merchant_reference_id": "pay_mbabizu24mvu3mela5njyhpit4",
          "connector_payment_id": "993672945374576J",
          "connector_response_reference_id": "<string>",
          "metadata": "{}",
          "description": "It's my first payment request",
          "authentication_type": "three_ds",
          "capture_method": "automatic",
          "setup_future_usage": "off_session",
          "attempt_count": 123,
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "cancellation_reason": "<string>",
          "order_details": "[{\n        \"product_name\": \"gillete creme\",\n        \"quantity\": 15,\n        \"amount\" : 900\n    }]",
          "return_url": "https://hyperswitch.io",
          "statement_descriptor_name": "Hyperswitch Router",
          "statement_descriptor_suffix": "Payment for shoes purchase",
          "allowed_payment_method_types": ["ach"],
          "authorization_count": 123,
          "modified_at": "2022-09-10T10:11:12Z",
        }
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
  </div>
}
