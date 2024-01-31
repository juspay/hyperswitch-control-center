@react.component
let make = (~previewOnly=false) => {
  open APIUtils
  open HSwitchRemoteFilter
  open OrderUIUtils
  open LogicUtils
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let (paymentModal, setPaymentModal) = React.useState(_ => false)
  let connectorList =
    HyperswitchAtom.connectorListAtom
    ->Recoil.useRecoilValueFromAtom
    ->safeParse
    ->getObjectArrayFromJson
  let isConfigureConnector = connectorList->Array.length > 0

  let (widthClass, heightClass) = React.useMemo1(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])

  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let fetchOrders = () => {
    if !previewOnly {
      switch filters {
      | Some(dict) =>
        let filters = Dict.make()

        filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        if !(searchText->isEmptyString) {
          filters->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
        }

        dict
        ->Dict.toArray
        ->Array.forEach(item => {
          let (key, value) = item
          filters->Dict.set(key, value)
        })

        filters
        ->getOrdersList(
          ~updateDetails,
          ~setOrdersData,
          ~previewOnly,
          ~setScreenState,
          ~setOffset,
          ~setTotalCount,
          ~offset,
        )
        ->ignore

      | _ => ()
      }
    } else {
      let filters = Dict.make()

      filters
      ->getOrdersList(
        ~updateDetails,
        ~setOrdersData,
        ~previewOnly,
        ~setScreenState,
        ~setOffset,
        ~setTotalCount,
        ~offset,
      )
      ->ignore
    }
  }

  React.useEffect3(() => {
    fetchOrders()
    None
  }, (offset, filters, searchText))

  let customTitleStyle = previewOnly ? "py-0 !pt-0" : ""

  let customUI = <NoData isConfigureConnector paymentModal setPaymentModal />

  let filtersUI = React.useMemo0(() => {
    <RemoteTableFilters
      placeholder="Search payment id"
      setSearchVal=setSearchText
      searchVal=searchText
      filterUrl
      setFilters
      endTimeFilterKey
      startTimeFilterKey
      initialFilters
      initialFixedFilter
      setOffset
    />
  })

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <PageUtils.PageHeading
        title="Payment Operations" subTitle="View and manage all payments" customTitleStyle
      />
      <div className="flex">
        <UIUtils.RenderIf condition={!previewOnly}>
          <div className="flex-1"> {filtersUI} </div>
        </UIUtils.RenderIf>
        <div className="flex justify-end gap-3">
          <GenerateSampleDataButton previewOnly getOrdersList={fetchOrders} />
          <UIUtils.RenderIf condition={generateReport}>
            <GenerateReport entityName={PAYMENT_REPORT} />
          </UIUtils.RenderIf>
          <PortalCapture key={`OrdersCustomizeColumn`} name={`OrdersCustomizeColumn`} />
        </div>
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Orders"
          actualData=orderData
          entity={OrderEntity.orderEntity}
          resultsPerPage=10
          showSerialNumber=true
          totalResults={previewOnly ? orderData->Array.length : totalCount}
          offset
          setOffset
          currrentFetchCount={orderData->Array.length}
          customColumnMapper=OrderEntity.ordersMapDefaultCols
          defaultColumns={OrderEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          previewOnly
          showResultsPerPageSelector=false
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
