open Typography

module OverviewCard = {
  @react.component
  let make = (~title, ~value) => {
    <div
      className="flex flex-col gap-4 bg-white border border-nd_gray-200 rounded-xl p-4 shadow-xs">
      <div className={`${body.md.medium} text-nd_gray-400`}> {title->React.string} </div>
      <div className={`${heading.md.semibold} text-nd_gray-800`}> {value->React.string} </div>
    </div>
  }
}

module StackedBarGraph = {
  @react.component
  let make = (~transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>) => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")

    // Process transaction data to count statuses
    let (postedCount, mismatchedCount, expectedCount) = React.useMemo(() => {
      transactionsData->Array.reduce((0, 0, 0), ((posted, mismatched, expected), transaction) => {
        switch transaction.transaction_status {
        | "posted" => (posted + 1, mismatched, expected)
        | "mismatched" => (posted, mismatched + 1, expected)
        | "expected" => (posted, mismatched, expected + 1)
        | _ => (posted, mismatched, expected)
        }
      })
    }, [transactionsData])

    let totalTransactions = postedCount + mismatchedCount + expectedCount

    // Create stacked bar graph data
    let stackedBarGraphData = React.useMemo(() => {
      open StackedBarGraphTypes
      {
        categories: ["Transactions"],
        data: [
          {
            name: "Posted",
            data: [postedCount->Int.toFloat],
            color: "#7AB891",
          },
          {
            name: "Mismatched",
            data: [mismatchedCount->Int.toFloat],
            color: "#EA8A8F",
          },
          {
            name: "Expected",
            data: [expectedCount->Int.toFloat],
            color: "#8BC2F3",
          },
        ],
        labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
      }
    }, [postedCount, mismatchedCount, expectedCount])

    <div
      className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className={`text-nd_gray-400 ${body.sm.medium}`}>
        {"Transaction Status Distribution"->React.string}
      </p>
      <p className={`text-nd_gray-800 ${heading.lg.semibold}`}>
        {totalTransactions->Int.toString->React.string}
      </p>
      <div className="w-full">
        <StackedBarGraph
          options={StackedBarGraphUtils.getStackedBarGraphOptions(
            stackedBarGraphData,
            ~yMax=totalTransactions,
            ~labelItemDistance={isMiniLaptopView ? 45 : 90},
          )}
        />
      </div>
    </div>
  }
}

module ReconRuleLineGraph = {
  @react.component
  let make = (~transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>=[], ()) => {
    // Process transaction data to create time-based trends
    let lineGraphData = React.useMemo(() => {
      // Group transactions by date and status
      let groupedByDate = transactionsData->Array.reduce(Dict.make(), (acc, transaction) => {
        let dateStr = transaction.created_at->String.slice(~start=0, ~end=10) // Extract YYYY-MM-DD
        let currentDateData = acc->Dict.get(dateStr)->Option.getOr(Dict.make())

        switch transaction.transaction_status {
        | "posted" => {
            let currentCount = currentDateData->Dict.get("posted")->Option.getOr(0)
            currentDateData->Dict.set("posted", currentCount + 1)
          }
        | "expected" => {
            let currentCount = currentDateData->Dict.get("expected")->Option.getOr(0)
            currentDateData->Dict.set("expected", currentCount + 1)
          }
        | "mismatched" => {
            let currentCount = currentDateData->Dict.get("mismatched")->Option.getOr(0)
            currentDateData->Dict.set("mismatched", currentCount + 1)
          }
        | "archived" => {
            let currentCount = currentDateData->Dict.get("archived")->Option.getOr(0)
            currentDateData->Dict.set("archived", currentCount + 1)
          }
        | _ => ()
        }

        acc->Dict.set(dateStr, currentDateData)
        acc
      })

      // Convert to sorted arrays for the line graph
      let sortedDates = groupedByDate->Dict.keysToArray->Array.toSorted(String.compare)
      let categories = sortedDates->Array.map(date => {
        // Convert YYYY-MM-DD to MMM DD format
        let parts = date->String.split("-")
        let month = switch parts->Array.get(1) {
        | Some("01") => "Jan"
        | Some("02") => "Feb"
        | Some("03") => "Mar"
        | Some("04") => "Apr"
        | Some("05") => "May"
        | Some("06") => "Jun"
        | Some("07") => "Jul"
        | Some("08") => "Aug"
        | Some("09") => "Sep"
        | Some("10") => "Oct"
        | Some("11") => "Nov"
        | Some("12") => "Dec"
        | _ => "Jan"
        }
        let day = parts->Array.get(2)->Option.getOr("01")
        `${month} ${day}`
      })

      let postedData = sortedDates->Array.map(date => {
        groupedByDate
        ->Dict.get(date)
        ->Option.getOr(Dict.make())
        ->Dict.get("posted")
        ->Option.getOr(0)
        ->Int.toFloat
      })

      let expectedData = sortedDates->Array.map(date => {
        groupedByDate
        ->Dict.get(date)
        ->Option.getOr(Dict.make())
        ->Dict.get("expected")
        ->Option.getOr(0)
        ->Int.toFloat
      })

      let lineGraphOptions: LineGraphTypes.lineGraphPayload = {
        chartHeight: LineGraphTypes.DefaultHeight,
        chartLeftSpacing: LineGraphTypes.DefaultLeftSpacing,
        categories,
        data: [
          {
            showInLegend: true,
            name: "Posted",
            data: postedData,
            color: "#7AB891",
          },
          {
            showInLegend: true,
            name: "Expected",
            data: expectedData,
            color: "#8BC2F3",
          },
        ],
        title: {
          text: "",
          align: "left",
        },
        tooltipFormatter: ReconEngineOverviewUtils.getOverviewLineGraphTooltipFormatter,
        yAxisMaxValue: None,
        yAxisMinValue: None,
        yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(~statType=Default),
        legend: {
          useHTML: true,
          labelFormatter: LineGraphUtils.valueFormatter,
          align: "left",
          verticalAlign: "top",
          floating: false,
          margin: 30,
        },
      }

      lineGraphOptions
    }, [transactionsData])

    <div className="border rounded-xl border-nd_gray-200">
      <div
        className="flex flex-col space-y-2 items-start px-4 py-2 bg-nd_gray-25 rounded-t-xl border-b border-nd_gray-200">
        <div className={`text-nd_gray-600 ${body.md.semibold} p-2 w-full`}>
          {"Reconciliation Trends"->React.string}
        </div>
      </div>
      <div className="w-full p-2">
        <LineGraph options={LineGraphUtils.getLineGraphOptions(lineGraphData)} />
      </div>
    </div>
  }
}

