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
            {`${(data.amount /. 100.00)->Belt.Float.toString} ${data.currency} `->React.string}
          </div>
          {getStatus(data)}
        </div>
        <FormRenderer.DesktopRow>
          <div
            className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
            {detailsFields
            ->Array.mapWithIndex((colType, i) => {
              if !(excludeColKeys->Array.includes(colType)) {
                <div className={`flex ${widthClass} items-center`} key={Belt.Int.toString(i)}>
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
  let (screenStateForRefund, setScreenStateForRefund) = React.useState(_ =>
    PageLoaderWrapper.Loading
  )
  let (_screenStateForOrder, setScreenStateForOrder) = React.useState(_ =>
    PageLoaderWrapper.Loading
  )
  let (offset, setOffset) = React.useState(_ => 0)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let refundData = RefundHook.useGetRefundData(id, setScreenStateForRefund)

  let paymentId =
    refundData->LogicUtils.getDictFromJsonObject->LogicUtils.getString("payment_id", "")

  let orderDataForPaymentId = OrderHooks.useGetOrdersData(paymentId, 0, setScreenStateForOrder)

  React.useEffect1(() => {
    let jsonArray = [orderDataForPaymentId]
    let paymentArray =
      jsonArray->Js.Json.array->LogicUtils.getArrayDataFromJson(OrderEntity.itemToObjMapper)
    setOrdersData(_ => paymentArray->Array.map(Js.Nullable.return))
    None
  }, [orderDataForPaymentId])

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
    </PageLoaderWrapper>
  </div>
}
