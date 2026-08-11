@react.component
let make = (~previewOnly=false) => {
  open HSwitchRemoteFilter
  open OrderUIUtils
  open LogicUtils
  open OrderTypes
  open SavedViewTypes
  open OrderEntity
  open Typography

  let ordersTableTitle = "Orders"
  let advancedOrdersTableTitle = "OrdersAdvanced"

  let fetchNormalOrdersHook = OrdersHook.useFetchOrdersHook()
  let fetchAnalyticsOrdersHook = AnalyticsOrdersHook.useFetchAnalyticsOrdersHook()
  let getSignal = AbortControllerHook.useAbortController()
  let showToast = ToastAdapter.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {
    devOpensearch,
    devAdvancedPaymentsView,
    devSavedViews,
    transactionView,
    generateReport,
    email,
    devSortEnabled,
  } =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {getCommonSessionDetails, getResolvedUserInfo, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {transactionEntity} = getResolvedUserInfo()
  let {merchantId, orgId, version} = getCommonSessionDetails()

  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()

  //enablement of open search
  let isOpenSearchEnabled =
    devOpensearch && version == V1 && userHasResourceAccess(~resourceAccess=Analytics) === Access
  //enablement of advanced view
  let isAdvancedViewEnabled = isOpenSearchEnabled && devAdvancedPaymentsView

  let (selectedSource, setSelectedSource) = React.useState(_ => None)
  let source =
    selectedSource->mapOptionOrDefault(isAdvancedViewEnabled ? Advanced : Normal, userSource =>
      userSource
    )
  let isAdvancedView = source === Advanced && isAdvancedViewEnabled
  let (tableTitle, savedViewsEntity) = isAdvancedView
    ? (advancedOrdersTableTitle, PaymentAdvanced)
    : (ordersTableTitle, Payment)
  let ompViewPortalName = `${tableTitle}OMPView`
  let portalNodes = PortalState.portalNodes->Recoil.useRecoilValueFromAtom
  let hasOmpViewPortal = portalNodes->getOptionValFromDict(ompViewPortalName)->Option.isSome

  let fetchOrdersWithSource = (~payload, ~version, ~signal) => {
    isOpenSearchEnabled
      ? fetchAnalyticsOrdersHook(~payload, ~version, ~signal)
      : fetchNormalOrdersHook(~payload, ~version, ~signal)
  }

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let (transactionViewStatuses, setTransactionViewStatuses) = React.useState(_ => [])
  let (sortAtomValue, setSortAtom) = Recoil.useRecoilState(LoadedTable.sortAtom)
  let (widthClass, heightClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let defaultSort: LoadedTable.sortOb = {
    sortKey: "",
    sortType: ASC,
  }
  let (pageDetailDict, setPageDetails) = Recoil.useRecoilState(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->getValueFromDict(tableTitle, defaultValue)
  let resultsPerPage = pageDetail.resultsPerPage
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {filterValueJson, updateExistingKeys, reset, setfilterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let startTime = filterValueJson->getString(startTimeFilterKey(version), "")
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

    updateExistingKeys(Dict.fromArray([(startTimeFilterKey(version), {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([(endTimeFilterKey(version), {prevStartDate})]))
  }

  let getOrdersList = async filterValueJson => {
    let signal = getSignal()
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let res = await fetchOrdersWithSource(
        ~payload=filterValueJson->JSON.Encode.object,
        ~version,
        ~signal,
      )
      let data = res.data
      let total = res.total_count

      if data->isEmptyArray && filterValueJson->getOptionValFromDict("payment_id")->Option.isSome {
        let paymentId = filterValueJson->getString("payment_id", "")

        if RegExp.test(%re(`/^[A-Za-z0-9]+_[A-Za-z0-9]+_[0-9]+/`), paymentId) {
          let newPaymentId = paymentId->String.replaceRegExp(%re("/_[0-9]$/g"), "")
          filterValueJson->Dict.set("payment_id", newPaymentId->JSON.Encode.string)

          let res = await fetchOrdersWithSource(
            ~payload=filterValueJson->JSON.Encode.object,
            ~version,
            ~signal,
          )
          let data = res.data
          let total = res.total_count

          setData(
            offset,
            setOffset,
            total,
            data,
            setTotalCount,
            setOrdersData,
            setScreenState,
            previewOnly,
          )
        } else {
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
      } else {
        setData(
          offset,
          setOffset,
          total,
          data,
          setTotalCount,
          setOrdersData,
          setScreenState,
          previewOnly,
        )
      }
    } catch {
    | AbortControllerHook.AbortError => ()
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  let fetchOrders = () => {
    if !previewOnly {
      switch filters {
      | Some(dict) =>
        let filterParams = Dict.make()

        filterParams->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        filterParams->Dict.set("limit", resultsPerPage->Int.toFloat->JSON.Encode.float)
        let trimmedSearchText = searchText->String.trim
        if trimmedSearchText->isNonEmptyString && !isOpenSearchEnabled {
          filterParams->Dict.set("payment_id", trimmedSearchText->JSON.Encode.string)
        }

        let sortObj = sortAtomValue->getValueFromDict(tableTitle, defaultSort)
        if sortObj.sortKey->isNonEmptyString {
          filterParams->Dict.set(
            "order",
            [
              ("on", sortObj.sortKey->JSON.Encode.string),
              ("by", sortObj->getSortString->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          )
        }
        //to create amount_filter query
        let newDict = AmountFilterUtils.createAmountQuery(~dict)
        newDict
        ->Dict.toArray
        ->Array.forEach(item => {
          let (key, value) = item
          filterParams->Dict.set(key, value)
        })
        //to delete unused keys
        filterParams->deleteNestedKeys(["start_amount", "end_amount", "amount_option"])
        if !isOpenSearchEnabled {
          advancedPaymentFilterCleanupKeys->Array.forEach(key => filterParams->Dict.delete(key))
        }

        let requestPayload = isOpenSearchEnabled
          ? buildAdvancedPaymentListPayload(
              ~filterParams,
              ~searchText,
              ~startTimeKey=startTimeFilterKey(version),
              ~endTimeKey=endTimeFilterKey(version),
            )
          : filterParams

        requestPayload
        ->getOrdersList
        ->ignore

      | _ => ()
      }
    } else {
      let filterParams = Dict.make()

      filterParams
      ->getOrdersList
      ->ignore
    }
  }

  React.useEffect(() => {
    setSelectedRows(_ => [])
    if filters->isNonEmptyValue {
      fetchOrders()
    }
    None
  }, (offset, filters, searchText, resultsPerPage))

  let handleSourceChange = newSource => {
    setSelectedSource(_ => Some(newSource))
    setOffset(_ => 0)
    setFilters(_ => None)
    reset()
    setfilterKeys(_ => [])
  }

  React.useEffect(() => {
    if isAdvancedView {
      mixpanelEvent(~eventName="advanced_payment_list_viewed")
    }
    None
  }, [isAdvancedView])

  React.useEffect(() => {
    setSortAtom(_ =>
      [(ordersTableTitle, defaultSort), (advancedOrdersTableTitle, defaultSort)]->Dict.fromArray
    )
    None
  }, [])

  let customTitleStyle = previewOnly ? "py-0 !pt-0" : ""

  let customUI =
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />
  let hasSearchText = searchText->isNonEmptyString
  let filtersUI = React.useMemo(() => {
    let searchPlaceholder = isAdvancedView
      ? "Search ID, email, card last 4..."
      : "Search by payment ID"
    let searchBar =
      <SearchBarFilter
        placeholder=searchPlaceholder setSearchVal=setSearchTextAndResetOffset searchVal=searchText
      />
    let searchBarWithInfo =
      <div className="flex items-center gap-2">
        {searchBar}
        <RenderIf condition={isAdvancedView}>
          <ToolTip
            description=advancedPaymentSearchDescription
            toolTipFor={<span className="inline-flex h-10 items-center text-nd_gray-500">
              <Icon name="nd-info-circle" size=16 />
            </span>}
            toolTipPosition=Top
          />
        </RenderIf>
      </div>

    let savedViewsAction =
      <RenderIf condition={devSavedViews}>
        <SavedViewsComponent version entity=savedViewsEntity />
      </RenderIf>

    <RemoteTableFilters
      title=tableTitle
      setFilters
      endTimeFilterKey={endTimeFilterKey(version)}
      startTimeFilterKey={startTimeFilterKey(version)}
      initialFilters={(json, filterValues, removeKeys, filterKeys, setfilterKeys, version) =>
        initialFiltersWithSource(
          ~isAdvancedView,
          json,
          filterValues,
          removeKeys,
          filterKeys,
          setfilterKeys,
          version,
        )}
      initialFixedFilter={version => initialFixedFilter(version, ~disable=hasSearchText)}
      setOffset
      submitInputOnEnter=true
      customLeftView={<div className="flex flex-col gap-1"> {searchBarWithInfo} </div>}
      customFilterActions=savedViewsAction
      setRemoteFilterData={filterData =>
        setTransactionViewStatuses(_ =>
          filterData
          ->getDictFromJsonObject
          ->getArrayFromDict("status", [])
          ->getStrArrayFromJsonArray
        )}
      entityName={switch version {
      | V1 => V1(ORDER_FILTERS)
      | V2 => V2(V2_ORDER_FILTERS)
      }}
      version
    />
  }, (searchText, version, isAdvancedView, devSavedViews))

  let selectedPaymentRows =
    selectedRows->Array.filter(row =>
      row->getDictFromJsonObject->getString("payment_id", "")->isNonEmptyString
    )

  let downloadData = () => {
    let currentDate = Date.make()->Date.toISOString->dateFormat("YYYY-MM-DD")
    DownloadUtils.downloadTableAsCsv(
      ~csvHeaders,
      ~rawData=selectedPaymentRows,
      ~tableItemToObjMapper=dict => dict,
      ~itemToCSVMapping=mapOrderDictToCsvRow,
      ~fileName=`payments_${currentDate}.csv`,
      ~toast=(~message, ~toastType) => showToast(~message, ~toastType),
    )
  }

  let hasSelectedRows = selectedPaymentRows->isNonEmptyArray
  let canExportSelectedRows = isAdvancedView && hasSelectedRows
  let exportButtonState: Button.buttonState = canExportSelectedRows ? Normal : Disabled
  let exportTooltipText = !isAdvancedView
    ? "CSV export is available in Advanced after selecting payments."
    : hasSelectedRows
    ? "Export selected payments as CSV."
    : "Select one or more payments to export CSV."
  let selectedRowsCountClass = Button.useGetTextColor(
    ~buttonType=Primary,
    ~buttonState=exportButtonState,
    ~showBorder=false,
  )

  let tableEntity = isAdvancedView
    ? openSearchOrderEntity(merchantId, orgId, ~devSortEnabled)
    : orderEntity(merchantId, orgId, ~version, ~devSortEnabled)
  let customColumnMapper = isAdvancedView
    ? TableAtoms.ordersAdvancedMapDefaultCols
    : TableAtoms.ordersMapDefaultCols
  let defaultColumns = isAdvancedView ? openSearchDefaultColumns : defaultColumns
  let checkBoxProps = isAdvancedView
    ? Some({
        LoadedTable.showCheckBox: true,
        selectedData: selectedRows,
        setSelectedData: setSelectedRows,
      })
    : None
  let showGenerateReportAction = generateReport && email && version == V1
  let disableGenerateReport = orderData->isEmptyArray

  <ErrorBoundary>
    <div
      className={`flex flex-col gap-4 md:gap-6 mx-auto h-full ${widthClass} ${heightClass} min-h-50-vh`}>
      <div className="flex flex-wrap justify-between gap-3 items-start">
        <PageUtils.PageHeading title="Payment Operations" subTitle="" customTitleStyle />
        <div
          className="flex flex-nowrap justify-end gap-2 items-center whitespace-nowrap overflow-x-auto no-scrollbar">
          <RenderIf condition={isAdvancedViewEnabled}>
            {<>
              <div className="shrink-0">
                <OrderListSourceControls.SourceTabs
                  source setSource=handleSourceChange advancedEnabled=isAdvancedViewEnabled
                />
              </div>
              <ToolTip
                description=exportTooltipText
                toolTipFor={<Button
                  text="Export"
                  buttonType=Primary
                  buttonState=exportButtonState
                  buttonSize=Small
                  showBorder=false
                  customButtonStyle="justify-start !w-28"
                  customIconMargin="ml-2"
                  customTextPaddingClass="!pl-2 !pr-0"
                  leftIcon={CustomIcon(<Icon name="nd-download-bar-down" size=16 />)}
                  rightIcon={CustomIcon(
                    <span
                      className={`inline-flex h-5 w-5 items-center justify-center rounded-full bg-white bg-opacity-20 ${body.md.medium} ${selectedRowsCountClass}`}>
                      {selectedPaymentRows->Array.length->Int.toString->React.string}
                    </span>,
                  )}
                  onClick={_ => canExportSelectedRows ? downloadData() : ()}
                />}
                toolTipPosition=Top
              />
            </>}
          </RenderIf>
          <RenderIf condition=showGenerateReportAction>
            <div className="shrink-0">
              <GenerateReport entityName={V1(PAYMENT_REPORT)} disableReport=disableGenerateReport />
            </div>
          </RenderIf>
        </div>
      </div>
      <RenderIf condition={transactionView}>
        <TransactionView
          entity=TransactionViewTypes.Orders
          version
          isAdvancedView
          allStatuses=transactionViewStatuses
        />
      </RenderIf>
      <div className="flex">
        <RenderIf condition={!previewOnly}>
          <div className="flex-1"> {filtersUI} </div>
        </RenderIf>
      </div>
      <RenderIf condition={hasOmpViewPortal}>
        <Portal to=ompViewPortalName>
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
          actualData=orderData
          entity=tableEntity
          resultsPerPage
          showSerialNumber=true
          totalResults={previewOnly ? orderData->Array.length : totalCount}
          offset
          setOffset
          currentFetchCount={orderData->Array.length}
          customColumnMapper
          defaultColumns
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          previewOnly
          remoteSortEnabled=true
          showAutoScroll=true
          isDraggable=true
          isNewColumn=isOpenSearchNewColumn
          getNewColumnDescription=getOpenSearchNewColumnDescription
          ?checkBoxProps
          visitedRows={{
            getId: (order: PaymentInterfaceTypes.order) => order.payment_id,
            prefix_key: "orders",
          }}
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
