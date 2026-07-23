open Typography

@react.component
let make = (~ingestionHistoryId: string) => {
  open APIUtils
  open LogicUtils
  open ReconEngineHooks
  open ReconEngineTypes
  open ReconEngineUtils
  open ReconEnginePipelinesTypes
  open ReconEnginePipelinesUtils

  let getURL = useGetURL()
  let getIngestionHistory = useGetIngestionHistory()
  let getTransformationHistory = useGetTransformationHistory()
  let getAccounts = useGetAccounts()
  let getProcessingEntriesV2 = useGetCursorPage(
    ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST_V2,
    ~itemMapper=processingItemToObjMapper,
  )
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastAdapter.useShowToast()
  let {filterValueJson, filterValue, updateExistingKeys, filterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let txFilterKey = "transformation_history_ids"
  let stagingTableTitle = "Transformed Entries"

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (historyItem, setHistoryItem) = React.useState(_ =>
    Dict.make()->ingestionHistoryItemToObjMapper
  )
  let (accountData, setAccountData) = React.useState(_ => [])
  let (transformations, setTransformations) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let searchTypeRef = React.useRef(SearchStagingEntryId)
  let (showTransformationRunDetails, setShowTransformationRunDetails) = React.useState(_ => false)
  let (selectedTransformation, setSelectedTransformation) = React.useState(_ =>
    Dict.make()->transformationHistoryItemToObjMapper
  )

  let sortDict = Recoil.useRecoilValueFromAtom(LoadedTable.sortAtom)
  let sortOrder =
    sortDict->getMappedValueFromDict(stagingTableTitle, Desc, getStagingEntriesSortOrder)

  let {
    items: stagingEntries,
    cursors: stagingCursors,
    screenState: stagingScreenState,
    goToFirstPage: goToFirstStagingPage,
    goToNextPage: goToNextStagingPage,
    goToPrevPage: goToPrevStagingPage,
  } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
    let effectiveFilterValueJson = Dict.copy(filterValueJson)
    if filterValueJson->getStrArrayFromDict(txFilterKey, [])->isEmptyArray {
      effectiveFilterValueJson->Dict.set(
        txFilterKey,
        transformations
        ->Array.map((t: transformationHistoryType) => t.transformation_history_id)
        ->getJsonFromArrayOfString,
      )
    }
    getProcessingEntriesV2(
      ~body=buildStagingEntriesV2Body(
        ~filterValueJson=effectiveFilterValueJson,
        ~searchType=searchTypeRef.current,
        ~searchText,
        ~sortBy,
        ~direction,
        ~order=sortOrder,
      ),
    )
  }, ~persistKey="recon-engine-pipeline-details-staging-entries")

  let handleSearchSubmit = (selectedType: option<string>) => {
    searchTypeRef.current =
      selectedType->mapOptionOrDefault(SearchStagingEntryId, stagingEntrySearchTypeFromString)
    goToFirstStagingPage()
  }

  let onDownloadFile = async (~fileName: string) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#DOWNLOAD_INGESTION_HISTORY_FILE,
        ~methodType=Get,
        ~id=Some(ingestionHistoryId),
      )
      let res = await fetchApi(
        url,
        ~method_=Get,
        ~xFeatureRoute,
        ~forceCookies,
        ~sendV1DummyApiKeyHeader,
      )
      let content = await res->Fetch.Response.blob
      DownloadUtils.download(~fileName, ~content, ~fileType="application/octet-stream")
      showToast(~message="File downloaded successfully", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to download file. Please try again.", ~toastType=ToastError)
    }
  }

  let fetchPipelineDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
      let queryString = `ingestion_history_id=${ingestionHistoryId}`
      let ingestionHistoryList = await getIngestionHistory(~queryParameters=Some(queryString))
      let latest =
        ingestionHistoryList->getValueFromArray(0, Dict.make()->ingestionHistoryItemToObjMapper)
      setHistoryItem(_ => latest)
      let transformationHistoryList = await getTransformationHistory(
        ~queryParameters=Some(queryString),
      )
      setTransformations(_ => transformationHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch pipeline details"))
    }
  }

  React.useEffect(() => {
    fetchPipelineDetails()->ignore
    None
  }, [ingestionHistoryId])

  React.useEffect(() => {
    if transformations->isNonEmptyArray {
      goToFirstStagingPage()
    }
    None
  }, (filterValue, sortOrder, transformations))

  let accountName = ReconEnginePipelinesTableEntity.getAccountName(
    ~accountData,
    historyItem.account_id,
  )

  let statCards = React.useMemo(() => {
    getPipelineDetailStatCards(~transformationHistory=transformations)
  }, [transformations])

  let transformationOptions = React.useMemo(() => {
    transformations->Array.map(t => {
      FilterSelectBox.label: t.transformation_name,
      value: t.transformation_history_id,
    })
  }, [transformations])

  <PageLoaderWrapper screenState>
    <div className="w-full flex flex-col gap-6">
      <div className="flex items-center justify-between gap-4 mr-4">
        <BreadCrumbNavigation
          path=[{title: "Pipelines", link: "/v1/recon-engine/pipelines"}]
          currentPageTitle={historyItem.file_name->isNonEmptyString
            ? historyItem.file_name
            : ingestionHistoryId}
        />
        <RenderIf condition={historyItem.id->isNonEmptyString}>
          <Button
            text="Download file"
            leftIcon={CustomIcon(<Icon name="nd-download-down" size=12 />)}
            buttonType=Secondary
            buttonSize=Small
            onClick={_ => onDownloadFile(~fileName=historyItem.file_name)->ignore}
            maxButtonWidth="!w-fit"
          />
        </RenderIf>
      </div>
      <RenderIf condition={historyItem.id->isNonEmptyString}>
        <div className="flex flex-col gap-6">
          <div className="border border-nd_gray-200 rounded-xl bg-white overflow-hidden">
            <div className="p-5">
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-start gap-3 min-w-0">
                  <div
                    className="w-9 h-9 rounded-lg border border-nd_gray-200 bg-nd_gray-50 flex items-center justify-center flex-shrink-0">
                    <Icon name="nd-file" size=16 className="text-nd_gray-500" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap my-2">
                      <p className={`${heading.sm.semibold} text-nd_gray-800 truncate`}>
                        {historyItem.file_name->React.string}
                      </p>
                      <TableUtils.LabelCell
                        labelColor={switch historyItem.status {
                        | Processed => LabelGreen
                        | Failed => LabelRed
                        | Processing => LabelOrange
                        | Pending => LabelYellow
                        | Discarded | UnknownIngestionTransformationStatus => LabelGray
                        }}
                        text={(historyItem.status :> string)->capitalizeString}
                      />
                      <RenderIf condition={historyItem.version > 0}>
                        <span
                          className={`${body.xs.medium} px-2 py-0.5 rounded-full bg-nd_gray-100 text-nd_gray-500 border border-nd_gray-200`}>
                          {`v${historyItem.version->Int.toString}`->React.string}
                        </span>
                      </RenderIf>
                    </div>
                    <div
                      className={`flex items-center gap-1.5 flex-wrap ${body.sm.regular} text-nd_gray-400`}>
                      <span> {historyItem.upload_type->capitalizeString->React.string} </span>
                      <RenderIf condition={accountName->isNonEmptyString}>
                        <span> {"·"->React.string} </span>
                        <span> {accountName->React.string} </span>
                      </RenderIf>
                    </div>
                  </div>
                </div>
                <div className="flex-shrink-0">
                  <TableUtils.DateCell
                    timestamp=historyItem.created_at
                    isCard=true
                    textStyle={`${body.sm.regular} text-nd_gray-400`}
                  />
                </div>
              </div>
            </div>
            <div className="border-t border-nd_gray-150 flex divide-x divide-nd_gray-150">
              {statCards
              ->Array.mapWithIndex((card, index) =>
                <ReconEnginePipelinesHelper.StatCard
                  key={index->Int.toString}
                  label={(card.pipelineDetailStatCardLabel :> string)}
                  value=card.pipelineDetailStatCardValue
                  desc=card.pipelineDetailStatCardDesc
                  cardType=card.pipelineDetailStatCardType
                  onClick=?card.pipelineDetailStatCardOnClick
                />
              )
              ->React.array}
            </div>
          </div>
          <RenderIf condition={transformations->isNonEmptyArray}>
            <div className="flex flex-col gap-3">
              <ReconEnginePipelinesHelper.SectionTitle count={transformations->Array.length}>
                {"Transformations"->React.string}
              </ReconEnginePipelinesHelper.SectionTitle>
              <div className="flex flex-col gap-3">
                {transformations
                ->Array.map(tx =>
                  <ReconEnginePipelinesHelper.TransformationCard
                    key={tx.transformation_history_id}
                    tx
                    onOpen={() => {
                      setSelectedTransformation(_ => tx)
                      setShowTransformationRunDetails(_ => true)
                    }}
                  />
                )
                ->React.array}
              </div>
            </div>
          </RenderIf>
          <RenderIf condition={transformations->isNonEmptyArray}>
            <div className="flex flex-col gap-3">
              <p className={`${body.md.semibold} text-nd_gray-800`}>
                {"Transformed Entries"->React.string}
              </p>
              <div className="flex flex-row -ml-1.5">
                <DynamicFilter
                  title="ReconEnginePipelineDetailsStagingFilters"
                  initialFilters={initialStagingEntriesFilters(~transformationOptions)}
                  options=[]
                  popupFilterFields=[]
                  initialFixedFilters=[]
                  defaultFilterKeys=[]
                  tabNames=filterKeys
                  key="ReconEnginePipelineDetailsStagingFilters"
                  updateUrlWith=updateExistingKeys
                  filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
                  showCustomFilter=false
                  refreshFilters=false
                  setOffset
                />
              </div>
              <LoadedTable
                title=stagingTableTitle
                hideTitle=true
                actualData={stagingEntries->Array.map(Nullable.make)}
                entity=ReconEngineExceptionEntity.processingTableEntity
                resultsPerPage=10
                totalResults={stagingEntries->Array.length}
                offset
                setOffset
                currentFetchCount={stagingEntries->Array.length}
                tableheadingClass="h-11"
                tableHeadingTextClass="!font-normal"
                nonFrozenTableParentClass="!rounded-none !border-0 !shadow-none"
                loadedTableParentClass="flex flex-col"
                enableEqualWidthCol=false
                showAutoScroll=true
                remoteSortEnabled=true
                showPagination=false
                showResultsPerPageSelector=false
                tableDataLoading={stagingScreenState === PageLoaderWrapper.Loading}
                dataLoading={stagingScreenState === PageLoaderWrapper.Loading}
                filters={<SearchInput
                  inputText=searchText
                  onChange={value => setSearchText(_ => value)}
                  placeholder="Search by ID"
                  showTypeSelector=true
                  typeSelectorOptions=stagingEntrySearchTypeOptions
                  onSubmitSearchDropdown=handleSearchSubmit
                  showSearchIcon=true
                  widthClass="w-max"
                />}
                bottomActions={<ReconEngineCursorPaginationButtons
                  cursors=stagingCursors
                  isLoading={stagingScreenState === PageLoaderWrapper.Loading}
                  hasData={stagingEntries->isNonEmptyArray}
                  onPrev=goToPrevStagingPage
                  onNext=goToNextStagingPage
                />}
              />
            </div>
          </RenderIf>
        </div>
      </RenderIf>
    </div>
    <ReconEnginePipelinesTransformationRunDetails
      showModal=showTransformationRunDetails
      setShowModal=setShowTransformationRunDetails
      selectedTransformation
      accountData
    />
  </PageLoaderWrapper>
}
