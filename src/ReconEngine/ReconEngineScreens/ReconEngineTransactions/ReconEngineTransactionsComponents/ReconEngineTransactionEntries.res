module AccountEntriesSection = {
  @react.component
  let make = (
    ~primaryTransactionId: string,
    ~accountId: string,
    ~accountsData: array<ReconEngineTypes.accountType>,
    ~transformationNameMap: Dict.t<string>,
  ) => {
    open LogicUtils
    open EntriesTableEntity
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper
    open ReconEngineTransactionsUtils

    let getEntries = ReconEngineHooks.useGetCursorPage(
      ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST,
      ~itemMapper=transactionsEntryItemToObjMapperFromDict,
    )

    let {
      items: entriesList,
      cursors,
      screenState,
      goToFirstPage,
      goToNextPage,
      goToPrevPage,
    } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=(~sortBy, ~direction) => {
      getEntries(
        ~body=buildEntriesListBody(
          ~primaryTransactionId,
          ~accountIds=[accountId],
          ~sortBy,
          ~direction,
        ),
      )
    })

    React.useEffect(() => {
      goToFirstPage()
      None
    }, [])

    let enrichedEntriesList = React.useMemo(() => {
      entriesList->Array.map(entry => {
        ...entry,
        transformation_name: entry.transformation_id->Option.flatMap(
          id => transformationNameMap->Dict.get(id),
        ),
      })
    }, (entriesList, transformationNameMap))

    let (groupedEntries, accountInfoMap) = React.useMemo(() => {
      getGroupedEntriesAndAccountMaps(
        ~accountsData,
        ~updatedEntriesList=enrichedEntriesList->addUniqueIdsToEntries,
      )
    }, (enrichedEntriesList, accountsData))

    let sectionDetails = (sectionIndex: int, rowIndex: int) => {
      getSectionRowDetails(
        ~sectionIndex,
        ~rowIndex,
        ~groupedEntries=groupedEntries->convertGroupedEntriesToEntryType,
      )
    }

    let tableSections = React.useMemo(() => {
      let sections = getEntriesSections(
        ~groupedEntries,
        ~accountInfoMap,
        ~detailsFields=transactionEntriesDetailFields,
        ~showTotalAmount=false,
      )
      let accountIds = groupedEntries->Dict.keysToArray
      sections->Array.mapWithIndex((section, index) => {
        let accountId = accountIds->getValueFromArray(index, "")
        let entriesWithUniqueId = groupedEntries->getValueFromDict(accountId, [])
        {
          ...section,
          rowData: entriesWithUniqueId->Array.map(entry => entry->Identity.genericTypeToJson),
        }
      })
    }, (groupedEntries, accountInfoMap))

    <RenderIf condition={entriesList->isNonEmptyArray}>
      <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-40 w-full rounded-xl" />}>
        <div className="flex flex-col">
          <ReconEngineCustomExpandableSelectionTable
            title=""
            heading={transactionEntriesDetailFields->Array.map(getHeading)}
            getSectionRowDetails=sectionDetails
            showScrollBar=true
            showOptions=false
            selectedRows=[]
            onRowSelect={_ => ()}
            sections=tableSections
          />
          <ReconEngineCursorPaginationButtons
            cursors
            isLoading={screenState === PageLoaderWrapper.Loading}
            hasData={entriesList->isNonEmptyArray}
            onPrev=goToPrevPage
            onNext=goToNextPage
          />
        </div>
      </PageLoaderWrapper>
    </RenderIf>
  }
}

@react.component
let make = (
  ~primaryTransactionId: string,
  ~accountIds: array<string>,
  ~accountsData: array<ReconEngineTypes.accountType>,
) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastAdapter.useShowToast()
  let (transformationNameMap, setTransformationNameMap) = React.useState(_ => Dict.make())

  let fetchTransformationConfigs = async () => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
      )
      let res = await fetchDetails(url)
      let configs = res->getArrayDataFromJson(ReconEngineUtils.transformationConfigItemToObjMapper)
      let nameMap = Dict.make()
      configs->Array.forEach(config => nameMap->Dict.set(config.transformation_id, config.name))
      setTransformationNameMap(_ => nameMap)
    } catch {
    | _ => showToast(~message="Failed to fetch transformation configs", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    fetchTransformationConfigs()->ignore
    None
  }, [])

  <div className="flex flex-col gap-4 mt-6 mb-16">
    <RenderIf condition={accountIds->isEmptyArray}>
      <NoDataFound customCssClass="my-6" message="No Data Available" renderType=Painting />
    </RenderIf>
    {accountIds
    ->Array.map(accountId =>
      <AccountEntriesSection
        key=accountId primaryTransactionId accountId accountsData transformationNameMap
      />
    )
    ->React.array}
  </div>
}
