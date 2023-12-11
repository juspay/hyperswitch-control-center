@react.component
let make = (~previewOnly=false) => {
  open APIUtils
  open HSwitchRemoteFilter
  open HSwitchUtils
  open OrderUIUtils
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let (paymentModal, setPaymentModal) = React.useState(_ => false)
  let isConfigureConnector = ListHooks.useListCount(~entityName=CONNECTOR) > 0

  let (widthClass, heightClass) = React.useMemo1(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])

  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Js.Dict.get("Orders")->Belt.Option.getWithDefault(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let fetchOrders = () => {
    if !previewOnly {
      switch filters {
      | Some(dict) =>
        let filters = Js.Dict.empty()

        filters->Js.Dict.set("offset", offset->Belt.Int.toFloat->Js.Json.number)
        if !(searchText->isEmptyString) {
          filters->Js.Dict.set("payment_id", searchText->Js.Json.string)
        }

        dict
        ->Js.Dict.entries
        ->Js.Array2.forEach(item => {
          let (key, value) = item
          filters->Js.Dict.set(key, value)
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
      let filters = Js.Dict.empty()

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

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <PageUtils.PageHeading
        title="Payment Operations" subTitle="View and manage all payments" customTitleStyle
      />
      <div className="flex w-full justify-end pb-3 gap-3">
        <GenerateSampleDataButton previewOnly getOrdersList={fetchOrders} />
        <UIUtils.RenderIf condition={generateReport}>
          <GenerateReport entityName={PAYMENT_REPORT} />
        </UIUtils.RenderIf>
      </div>
      <UIUtils.RenderIf condition={!previewOnly}>
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
      </UIUtils.RenderIf>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Orders"
          actualData=orderData
          entity={OrderEntity.orderEntity}
          resultsPerPage=10
          showSerialNumber=true
          totalResults={previewOnly ? orderData->Js.Array2.length : totalCount}
          offset
          setOffset
          currrentFetchCount={orderData->Js.Array2.length}
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
