open ReconEngineAccountEntity
open Typography
module SummaryCard = {
  @react.component
  let make = (~title, ~value) => {
    <div className="bg-white border border-nd_gray-200 rounded-xl p-4 shadow-xs">
      <div className="flex flex-col gap-2">
        <div className={`${body.md.medium} text-nd_gray-500`}> {title->React.string} </div>
        <div className={`${heading.md.semibold} text-nd_gray-900`}> {value->React.string} </div>
      </div>
    </div>
  }
}

module ProcessedEntriesTable = {
  @react.component
  let make = (~accountId) => {
    open ReconEngineOverviewUtils
    open LogicUtils
    open APIUtils
    let (offset, setOffset) = React.useState(_ => 0)
    let (filterDataJson, _setFilterDataJson) = React.useState(_ => None)
    let (processedEntriesData, setProcessedEntriesData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (dimensions, _setDimensions) = React.useState(_ => [])
    let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)
    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="recon_processed_date_dropdown_triggered")
    }
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let getProcessedEntriesData = async _ => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~id=Some(accountId),
          ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST_WITH_ACCOUNT,
        )
        let res = await fetchDetails(url)
        let processedEntriesData = res->getArrayDataFromJson(processedItemToObjMapper)
        setProcessedEntriesData(_ => processedEntriesData)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let topFilterUi = {
      let (initialFilters, popupFilterFields, key) = switch filterDataJson {
      | Some(filterData) => (
          HSAnalyticsUtils.initialFilterFields(filterData, ~isTitle=true),
          HSAnalyticsUtils.options(filterData),
          "0",
        )
      | None => ([], [], "1")
      }

      <div className="flex flex-row">
        <DynamicFilter
          title="AuthenticationAnalyticsV2"
          initialFilters
          options=[]
          popupFilterFields
          initialFixedFilters={initialFixedFilterFields(
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames
          key
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
    }

    React.useEffect(() => {
      getProcessedEntriesData()->ignore
      None
    }, [])

    let tableData = processedEntriesData->Array.map(Nullable.make)
    <PageLoaderWrapper screenState>
      <div
        className="-ml-1 sticky top-0 z-10 p-1 bg-hyperswitch_background/70 py-1 rounded-lg my-2">
        {topFilterUi}
      </div>
      <LoadedTable
        title="Processed Entries"
        hideTitle=true
        actualData=tableData
        entity=processedTableEntity
        resultsPerPage=10
        totalResults={tableData->Array.length}
        offset
        setOffset
        currrentFetchCount={tableData->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        showAutoScroll=true
      />
    </PageLoaderWrapper>
  }
}

module ProcessingEntriesTable = {
  @react.component
  let make = (~accountId) => {
    open ReconEngineOverviewUtils
    open LogicUtils
    open APIUtils
    let (offset, setOffset) = React.useState(_ => 0)
    let (processingEntriesData, setProcessingEntriesData) = React.useState(_ => [])
    let (filterDataJson, _setFilterDataJson) = React.useState(_ => None)
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (dimensions, _setDimensions) = React.useState(_ => [])
    let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)
    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="recon_processing_date_dropdown_triggered")
    }
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let getProcessingEntriesData = async _ => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
          ~methodType=Get,
          ~queryParamerters=Some(`account_id=${accountId}&status=needs_manual_review`),
        )
        let res = await fetchDetails(url)
        let processingEntriesList = res->getArrayDataFromJson(processingItemToObjMapper)
        setProcessingEntriesData(_ => processingEntriesList)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    React.useEffect(() => {
      getProcessingEntriesData()->ignore
      None
    }, [])

    let topFilterUi = {
      let (initialFilters, popupFilterFields, key) = switch filterDataJson {
      | Some(filterData) => (
          HSAnalyticsUtils.initialFilterFields(filterData, ~isTitle=true),
          HSAnalyticsUtils.options(filterData),
          "0",
        )
      | None => ([], [], "1")
      }

      <div className="flex flex-row">
        <DynamicFilter
          title="AuthenticationAnalyticsV2"
          initialFilters
          options=[]
          popupFilterFields
          initialFixedFilters={initialFixedFilterFields(
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames
          key
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
    }

    let tableData = processingEntriesData->Array.map(Nullable.make)
    <PageLoaderWrapper screenState>
      <div
        className="-ml-1 sticky top-0 z-10 p-1 bg-hyperswitch_background/70 py-1 rounded-lg my-2">
        {topFilterUi}
      </div>
      <LoadedTable
        title="Processing Entries"
        hideTitle=true
        actualData=tableData
        entity=processingTableEntity
        resultsPerPage=10
        totalResults={tableData->Array.length}
        offset
        setOffset
        currrentFetchCount={tableData->Array.length}
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        showAutoScroll=true
      />
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~id) => {
  open LogicUtils
  open APIUtils
  open ReconEngineOverviewUtils

  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => Dict.make()->accountItemToObjMapper)

  let getAccountData = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~methodType=Get,
        ~id=Some(id),
      )
      let res = await fetchDetails(url)
      let accountData = res->getDictFromJsonObject->accountItemToObjMapper
      setAccountData(_ => accountData)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getAccountData()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Processed Entries",
        renderContent: () => <ProcessedEntriesTable accountId=id />,
      },
      {
        title: "Processing Entries",
        renderContent: () => <ProcessingEntriesTable accountId=id />,
      },
    ]
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-8 p-6">
      <BreadCrumbNavigation
        path=[
          {
            title: "Overview",
            link: `/v1/recon-engine/overview/`,
          },
        ]
        currentPageTitle="Accounts"
        cursorStyle="cursor-pointer"
      />
      <div className="flex flex-col gap-6">
        <div className="flex items-center justify-between">
          <div>
            <PageUtils.PageHeading title=accountData.account_name />
            <p className={`${body.lg.medium} text-nd_gray-400`}>
              {"Track posted and pending balances along with any variances for each source account."->React.string}
            </p>
          </div>
          <div className="flex gap-4">
            <Button text="Upload File" buttonType={Secondary} />
            <Button text="Generate Report" buttonType={Primary} />
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <SummaryCard
            title="Pending Balance"
            value={getAmountString(accountData.pending_balance, accountData.currency)}
          />
          <SummaryCard
            title="Posted Balance"
            value={getAmountString(accountData.posted_balance, accountData.currency)}
          />
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <Tabs
          initialIndex={tabIndex >= 0 ? tabIndex : 0}
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center px-6 ${body.md.semibold}`}
          onTitleClick={index => {
            setTabIndex(_ => index)
          }}
          selectTabBottomBorderColor="bg-primary"
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
