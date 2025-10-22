module TotalCostIncurred = {
  @react.component
  let make = (~totalIncurredCost: FeeEstimationTypes.overviewFeeEstimate) => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")
    <div className="flex flex-col gap-2 rounded-xl border border-nd_br_gray-200 pt-3 p-4 mb-6">
      <div className="flex flex-col gap-2">
        <p className="text-sm font-medium text-nd_gray-400">
          {"Total Cost Incurred"->React.string}
        </p>
        <p className="text-2xl font-semibold text-nd_gray-800">
          {`$ ${LogicUtils.valueFormatter(totalIncurredCost.totalCost, Amount)}`->React.string}
        </p>
      </div>
      <StackedBarGraph
        options={StackedBarGraphUtils.getStackedBarGraphOptions(
          {
            categories: ["Total Orders"],
            data: [
              {
                name: "Interchanged Based Fee",
                data: [totalIncurredCost.totalInterchangeCost],
                color: "#8BC2F3",
              },
              {
                name: "Scheme Based Fee",
                data: [totalIncurredCost.totalSchemeCost],
                color: "#7CC5BF",
              },
            ],
            labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
          },
          ~yMax=Math.Int.max(totalIncurredCost.totalCost->Math.ceil->Int.fromFloat, 10),
          ~labelItemDistance={isMiniLaptopView ? 45 : 90},
        )}
      />
    </div>
  }
}

module FeeBreakdownBasedOnGeoLocation = {
  @react.component
  let make = (~feeBreakdownData: array<FeeEstimationTypes.feeBreakdownGeoLocation>) => {
    open BarGraphTypes

    let categories =
      feeBreakdownData->Array.map(item =>
        item.region->LogicUtils.getNonEmptyString->Option.getOr("Unknown")
      )

    let percentageSeries: BarGraphTypes.dataObj = {
      showInLegend: true,
      name: "Percentage",
      data: feeBreakdownData->Array.map(item => item.percentage),
      color: "#4392BC",
    }

    let tooltipFormatterJs = @this
    (this: BarGraphTypes.pointFormatter) => {
      let title = this.points->Array.get(0)->Option.map(point => point.x)->Option.getOr("")
      let seriesNames = ["Percentage"]

      let rows =
        this.points
        ->Array.mapWithIndex((point, idx) => {
          let label = seriesNames->Array.get(idx)->Option.getOr("")
          let value = point.y
          `<div style="display:flex;justify-content:space-between;gap:12px;padding:2px 0;"><div style=\"display:flex;align-items:center;gap:8px;\"><div style=\"width:10px;height:10px;background-color:${point.color};border-radius:2px;\"></div><div>${label}</div></div><div style=\"font-weight:600\">${LogicUtils.valueFormatter(
              value,
              LogicUtilsTypes.Default,
            )}</div></div>`
        })
        ->Array.joinWith("")

      `<div style=\"padding:8px 12px;min-width:200px;\"><div style=\"font-weight:700;margin-bottom:8px;\">${title}</div>${rows}</div>`
    }

    let payload: BarGraphTypes.barGraphPayload = {
      categories,
      data: [percentageSeries],
      title: {text: ""},
      tooltipFormatter: BarGraphTypes.asTooltipPointFormatter(tooltipFormatterJs),
    }

    let options = BarGraphUtils.getBarGraphOptions(payload)

    <div>
      <div className="bg-nd_gray-25 py-4 px-4 border border-nd_gray-200 rounded-t-xl">
        <p className="font-semibold text-nd_gray-600">
          {"Fee Breakdown Based on Geolocation"->React.string}
        </p>
      </div>
      <div className="border border-t-0 border-nd_gray-200 rounded-b-xl">
        <BarGraph options />
      </div>
    </div>
  }
}

module CostBreakDown = {
  @react.component
  let //   let make = (~costBreakdownCards, ~costBreakDownTableData) => {
  make = (~costBreakDownTableData) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let sendMixpanelEvent = () => {
      mixpanelEvent(~eventName="hypersense_fee_estimation_transaction_view_table")
    }
    let defaultData: FeeEstimationTypes.overViewFeesBreakdown = {
      feeName: "",
      totalCostIncurred: 0.0,
      transactionCurrency: "",
      transactionCount: 0,
      feeType: "",
      costContribution: 0.0,
      cardBrand: "",
      gmvPercentage: 0.0,
      regionValues: [],
      regionBasedBreakdown: [],
    }
    let (selectedTransaction, setSelectedTransaction) = React.useState(_ => defaultData)

