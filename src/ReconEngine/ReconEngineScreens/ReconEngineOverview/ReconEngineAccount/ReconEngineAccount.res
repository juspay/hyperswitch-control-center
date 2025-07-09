open ReconEngineAccountEntity
open Typography
module SummaryCard = {
  @react.component
  let make = (~title, ~value) => {
    <div className="bg-white border border-nd_gray-200 rounded-xl p-4 shadow-xs">
      <div className="flex flex-col gap-2">
        <div className={`${body.md.medium} text-gray-500`}> {title->React.string} </div>
        <div className={`${heading.md.semibold} text-gray-900`}> {value->React.string} </div>
      </div>
    </div>
  }
}

module ProcessedEntriesTable = {
  @react.component
  let make = () => {
    open ReconEngineOverviewUtils
    let (offset, setOffset) = React.useState(_ => 0)
    let (filterDataJson, _setFilterDataJson) = React.useState(_ => None)
    let (processedData, setProcessedData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (dimensions, _setDimensions) = React.useState(_ => [])
    let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)
    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="recon_processed_date_dropdown_triggered")
    }
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
    let getProcessedEntriesData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let response = Processed.processed->JSON.Decode.array->Option.getOr([])
        setProcessedData(_ => response)

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
    let tableData =
      processedData
      ->Array.map(item => item->LogicUtils.getDictFromJsonObject->processedItemToObjMapper)
      ->Array.map(Nullable.make)
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

module AccountGraph = {
  @react.component
  let make = () => {
    let accountBalanceOptions: ColumnGraphTypes.columnGraphPayload = {
      title: {
        text: "",
      },
      data: [
        {
          showInLegend: false,
          name: "Account Balance",
          colorByPoint: true,
          data: [
            {
              name: "1 Day",
              y: 13711.0,
              color: "#8BC2F3",
            },
            {
              name: "2 Day",
              y: 44579.0,
              color: "#8BC2F3",
            },
            {
              name: "3 Day",
              y: 40510.0,
              color: "#8BC2F3",
            },
            {
              name: "4 Day",
              y: 48035.0,
              color: "#8BC2F3",
            },
            {
              name: "5 Day",
              y: 51640.0,
              color: "#8BC2F3",
            },
            {
              name: "6 Day",
              y: 51483.0,
              color: "#8BC2F3",
            },
            {
              name: "7 Day",
              y: 50049.0,
              color: "#8BC2F3",
            },
          ],
          color: "",
        },
      ],
      tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
        ~title="Account Balance",
        ~metricType=FormattedAmount,
      ),
      yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
        ~statType=FormattedAmount,
        ~currency="$",
      ),
    }

    <div className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 py-6">
      <p className="text-nd_gray-600 text-sm leading-5 font-medium my-4">
        {"Account Balance"->React.string}
      </p>
      <div className="w-full">
        <ColumnGraph options={ColumnGraphUtils.getColumnGraphOptions(accountBalanceOptions)} />
      </div>
    </div>
  }
}

module ProcessingEntriesTable = {
  @react.component
  let make = () => {
    open ReconEngineOverviewUtils

    let (offset, setOffset) = React.useState(_ => 0)
    let (processingData, setProcessingData) = React.useState(_ => [])
    let (filterDataJson, _setFilterDataJson) = React.useState(_ => None)
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (dimensions, _setDimensions) = React.useState(_ => [])
    let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)
    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="recon_processing_date_dropdown_triggered")
    }
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)

    let getProcessingEntriesData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let response = Processing.processing->JSON.Decode.array->Option.getOr([])
        setProcessingData(_ => response)

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

    let tableData =
      processingData
      ->Array.map(item => item->LogicUtils.getDictFromJsonObject->processingItemToObjMapper)
      ->Array.map(Nullable.make)
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
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let accountData = Account.account->JSON.Decode.array->Option.getOr([])
  let currentAccount =
    accountData
    ->Array.find(account => {
      let accountDict = account->getDictFromJsonObject
      accountDict->getString("account_id", "") === id
    })
    ->Option.map(account => account->getDictFromJsonObject->accountItemToObjMapper)

  let accountName = currentAccount->Option.mapOr("Unknown Account", account => account.account_name)
  let pendingBalance = currentAccount->Option.mapOr("$0", account => account.pending_balance)
  let postedBalance = currentAccount->Option.mapOr("$0", account => account.posted_balance)

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Processed Entries",
        renderContent: () => <ProcessedEntriesTable />,
      },
      {
        title: "Processing Entries",
        renderContent: () => <ProcessingEntriesTable />,
      },
    ]
  }, [])

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
          <PageUtils.PageHeading title=accountName />
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
        <SummaryCard title="Pending Balance" value=pendingBalance />
        <SummaryCard title="Posted Balance" value=postedBalance />
      </div>
      <AccountGraph />
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
}
