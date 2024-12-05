@react.component
let make = (~previewOnly=false) => {
  open APIUtils
  open HSwitchRemoteFilter
  open OrderUIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {transactionEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let (sortAtomValue, setSortAtom) = Recoil.useRecoilState(LoadedTable.sortAtom)
  let (widthClass, heightClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let defaultSort: LoadedTable.sortOb = {
    sortKey: "",
    sortType: ASC,
  }
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {generateReport, transactionView} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let fetchOrders = () => {
    if !previewOnly {
      switch filters {
      | Some(dict) =>
        let filters = Dict.make()

        filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        filters->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
        if !(searchText->isEmptyString) {
          filters->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
        }

        let sortObj = sortAtomValue->Dict.get("Orders")->Option.getOr(defaultSort)
        if sortObj.sortKey->isNonEmptyString {
          filters->Dict.set(
            "order",
            [
              ("on", sortObj.sortKey->JSON.Encode.string),
              ("by", sortObj->OrderTypes.getSortString->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          )
        }
        let encodeFloatOrDefault = val => (val->getFloatFromJson(0.0) *. 100.0)->JSON.Encode.float
        filters->Dict.set(
          "amount_filter",
          [
            (
              "start_amount",
              getvalFromDict(dict, "start_amount")->mapOptionOrDefault(
                JSON.Encode.null,
                encodeFloatOrDefault,
              ),
            ),
            (
              "end_amount",
              getvalFromDict(dict, "end_amount")->mapOptionOrDefault(
                JSON.Encode.null,
                encodeFloatOrDefault,
              ),
            ),
          ]->getJsonFromArrayOfJson,
        )
        dict
        ->Dict.toArray
        ->Array.forEach(item => {
          let (key, value) = item
          filters->Dict.set(key, value)
        })
        filters->OrderUIUtils.deleteNestedKeys(["start_amount", "end_amount"])

        filters
        ->getOrdersList(
          ~updateDetails,
          ~setOrdersData,
          ~previewOnly,
          ~setScreenState,
          ~setOffset,
          ~setTotalCount,
          ~offset,
          ~getURL,
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
        ~getURL,
      )
      ->ignore
    }
  }

  React.useEffect(() => {
    if filters->isNonEmptyValue {
      fetchOrders()
    }

    None
  }, (offset, filters, searchText))

  React.useEffect(() => {
    Some(() => setSortAtom(_ => [("Orders", defaultSort)]->Dict.fromArray))
  }, [])

  let customTitleStyle = previewOnly ? "py-0 !pt-0" : ""

  let customUI =
    <NoDataFound
      customCssClass={"my-6"} message="There are no payments as of now" renderType=Painting
    />

  let filtersUI = React.useMemo(() => {
    <RemoteTableFilters
      title="Orders"
      setFilters
      endTimeFilterKey
      startTimeFilterKey
      initialFilters
      initialFixedFilter
      setOffset
      submitInputOnEnter=true
      customLeftView={<SearchBarFilter
        placeholder="Search for any payment id" setSearchVal=setSearchText searchVal=searchText
      />}
      entityName=ORDER_FILTERS
    />
  }, [])

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Payment Operations" subTitle="" customTitleStyle />
        <div className="flex gap-4">
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
            selectedEntity={transactionEntity}
            onChange={updateTransactionEntity}
          />
          <RenderIf condition={generateReport && orderData->Array.length > 0}>
            <GenerateReport entityName={PAYMENT_REPORT} />
          </RenderIf>
        </div>
      </div>
      <RenderIf condition={transactionView}>
        <div className="flex gap-6 justify-around">
          <TransactionView entity=TransactionViewTypes.Orders />
        </div>
      </RenderIf>
      <div className="flex">
        <RenderIf condition={!previewOnly}>
          <div className="flex-1"> {filtersUI} </div>
        </RenderIf>
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Orders"
          actualData=orderData
          entity={OrderEntity.orderEntity}
          resultsPerPage=20
          showSerialNumber=true
          totalResults={previewOnly ? orderData->Array.length : totalCount}
          offset
          setOffset
          currrentFetchCount={orderData->Array.length}
          customColumnMapper=TableAtoms.ordersMapDefaultCols
          defaultColumns={OrderEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          previewOnly
          remoteSortEnabled=true
          showAutoScroll=true
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