    let costBreakdownCards = [
      {
        "title": "Scheme Based Fee",
        "cost": 75,
        "totalTransactions": 50,
      },
      {
        "title": "Interchange Based Fee",
        "cost": 25,
        "totalTransactions": 50,
      },
      {
        "title": "Interchange Based Fee",
        "cost": 25,
        "totalTransactions": 50,
      },
      {
        "title": "Interchange Based Fee",
        "cost": 25,
        "totalTransactions": 50,
      },
    ]

    let handleSelectedTransactionData = selectedData => {
      setSelectedTransaction(_ => selectedData)
      setShowModal(_ => true)
      Console.log2("Selected Data", selectedData)
    }

    <div>
      <div className="flex flex-col gap-2">
        <p className="text-lg font-semibold text-nd_gray-800"> {"Breakdown"->React.string} </p>
      </div>
      <div className="grid grid-cols-4 gap-6 my-6">
        {costBreakdownCards
        ->Array.mapWithIndex((card, index) => {
          <div
            className="flex flex-col rounded-xl w-full gap-4 p-4 border border-nd_br_gray-200"
            key={index->Int.toString}>
            <p className="text-sm font-medium text-nd_gray-400">
              // {card.title->React.string}
              {"Total Fees"->React.string}
            </p>
            <p className="text-xl font-semibold text-nd_gray-800">
              {"$1000"->React.string}
              // `${cost.currency}${LogicUtils.valueFormatter(card.cost, Amount)}`
            </p>
          </div>
        })
        ->React.array}
      </div>
      <LoadedTable
        title="Fee Estimate Transaction Overview"
        actualData={costBreakDownTableData->Array.map(Nullable.make)}
        totalResults={costBreakDownTableData->Array.length}
        resultsPerPage=20
        offset
        setOffset
        entity={FeeEstimationEntity.feeOverviewEstimationEntity(
          ~authorization=userHasAccess(~groupAccess=AnalyticsView),
          ~sendMixpanelEvent,
        )}
        currrentFetchCount={costBreakDownTableData->Array.length}
        onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
        collapseTableRow=false
        showAutoScroll=true
      />
      <Modal
        showModal
        modalHeading={"Transaction details"}
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-full h-full max-w-[539px] !bg-white dark:!bg-jp-gray-lightgray_background">
        <div className="p-2">
          <div className="grid grid-cols-2 gap-y-8 justify-between">
            <div className="flex flex-col gap-1">
              <p className="text-sm text-[#717784] font-medium">
                {"Total Cost Incurred"->React.string}
              </p>
              <p className="text-nd_gray-600 font-semibold">
                {selectedTransaction.totalCostIncurred->Float.toString->React.string}
              </p>
            </div>
            <div className="flex flex-col gap-1">
              <p className="text-sm text-[#717784] font-medium"> {"Processor"->React.string} </p>
              <div className="flex items-center gap-2">
                <GatewayIcon
                  gateway={selectedTransaction.cardBrand->String.toUpperCase} className="w-5 h-5"
                />
                <p className="text-nd_gray-600 font-semibold">
                  {selectedTransaction.cardBrand->LogicUtils.camelCaseToTitle->React.string}
                </p>
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <p className="text-sm text-[#717784] font-medium">
                {"Total Transactions"->React.string}
              </p>
              <p className="text-nd_gray-600 font-semibold">
                {selectedTransaction.transactionCount
                ->Int.toString
                ->LogicUtils.camelCaseToTitle
                ->React.string}
              </p>
            </div>
            <div className="flex flex-col gap-1">
              <p className="text-sm text-[#717784] font-medium"> {"Card Brand"->React.string} </p>
              <p className="text-nd_gray-600 font-semibold">
                {selectedTransaction.gmvPercentage
                ->Float.toString
                ->LogicUtils.camelCaseToTitle
                ->React.string}
              </p>
            </div>
          </div>
        </div>
      </Modal>
    </div>
  }
}

