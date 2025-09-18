@react.component
let make = () => {
  open APIUtils
  open HSwitchRemoteFilter
  open LogicUtils
  open RefundUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (refundData, setRefundsData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Refunds")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {transactionEntity, merchantId, orgId}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTime = filterValueJson->getString("start_time", "")

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartdate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([("start_time", {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([("end_time", {prevStartdate})]))
  }

  let customUI = {
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />
  }
  let fetchRefunds = () => {
    switch filters {
    | Some(dict) =>
      let filters = Dict.make()

      filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
      filters->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
      if !(searchText->isEmptyString) {
        filters->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
        filters->Dict.set("refund_id", searchText->String.trim->JSON.Encode.string)
      }
      //to create amount_filter query
      let newdict = AmountFilterUtils.createAmountQuery(~dict)
      newdict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        filters->Dict.set(key, value)
      })
      //to delete unused keys
      filters->deleteNestedKeys(["start_amount", "end_amount", "amount_option"])
      filters
      ->getRefundsList(
        ~updateDetails,
        ~setRefundsData,
        ~setScreenState,
        ~offset,
        ~setOffset,
        ~setTotalCount,
        ~getURL,
      )
      ->ignore
    | _ => ()
    }
  }

  React.useEffect(() => {
    if filters->OrderUIUtils.isNonEmptyValue {
      fetchRefunds()
    }
    None
  }, (offset, filters, searchText))

  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <ErrorBoundary>
    <div className="min-h-[50vh]">
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Refunds" />
        <div className="flex gap-4">
          <Portal to="RefundsOMPView">
            <OMPSwitchHelper.OMPViews
              views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
              selectedEntity={transactionEntity}
              onChange={updateTransactionEntity}
              entityMapper=UserInfoUtils.transactionEntityMapper
            />
          </Portal>
          <RenderIf condition={generateReport && refundData->Array.length > 0}>
            <GenerateReport entityName={V1(REFUND_REPORT)} />
          </RenderIf>
        </div>
      </div>
      <div className="grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6 my-8">
        <TransactionView entity=TransactionViewTypes.Refunds />
      </div>
      <div className="flex justify-between gap-3">
        <div className="flex-1">
          <RemoteTableFilters
            setFilters
            endTimeFilterKey
            startTimeFilterKey
            initialFilters
            initialFixedFilter
            setOffset
            customLeftView={<SearchBarFilter
              placeholder="Search for payment ID or refund ID"
              setSearchVal=setSearchText
              searchVal=searchText
            />}
            entityName=V1(REFUND_FILTERS)
            title="Refunds"
          />
        </div>
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          hideTitle=true
          title="Refunds"
          actualData=refundData
          entity={RefundEntity.refundEntity(merchantId, orgId)}
          resultsPerPage=20
          showSerialNumber=true
          totalResults={totalCount}
          offset
          setOffset
          currrentFetchCount={refundData->Array.length}
          defaultColumns={RefundEntity.defaultColumns}
          customColumnMapper=TableAtoms.refundsMapDefaultCols
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          showAutoScroll=true
          isDraggable=true
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