module ReconRuleTransactions = {
  @react.component
  let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
    open LogicUtils
    open ReconEngineTransactionsUtils
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (configuredTransactions, setConfiguredReports) = React.useState(_ => [])
    let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
    let (offset, setOffset) = React.useState(_ => 0)
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )
    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let mixpanelEvent = MixpanelHook.useSendEvent()

    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="recon_engine_overview_transactions_date_filter_opened")
    }

    let filterLogic = ReactDebounce.useDebounced(ob => {
      let (searchText, arr) = ob
      let filteredList = if searchText->isNonEmptyString {
        arr->Array.filter((obj: Nullable.t<ReconEngineTransactionsTypes.transactionPayload>) => {
          switch Nullable.toOption(obj) {
          | Some(obj) =>
            isContainingStringLowercase(obj.transaction_id, searchText) ||
            isContainingStringLowercase(obj.transaction_status, searchText)
          | None => false
          }
        })
      } else {
        arr
      }
      setFilteredReports(_ => filteredList)
    }, ~wait=200)

    let fetchTransactionsData = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let baseQueryString = ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson)
        let queryString = if baseQueryString->isNonEmptyString {
          `${baseQueryString}&rule_id=${ruleDetails.rule_id}`
        } else {
          `rule_id=${ruleDetails.rule_id}`
        }

        let transactionsUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSACTIONS_LIST,
          ~queryParamerters=Some(queryString),
        )

        let res = await fetchDetails(transactionsUrl)
        let transactionsList = res->LogicUtils.getArrayDataFromJson(getAllTransactionPayload)

        let transactionsDataList = transactionsList->Array.map(Nullable.make)
        setConfiguredReports(_ => transactionsDataList)
        setFilteredReports(_ => transactionsDataList)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~origin="recon_engine_overview_transactions",
      (),
    )

    React.useEffect(() => {
      setInitialFilters()
      None
    }, [])

    React.useEffect(() => {
      fetchTransactionsData()->ignore
      None
    }, [filterValue])

    let topFilterUi = {
      <div className="flex flex-row">
        <DynamicFilter
          title="ReconEngineOverviewTransactionsFilters"
          initialFilters={initialDisplayFilters()}
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEngineOverviewTransactionsFilters"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
    }

    <div className="flex flex-col gap-4">
      <div className="flex-shrink-0"> {topFilterUi} </div>
      <PageLoaderWrapper screenState>
        <LoadedTableWithCustomColumns
          title="All Transactions"
          actualData={filteredTransactionsData}
          entity={TransactionsTableEntity.transactionsEntity(
            `v1/recon-engine/transactions`,
            ~authorization=Access,
          )}
          resultsPerPage=10
          filters={<TableSearchFilter
            data={configuredTransactions}
            filterLogic
            placeholder="Search Transaction Id or Status"
            customSearchBarWrapperWidth="w-1/3"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          totalResults={filteredTransactionsData->Array.length}
          offset
          setOffset
          currrentFetchCount={configuredTransactions->Array.length}
          customColumnMapper=TableAtoms.reconTransactionsDefaultCols
          defaultColumns={TransactionsTableEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          customizeColumnButtonIcon="nd-filter-horizontal"
          hideRightTitleElement=true
          showAutoScroll=true
        />
      </PageLoaderWrapper>
    </div>
  }
}