module OverviewContainer = {
  @react.component
  let make = () => {
    let defaultValue: FeeEstimationTypes.overviewFeeEstimate = {
      totalCost: 0.0,
      totalInterchangeCost: 0.0,
      totalSchemeCost: 0.0,
      noOfTxn: 0,
      totalGrossAmt: 0.0,
      feeBreakdownBasedOnGeoLocation: [{region: "", percentage: 0.0, fees: 0.0}],
      overviewBreakdown: [
        {
          feeName: "",
          totalCostIncurred: 0.0,
          transactionCurrency: "",
          transactionCount: 0,
          feeType: "",
          costContribution: 0.0,
          cardBrand: "",
          gmvPercentage: 0.0,
          regionValues: [],
          regionBasedBreakdown: [],
        },
      ],
    }
    let (overviewRawData, setOverviewRawData) = React.useState(_ => defaultValue)

    let fetchOverviewData = () => {
      let overViewData =
        FeeEstimationMockData.overViewMockData
        ->LogicUtils.getDictFromJsonObject
        ->FeeEstimationUtils.totalCostIncurredMapper

      Console.log2("overViewData", overViewData)
      setOverviewRawData(_ => overViewData)
    }

    React.useEffect(() => {
      fetchOverviewData()->ignore
      None
    }, [])

    <div>
      <TotalCostIncurred totalIncurredCost={overviewRawData} />
      <FeeBreakdownBasedOnGeoLocation
        feeBreakdownData=overviewRawData.feeBreakdownBasedOnGeoLocation
      />
      <CostBreakDown costBreakDownTableData={overviewRawData.overviewBreakdown} />
    </div>
  }
}

module AppliedFeesBreakdown = {
  open FeeEstimationEntity
  open FeeEstimationTypes
  @react.component
  let make = (~appliedFeesData: breakdownItem) => {
    let heading = feesBreakdownColumns->Array.map(getFeeBreakdownHeading)
    let rows = feesBreakdownColumns->Array.map(item => {
      appliedFeesData.estimateSchemeBreakdown->Array.map(colType =>
        getFeeBreakdownCell(colType, item)
      )
    })
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])

    let collapseClick = idx => {
      let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
      setExpandedRowIndexArray(_ => {
        let array = expandedRowIndexArray->Array.map(item => item)
        array->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])

        array
      })
    }
    let onExpandClick = idx => {
      setExpandedRowIndexArray(_ => {
        [idx]
      })
    }
    let onExpandIconClick = (isCurrentRowExpanded, rowIndex) => {
      if isCurrentRowExpanded {
        collapseClick(rowIndex)
      } else {
        onExpandClick(rowIndex)
      }
    }
    let attemptsData = appliedFeesData.estimateSchemeBreakdown->Array.toSorted((a, b) => {
      let rowValue_a = a.cost
      let rowValue_b = b.cost

      rowValue_a <= rowValue_b ? 1. : -1.
    })
    let getRowDetails = rowIndex => {
      switch attemptsData[rowIndex] {
      | Some(data) => <div> {data.feeName->React.string} </div>
      | None => React.null
      }
    }
    <div>
      <CustomExpandableTable
        title="Refunds"
        heading
        rows
        onExpandIconClick
        expandedRowIndexArray
        getRowDetails
        showSerial=true
      />
    </div>
  }
}

module TransactionViewContainer = {
  @react.component
  let make = () => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let defaultData: FeeEstimationTypes.breakdownItem = {
      paymentId: "",
      merchantId: "",
      connector: "",
      gross: 0.0,
      regionality: "",
      transactionCurrency: "",
      fundingSource: "",
      cardBrand: "",
      cardVariant: "",
      estimateInterchangeName: "",
      estimateInterchangeFixedRate: 0.0,
      estimateInterchangeVariableRate: 0.0,
      estimateInterchangeCost: 0.0,
      estimateSchemeBreakdown: [],
      estimateSchemeTotalCost: 0.0,
      totalCost: 0.0,
    }
    let (selectedTransaction, setSelectedTransaction) = React.useState(_ => defaultData)

    let (transactionData, setTransactionData) = React.useState(_ => [defaultData])

    let sendMixpanelEvent = () => {
      mixpanelEvent(~eventName="hypersense_fee_estimation_transaction_view_table")
    }

    let handleSelectedTransactionData = selectedData => {
      setSelectedTransaction(_ => selectedData)
      setShowModal(_ => true)
      Console.log2("Selected Data", selectedData)
    }

    let fetchData = () => {
      let transactionData =
        FeeEstimationMockData.mockData
        ->LogicUtils.getDictFromJsonObject
        ->FeeEstimationUtils.feeEstimationMapper
      setTransactionData(_ => transactionData.breakdown)
    }

    React.useEffect(_ => {
      fetchData()->ignore
      None
    }, [])

