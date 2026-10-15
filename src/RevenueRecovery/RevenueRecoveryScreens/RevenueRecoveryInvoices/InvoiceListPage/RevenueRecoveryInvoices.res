@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open HSwitchRemoteFilter
  open RevenueRecoveryFilterUtils

  let getURL = useGetURL()
  let fetchDetails = useCancellableGetMethod()
  let getSignal = AbortControllerHook.useAbortController()
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {getCommonSessionDetails, getResolvedUserInfo, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {transactionEntity} = getResolvedUserInfo()
  let {merchantId, orgId, profileId} = getCommonSessionDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let (pageDetailDict, setPageDetails) = Recoil.useRecoilState(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->getValueFromDict(tableTitle, defaultValue)
  let resultsPerPage = pageDetail.resultsPerPage
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (filters, setFilters) = React.useState(_ => None)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ => [])
  let {generateReport, email} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTimeKey = OrderUIUtils.startTimeFilterKey(V2)
  let endTimeKey = OrderUIUtils.endTimeFilterKey(V2)
  let startTime = filterValueJson->getString(startTimeKey, "")
  let isProfileView = transactionEntity === #Profile

  let portalNodes = PortalState.portalNodes->Recoil.useRecoilValueFromAtom
  let hasOmpViewPortal = portalNodes->getOptionValFromDict(`${tableTitle}OMPView`)->Option.isSome

  let setSearchTextAndResetOffset = updateSearchText => {
    setPageDetails(prev => {
      let currentPageDetail = prev->getValueFromDict(tableTitle, defaultValue)
      let updatedPageDetails = prev->Dict.toArray->Dict.fromArray
      updatedPageDetails->Dict.set(tableTitle, {...currentPageDetail, offset: 0})
      updatedPageDetails
    })
    setOffset(_ => 0)
    setSearchText(updateSearchText)
  }

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartDate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([(startTimeKey, extendedStartDate)]))
    updateExistingKeys(Dict.fromArray([(endTimeKey, prevStartDate)]))
  }

  let setData = (total, data) => {
    if offset > 0 && total <= offset {
      setOffset(_ => 0)
    } else if total > 0 {
      let arr = Array.make(~length=offset, Dict.make()->RevenueRecoveryEntity.itemToObjMapper)
      let list = arr->Array.concat(data)->Array.map(Nullable.make)
      setTotalCount(_ => total)
      setRevenueRecoveryData(_ => list)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setRevenueRecoveryData(_ => [])
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let getPaymentsList = async query => {
    let signal = getSignal()
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V2(V2_RECOVERY_INVOICES_LIST),
        ~methodType=Get,
        ~queryParameters=Some(query->FilterUtils.parseFilterDictV2),
      )
      let res = await fetchDetails(url, ~version=V2, ~signal)

      let resDict = res->getDictFromJsonObject
      let data = resDict->getArrayFromDict("data", [])
      let total = resDict->getInt("total_count", 0)

      let orderData =
        data
        ->Belt.Array.keepMap(JSON.Decode.object)
        ->Array.map(RevenueRecoveryEntity.itemToObjMapper)
      setData(total, orderData)
    } catch {
    | AbortControllerHook.AbortError => ()
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    switch filters {
    | Some(dict) =>
      buildQuery(
        ~filters=dict,
        ~offset,
        ~limit=resultsPerPage,
        ~searchText,
        ~profileId,
        ~isProfileView,
      )
      ->getPaymentsList
      ->ignore
    | None => ()
    }
    None
  }, (offset, filters, searchText, resultsPerPage, transactionEntity))

  let customUI =
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />

  let filtersUI = React.useMemo(() => {
    <RemoteTableFilters
      title=tableTitle
      setFilters
      endTimeFilterKey=endTimeKey
      startTimeFilterKey=startTimeKey
      initialFilters
      initialFixedFilter={_version => initialFixedFilter(~disable=searchText->isNonEmptyString)}
      setOffset
      submitInputOnEnter=true
      customLeftView={<SearchBarFilter
        placeholder="Search by payment ID"
        setSearchVal=setSearchTextAndResetOffset
        searchVal=searchText
      />}
      entityName={V2(V2_ORDER_FILTERS)}
      version=V2
      fetchFilters=false
    />
  }, [searchText])

  <ErrorBoundary>
    <div className={`flex flex-col gap-4 mx-auto h-full w-full min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="List of Invoices" customTitleStyle="py-0 !pt-0" />
        <RenderIf condition={generateReport && email && revenueRecoveryData->Array.length > 0}>
          <GenerateReport entityName={V2(REVENUE_RECOVERY_REPORT)} />
        </RenderIf>
      </div>
      {filtersUI}
      <RenderIf condition={hasOmpViewPortal}>
        <Portal to={`${tableTitle}OMPView`}>
          <OMPSwitchHelper.OMPViews
            views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
            selectedEntity={transactionEntity}
            onChange={updateTransactionEntity}
            entityMapper=UserInfoUtils.transactionEntityMapper
          />
        </Portal>
      </RenderIf>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title=tableTitle
          actualData=revenueRecoveryData
          entity={RevenueRecoveryEntity.revenueRecoveryEntity(merchantId, orgId, profileId)}
          resultsPerPage
          showSerialNumber=true
          totalResults={totalCount}
          offset
          setOffset
          currentFetchCount={revenueRecoveryData->Array.length}
          customColumnMapper=TableAtoms.revenueRecoveryMapDefaultCols
          defaultColumns={RevenueRecoveryEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          showAutoScroll=true
          hideCustomisableColumnButton=true
          visitedRows={{
            getId: (order: RevenueRecoveryOrderTypes.order) => order.id,
            prefix_key: "recovery_invoices",
          }}
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
