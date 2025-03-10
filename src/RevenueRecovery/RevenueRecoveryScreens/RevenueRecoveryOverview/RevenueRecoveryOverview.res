@react.component
let make = (~previewOnly=false) => {
  open LogicUtils
  open RevenueRecoveryOrderUtils

  let {userInfo: {merchantId, orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTime = filterValueJson->getString("start_time", "")
  let arr = Array.make(~length=offset, Dict.make())
  let showToast = ToastState.useShowToast()
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ => [])

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartdate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([("start_time", {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([("end_time", {prevStartdate})]))
  }
  //Need to integrate api
  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      // let res = await fetchDetails(url)
      let res = {
        "size": 1,
        "data": [
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
          },
        ],
      }->Identity.genericTypeToJson
      let data = getArrayDictFromRes(res)
      let total = getSizeofRes(res)

      let orderDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)

      let orderData =
        arr
        ->Array.concat(orderDataDictArr)
        ->Array.map(RevenueRecoveryEntity.itemToObjMapper)
        ->Array.filterWithIndex((_, i) => {
          !previewOnly || i <= 2
        })

      let list = orderData->Array.map(Nullable.make)
      setRevenueRecoveryData(_ => list)
      setTotalCount(_ => total)
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

  let customTitleStyle = "py-0 !pt-0"
  React.useEffect(() => {
    fetchOrderDetails()->ignore
    setScreenState(_ => PageLoaderWrapper.Success)
    None
  }, [])
  let customUI =
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />

  let (widthClass, heightClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Revenue Recovery Payments" subTitle="" customTitleStyle />
        <Button
          text="View Chargebee"
          buttonType={Secondary}
          onClick={_ =>
            // TODO: billiig connector id should be removed
            RescriptReactRouter.replace(
              GlobalVars.appendDashboardPath(
                ~url=`/v2/recovery/summary/mca_JxiR6yu2EAGOvWjWxBOM?name=chargebee`,
              ),
            )}
          buttonSize={Small}
          customButtonStyle="w-fit"
        />
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Recovery"
          actualData=revenueRecoveryData
          entity={RevenueRecoveryEntity.revenueRecoveryEntity(merchantId, orgId)}
          resultsPerPage=20
          showSerialNumber=true
          totalResults={previewOnly ? revenueRecoveryData->Array.length : totalCount}
          offset
          setOffset
          currrentFetchCount={revenueRecoveryData->Array.length}
          customColumnMapper=TableAtoms.revenueRecoveryMapDefaultCols
          defaultColumns={RevenueRecoveryEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          previewOnly
          remoteSortEnabled=true
          showAutoScroll=true
          hideCustomisableColumnButton=true
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