    <div>
      <RenderIf condition={transactionData->Array.length > 0}>
        <LoadedTable
          title="Fee Estimate Transaction Overview"
          actualData={transactionData->Array.map(Nullable.make)}
          totalResults={transactionData->Array.length}
          resultsPerPage=20
          offset
          setOffset
          entity={FeeEstimationEntity.feeEstimationEntity(
            ~authorization=userHasAccess(~groupAccess=AnalyticsView),
            ~sendMixpanelEvent,
          )}
          currrentFetchCount={transactionData->Array.length}
          onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
          collapseTableRow=false
          showAutoScroll=true
        />
        <Modal
          showModal
          modalHeading={"Transaction details"}
          setShowModal
          closeOnOutsideClick=true
          modalClass="w-full h-full max-w-[539px] !bg-white dark:!bg-jp-gray-lightgray_background">
          <div className="p-2">
            <div className="grid grid-cols-2 gap-y-8 justify-between">
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium"> {"Payment ID"->React.string} </p>
                <p className="text-nd_gray-600 font-semibold">
                  {selectedTransaction.paymentId->React.string}
                </p>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium"> {"Processor"->React.string} </p>
                <div className="flex items-center gap-2">
                  <GatewayIcon
                    gateway={selectedTransaction.connector->String.toUpperCase} className="w-5 h-5"
                  />
                  <p className="text-nd_gray-600 font-semibold">
                    {selectedTransaction.connector->LogicUtils.camelCaseToTitle->React.string}
                  </p>
                </div>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium">
                  {"Type of Card"->React.string}
                </p>
                <p className="text-nd_gray-600 font-semibold">
                  {selectedTransaction.fundingSource->LogicUtils.camelCaseToTitle->React.string}
                </p>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium"> {"Card Brand"->React.string} </p>
                <p className="text-nd_gray-600 font-semibold">
                  {selectedTransaction.cardBrand->LogicUtils.camelCaseToTitle->React.string}
                </p>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium">
                  {"Regionality"->React.string}
                </p>
                <p className="text-nd_gray-600 font-semibold">
                  {selectedTransaction.regionality->LogicUtils.camelCaseToTitle->React.string}
                </p>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium">
                  {"Card Variant"->React.string}
                </p>
                <p className="text-nd_gray-600 font-semibold">
                  {selectedTransaction.cardVariant->LogicUtils.camelCaseToTitle->React.string}
                </p>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium">
                  {"Transaction value"->React.string}
                </p>
                <p className="text-nd_gray-600 font-semibold">
                  {`${selectedTransaction.transactionCurrency} ${LogicUtils.valueFormatter(
                      selectedTransaction.gross,
                      Amount,
                    )}`->React.string}
                </p>
              </div>
              <div className="flex flex-col gap-1">
                <p className="text-sm text-[#717784] font-medium"> {"Total Cost"->React.string} </p>
                <p className="text-nd_gray-600 font-semibold">
                  {`${selectedTransaction.transactionCurrency} ${LogicUtils.valueFormatter(
                      selectedTransaction.totalCost,
                      Amount,
                    )}`->React.string}
                </p>
              </div>
            </div>
            <div className="mt-10">
              <p className="text-nd_gray-700 text-semibold"> {"Fee Applied"->React.string} </p>
              <AppliedFeesBreakdown appliedFeesData=selectedTransaction />
            </div>
          </div>
        </Modal>
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  let (activeTab, setActiveTab) = React.useState(_ => ["Overview"])
  let filteredTabVales: array<DynamicTabs.tab> = [
    {
      title: "Overview",
      value: "Overview",
      isRemovable: false,
    },
    {
      title: "Transactions View",
      value: "Transactions View",
      isRemovable: false,
    },
  ]
  let moduleName = "FeeEstimationAnalytics"
  let setActiveTab = React.useMemo(() => {
    (str: string) => {
      setActiveTab(_ => [str])
    }
  }, [setActiveTab])

  // Console.log2("setActiveTab changed", activeTab)

  let fetchData = () => {
    let overViewData =
      FeeEstimationMockData.overViewMockData
      ->LogicUtils.getDictFromJsonObject
      ->FeeEstimationUtils.totalCostIncurredMapper
    //   rawFrontendConfigs
    //   ->LogicUtils.getDictFromJsonObject
    //   ->LogicUtils.getJsonObjectFromDict("run_time_config")
    //   ->JSON.Decode.object
    //   ->Option.getOr(Dict.make())
    //   ->frontendConfigMapper
    // configEnv(frontendConfigs)->ignore
  }

  <div>
    <DynamicTabs
      tabs=filteredTabVales
      maxSelection=3
      tabId=moduleName
      setActiveTab
      tabContainerClass="analyticsTabs"
      initalTab=activeTab
      showAddMoreTabs=false
    />
    {switch activeTab[0]->Option.getOr("") {
    | "Overview" => <OverviewContainer />
    | _ => <TransactionViewContainer />
    }}
  </div>
}
