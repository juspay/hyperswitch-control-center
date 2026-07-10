open Typography

@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open ReconEngineDataTransformedEntriesUtils
  open ReconEngineDataTransformedEntriesTypes
  open ReconEngineHooks
  open HSAnalyticsUtils

  let getProcessingEntriesV2 = useGetProcessingEntriesV2()
  let getAccounts = useGetAccounts()
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )

  let (processingEntries, setProcessingEntries) = React.useState(_ => [])
  let (cursors, setCursors) = React.useState((_): processingEntryCursors => {
    next: None,
    prev: None,
  })
  let (accountData, setAccountData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchType, setSearchType) = React.useState(_ => SearchStagingEntryId)

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_accounts_transformed_entries_date_filter_opened")
  }

  let accountOptions =
    accountData->Array.map((
      account: ReconEngineTypes.accountType,
    ): FilterSelectBox.dropdownOption => {
      label: account.account_name,
      value: account.account_id,
    })

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder = sortDict->getMappedValueFromDict("All Transformed Entries", Desc, getSortOrder)

  let fetchAccounts = async () => {
    try {
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
    } catch {
    | _ => ()
    }
  }

  let fetchPage = async (~sortBy, ~direction, ~searchType, ~searchText) => {
    if screenState !== PageLoaderWrapper.Success {
      setScreenState(_ => PageLoaderWrapper.Loading)
    }
    try {
      let body = buildProcessingEntriesV2Body(
        ~filterValueJson,
        ~searchType,
        ~searchText,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
      )
      let page = await getProcessingEntriesV2(~body)
      setProcessingEntries(_ => page.processingEntries)
      setCursors(_ => page.cursors)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let goToFirstPage = () => {
    fetchPage(
      ~sortBy=defaultProcessingEntrySortBy,
      ~direction=#next,
      ~searchType,
      ~searchText,
    )->ignore
  }

  let goToNextPage = () => {
    cursors.next->mapOptionOrDefault((), nextCursor => {
      fetchPage(~sortBy=nextCursor, ~direction=#next, ~searchType, ~searchText)->ignore
    })
  }

  let goToPrevPage = () => {
    cursors.prev->mapOptionOrDefault((), prevCursor => {
      fetchPage(~sortBy=prevCursor, ~direction=#previous, ~searchType, ~searchText)->ignore
    })
  }

  let handleSearchSubmit = (selectedType: option<string>) => {
    let newSearchType = selectedType->mapOptionOrDefault(SearchStagingEntryId, searchTypeFromString)
    setSearchType(_ => newSearchType)
    fetchPage(
      ~sortBy=defaultProcessingEntrySortBy,
      ~direction=#next,
      ~searchType=newSearchType,
      ~searchText,
    )->ignore
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_accounts_transformed_entries",
    ~range=180,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      goToFirstPage()
    }
    None
  }, (filterValue, sortOrder))

  let topFilterUi = {
    <div className="flex flex-row -ml-1.5">
      <DynamicFilter
        title="ReconEngineDataTransformedEntriesFilters"
        initialFilters={initialDisplayFilters(~accountOptions)}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineDataTransformedEntriesFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  let onEntityClick = async (transformedEntry: ReconEngineTypes.processingEntryType) => {
    try {
      if transformedEntry.transformation_history_id->isNonEmptyString {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
          ~queryParameters=None,
          ~id=Some(transformedEntry.transformation_history_id),
        )
        let res = await fetchDetails(url)
        let transformationHistoryData =
          res->getDictFromJsonObject->getTransformedEntriesTransformationHistoryPayloadFromDict
        RescriptReactRouter.push(
          GlobalVars.appendDashboardPath(
            ~url=`/v1/recon-engine/transformed-entries/ingestion-history/${transformationHistoryData.ingestion_history_id}?transformationHistoryId=${transformedEntry.transformation_history_id}&stagingEntryId=${transformedEntry.staging_entry_id}`,
          ),
        )
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  <div className="flex flex-col gap-5 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entries"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
    </div>
    <ReconEngineDataTransformedEntriesOverviewCards selectedTransformationHistoryId=None />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-4">
        <div className="flex-shrink-0"> {topFilterUi} </div>
        <LoadedTable
          title="All Transformed Entries"
          hideTitle=true
          actualData={processingEntries->Array.map(Nullable.make)}
          entity={ReconEngineExceptionEntity.processingTableEntity}
          resultsPerPage=10
          totalResults={processingEntries->Array.length}
          offset
          setOffset
          currentFetchCount={processingEntries->Array.length}
          tableheadingClass="h-12"
          tableHeadingTextClass="!font-normal"
          nonFrozenTableParentClass="!rounded-lg"
          loadedTableParentClass="flex flex-col"
          enableEqualWidthCol=false
          onEntityClick={val => {
            onEntityClick(val)->ignore
          }}
          showAutoScroll=true
          remoteSortEnabled=true
          showPagination=false
          showResultsPerPageSelector=false
          tableDataLoading={screenState === PageLoaderWrapper.Loading}
          dataLoading={screenState === PageLoaderWrapper.Loading}
          filters={<SearchInput
            inputText=searchText
            onChange={value => setSearchText(_ => value)}
            placeholder="Search by ID"
            showTypeSelector=true
            typeSelectorOptions=searchTypeOptions
            onSubmitSearchDropdown=handleSearchSubmit
            showSearchIcon=true
            widthClass="w-max"
          />}
        />
        <RenderIf condition={processingEntries->isNonEmptyArray}>
          <div className="flex flex-row justify-end items-center gap-3">
            <Button
              text="Prev"
              buttonType=Secondary
              buttonSize=Small
              buttonState={cursors.prev->Option.isNone || screenState === PageLoaderWrapper.Loading
                ? Disabled
                : Normal}
              onClick={_ => goToPrevPage()}
            />
            <Button
              text="Next"
              buttonType=Primary
              buttonSize=Small
              buttonState={cursors.next->Option.isNone || screenState === PageLoaderWrapper.Loading
                ? Disabled
                : Normal}
              onClick={_ => goToNextPage()}
            />
          </div>
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
