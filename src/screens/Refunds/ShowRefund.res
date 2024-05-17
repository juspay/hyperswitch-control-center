open OrderUtils
open RefundEntity

module RefundInfo = {
  module Details = {
    @react.component
    let make = (
      ~data,
      ~getHeading,
      ~getCell,
      ~excludeColKeys=[],
      ~detailsFields,
      ~justifyClassName="justify-start",
      ~widthClass="w-1/4",
      ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
      ~children=?,
    ) => {
      <Section
        customCssClass={`border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 ${bgColor} rounded-md p-5`}>
        <div className="flex items-center">
          <div className="font-bold text-4xl m-3">
            {`${(data.amount /. 100.00)->Float.toString} ${data.currency} `->React.string}
          </div>
          {useGetStatus(data)}
        </div>
        <FormRenderer.DesktopRow>
          <div
            className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
            {detailsFields
            ->Array.mapWithIndex((colType, i) => {
              if !(excludeColKeys->Array.includes(colType)) {
                <div className={`flex ${widthClass} items-center`} key={Int.toString(i)}>
                  <DisplayKeyValueParams
                    heading={getHeading(colType)}
                    value={getCell(data, colType)}
                    customMoneyStyle="!font-normal !text-sm"
                    labelMargin="!py-0 mt-2"
                    overiddingHeadingStyles="text-black text-sm font-medium"
                    textColor="!font-normal !text-jp-gray-700"
                  />
                </div>
              } else {
                React.null
              }
            })
            ->React.array}
          </div>
        </FormRenderer.DesktopRow>
        {switch children {
        | Some(ele) => ele
        | None => React.null
        }}
      </Section>
    }
  }
  @react.component
  let make = (~orderDict) => {
    let refundData = itemToObjMapper(orderDict)
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details
        data=refundData
        getHeading
        getCell
        excludeColKeys=[RefundStatus, Amount]
        detailsFields=allColumns
      />
    </>
  }
}

@react.component
let make = (~id) => {
  let getURL = APIUtils.useGetURL()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (screenStateForRefund, setScreenStateForRefund) = React.useState(_ =>
    PageLoaderWrapper.Loading
  )
  let (refundData, setRefundData) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (offset, setOffset) = React.useState(_ => 0)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let fetchDetails = APIUtils.useGetMethod()
  let showToast = ToastState.useShowToast()
  let paymentId =
    refundData->LogicUtils.getDictFromJsonObject->LogicUtils.getString("payment_id", "")
  let fetchRefundData = async () => {
    try {
      let refundUrl = getURL(~entityName=REFUNDS, ~methodType=Get, ~id=Some(id), ())
      let refundData = await fetchDetails(refundUrl)
      let paymentId =
        refundData->LogicUtils.getDictFromJsonObject->LogicUtils.getString("payment_id", "")
      let orderUrl = getURL(
        ~entityName=ORDERS,
        ~methodType=Get,
        ~id=Some(paymentId),
        ~queryParamerters=Some("expand_attempts=true"),
        (),
      )
      let orderData = await fetchDetails(orderUrl)
      let paymentArray =
        [orderData]->JSON.Encode.array->LogicUtils.getArrayDataFromJson(OrderEntity.itemToObjMapper)
      setOrdersData(_ => paymentArray->Array.map(Nullable.make))
      setRefundData(_ => refundData)
      setScreenStateForRefund(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("HE_02") {
          setScreenStateForRefund(_ => Custom)
        } else {
          showToast(~message="Failed to Fetch!", ~toastType=ToastState.ToastError, ())
          setScreenStateForRefund(_ => Error("Failed to Fetch!"))
        }

      | None => setScreenStateForRefund(_ => Error("Failed to Fetch!"))
      }
    }
  }
  React.useEffect0(() => {
    fetchRefundData()->ignore
    None
  })

  <div className="flex flex-col overflow-scroll">
    <div className="mb-4 flex justify-between">
      <div className="flex items-center">
        <div>
          <PageUtils.PageHeading title="Refunds" />
          <BreadCrumbNavigation
            path=[{title: "Refunds", link: "/refunds"}]
            currentPageTitle=id
            cursorStyle="cursor-pointer"
          />
        </div>
        <div />
      </div>
    </div>
    <PageLoaderWrapper
      screenState={screenStateForRefund}
      customUI={<DefaultLandingPage
        height="90vh"
        title="Something Went Wrong!"
        overriddingStylesTitle={`text-3xl font-semibold`}
      />}>
      <RefundInfo orderDict={refundData->LogicUtils.getDictFromJsonObject} />
      <UIUtils.RenderIf condition={userPermissionJson.operationsView !== NoAccess}>
        <LoadedTable
          title="Payment"
          actualData=orderData
          entity={OrderEntity.orderEntity}
          resultsPerPage=1
          showSerialNumber=true
          totalResults=1
          offset
          setOffset
          currrentFetchCount=1
        />
      </UIUtils.RenderIf>
      <div className="mt-5" />
      <UIUtils.RenderIf condition={featureFlagDetails.auditTrail}>
        <OrderUIUtils.RenderAccordian
          accordion={[
            {
              title: "Events and logs",
              renderContent: () => {
                <LogsWrapper wrapperFor={#REFUND}>
                  <RefundLogs refundId=id paymentId />
                </LogsWrapper>
              },
              renderContentOnTop: None,
            },
          ]}
        />
      </UIUtils.RenderIf>
    </PageLoaderWrapper>
  </div>
}
