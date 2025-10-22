open FeeEstimationTypes

module SingleSelectDropDown = {
  @react.component
  let make = (
    ~options: array<string>,
    ~name,
    ~page,
    ~isButtonDisabled,
    ~onApply,
    ~filterIcon,
    ~globalFilterSelectedFilter,
    ~isLoading,
    ~alignmentCss="right-1",
  ) => {
    let (isFilterOpen, setIsFilterOpen) = React.useState(_ => false)
    let (selectedFilter, setSelectedFilter) = React.useState(_ => globalFilterSelectedFilter)

    React.useEffect(() => {
      setSelectedFilter(_ => globalFilterSelectedFilter)
      None
    }, [globalFilterSelectedFilter])

    let isMobile = MatchMedia.useMobileChecker()
    let dropdownRef = React.useRef(Nullable.null)

    let toggle = () => setIsFilterOpen(p => !p)

    OutsideClick.useOutsideClick(
      ~refs={ArrayOfRef([dropdownRef])},
      ~isActive=isFilterOpen,
      ~callback=() => {
        setSelectedFilter(_ => globalFilterSelectedFilter)
        setIsFilterOpen(_ => false)
      },
    )

    let downArrowIcon = "chevron-down"
    let arrowIconSize = 16
    let buttonIcon =
      <Icon
        name=downArrowIcon
        size=arrowIconSize
        className={`transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)] ${isFilterOpen
            ? "-rotate-180"
            : ""}`}
      />

    let handleClick = option => setSelectedFilter(_ => option)

    let getSelectedLabel = () =>
      if selectedFilter === "" {
        name
      } else {
        selectedFilter->LogicUtils.snakeToTitle
      }

    <div
      className={`relative flex justify-end ${isButtonDisabled
          ? "pointer-events-none opacity-70"
          : ""}`}
      ref={dropdownRef->ReactDOM.Ref.domRef}>
      <Button
        text={getSelectedLabel()}
        buttonType={Secondary}
        buttonState={isLoading ? Loading : Normal}
        onClick={_ => toggle()}
        customPaddingClass="p-1 px-2 md:p-2 md:px-4"
        rightIcon={CustomIcon(buttonIcon)}
        leftIcon={NoIcon}
      />
      <RenderIf condition={isFilterOpen}>
        <div
          className={`absolute z-10 top-[3rem] right-1 ${alignmentCss} w-fit border rounded-xl bg-white p-2 flex flex-col gap-2 shadow-connectorTagShadow`}>
          <div className="flex flex-col gap-4 mb-4 p-2 max-h-[210px] overflow-y-auto">
            {options
            ->Array.map(option => {
              <div
                key={option}
                className="flex gap-2 items-center cursor-pointer pr-4"
                onClick={_ => handleClick(option)}>
                <CheckBoxIcon isSelected={selectedFilter == option} />
                <p className="text-sm text-grey-light_not_selected">
                  {option->LogicUtils.snakeToTitle->React.string}
                </p>
              </div>
            })
            ->React.array}
          </div>
          <Button
            text="Apply"
            // fullLength=true
            buttonType={Primary}
            onClick={_ => {
              onApply(selectedFilter)
              setIsFilterOpen(_ => false)
            }}
            customButtonStyle="text-center"
          />
        </div>
      </RenderIf>
    </div>
  }
}
module TotalCostIncurred = {
  @react.component
  let make = (~totalIncurredCost: FeeEstimationTypes.overviewFeeEstimate) => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")
    <div className="flex flex-col gap-2 rounded-xl border border-nd_br_gray-200 pt-3 p-4 my-6">
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
  let make = (~feeBreakdownData: array<feeBreakdownGeoLocation>) => {
    let payload = FeeEstimationHelper.feeBreakdownBasedOnGeoLocationPayload(~feeBreakdownData)
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

module CostBreakDownSideModal = {
  @react.component
  let make = (~selectedTransaction: overViewFeesBreakdown, ~filterTabValues) => {
    open StackedBarGraphTypes
    let (activeTab, setActiveTab) = React.useState(_ => ["domestic"])

    let fundingSourceGroupedRef: React.ref<array<(string, float, float)>> = React.useRef([])
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")
    let colors = ["#4392BC", "#7CC5BF"]
    let maxFeeContribution = React.useRef(0.0)

    let setActiveTab = React.useMemo(() => {
      (str: string) => {
        setActiveTab(_ => [str])
      }
    }, [setActiveTab])

    fundingSourceGroupedRef.current = React.useMemo(() => {
      maxFeeContribution.current = 0.0
      let currentTab = activeTab->Array.at(0)->Option.getOr("domestic")

      let rawItems = switch selectedTransaction.regionBasedBreakdown {
      | items => items
      | _ => []
      }

      let costDict = Js.Dict.empty()
      let txnDict = Js.Dict.empty()

      rawItems->Array.forEach(item => {
        let funding = item.fundingSource

        if item.region == currentTab {
          let value = item.totalCostIncurred
          let txns = item.transactionCount->Int.toFloat

          let prevCost = costDict->Dict.get(funding)->Belt.Option.getWithDefault(0.0)
          costDict->Dict.set(funding, prevCost +. value)

          let prevTxn = txnDict->Dict.get(funding)->Belt.Option.getWithDefault(0.0)
          txnDict->Dict.set(funding, prevTxn +. txns)
        }
      })

      let grouped =
        costDict
        ->Js.Dict.entries
        ->Array.map(((k, v)) => {
          let txn = Js.Dict.get(txnDict, k)->Belt.Option.getWithDefault(0.0)
          maxFeeContribution.current = Math.max(maxFeeContribution.current, v)
          (k, v, txn)
        })

      grouped
    }, (activeTab, selectedTransaction))

    let optionPayload: stackedBarGraphPayload = {
      categories: [""],
      data: fundingSourceGroupedRef.current->Array.mapWithIndex(((funding, value, _), index) => {
        name: funding,
        data: [value],
        color: colors->Array.get(index)->Option.getOr("#4392BC"),
      }),
      labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Amount),
    }

    <div className="overflow-y-auto min-h-screen">
      <div className="flex flex-col  gap-12 p-2">
        <div className="grid grid-cols-2 gap-y-8 justify-between">
          <div className="flex flex-col gap-1">
            <p className="text-sm text-[#717784] font-medium">
              {"Total Cost Incurred"->React.string}
            </p>
            <p className="text-nd_gray-600 font-semibold">
              {LogicUtils.valueFormatter(
                selectedTransaction.totalCostIncurred,
                Amount,
              )->React.string}
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
              {LogicUtils.valueFormatter(
                selectedTransaction.transactionCount->Int.toFloat,
                Amount,
              )->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-1">
            <p className="text-sm text-[#717784] font-medium"> {"Contribution %"->React.string} </p>
            <p className="text-nd_gray-600 font-semibold">
              {LogicUtils.valueFormatter(selectedTransaction.gmvPercentage, Rate)->React.string}
            </p>
          </div>
        </div>
        <div>
          <p className="font-semibold text-nd_gray-700">
            {"Breakdown of fee contribution"->React.string}
          </p>
          <DynamicTabs
            tabs=filterTabValues
            maxSelection=3
            tabId="Fee Contribution Breakdown"
            setActiveTab
            tabContainerClass="!mt-4"
            initalTab=activeTab
            showAddMoreTabs=false
          />
          <div className="border border-nd_br_gray-150 pt-6 p-4 mt-3 rounded-xl">
            <StackedBarGraph
              options={StackedBarGraphUtils.getStackedBarGraphOptions(
                optionPayload,
                ~yMax=Math.Int.max(maxFeeContribution.current->Math.ceil->Int.fromFloat, 10),
                ~labelItemDistance={isMiniLaptopView ? 45 : 90},
              )}
            />
            <div
              className="flex flex-col gap-2 mt-6 p-3 rounded-xl bg-nd_gray-25 border border-nd_br_gray-150">
              <p className="text-xs text-nd_gray-400 font-semibold"> {"Summary"->React.string} </p>
              <ol className="flex flex-col gap-2">
                {fundingSourceGroupedRef.current
                ->Array.mapWithIndex(((funding, value, txns), index) => {
                  <li
                    key={index->Int.toString}
                    className="text-nd_gray-600 list-disc marker:text-nd_gray-600 ml-5 text-sm font-medium">
                    {`${funding->LogicUtils.camelCaseToTitle} processed ${txns->Float.toString} txns, with a total cost incurred ${LogicUtils.valueFormatter(
                        value,
                        Amount,
                      )}`->React.string}
                  </li>
                })
                ->React.array}
              </ol>
            </div>
          </div>
        </div>
      </div>
    </div>
  }
}

module CostBreakDown = {
  @react.component
  let make = (~costBreakDownRawData: overviewFeeEstimate) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let filteredTabVales: React.ref<array<DynamicTabs.tab>> = React.useRef([])
    let (filteredCostBreakDownTableData, setFilteredCostBreakDownTableData) = React.useState(_ =>
      costBreakDownRawData.overviewBreakdown
    )

    let filterValuesOptions = React.useMemo(() => {
      let cardBrandsSet = Set.make()
      costBreakDownRawData.overviewBreakdown->Array.forEach(value => {
        cardBrandsSet->Set.add(value.cardBrand)
      })
      let cardBrandsArray = []
      cardBrandsSet->Set.forEach(value => {
        cardBrandsArray->Array.push(value)
      })
      cardBrandsArray
    }, [costBreakDownRawData.overviewBreakdown])

    let cardBreakdownData: array<breakdownCard> = [
      {
        title: "Total Sales",
        value: costBreakDownRawData.totalGrossAmt,
      },
      {
        title: "Total Cost Incurred",
        value: costBreakDownRawData.totalCost,
      },
      {
        title: "Total Scheme Based Fee",
        value: costBreakDownRawData.totalSchemeCost,
      },
      {
        title: "Total Interchange Based Fee",
        value: costBreakDownRawData.totalInterchangeCost,
      },
    ]

    let sendMixpanelEvent = () => {
      mixpanelEvent(~eventName="hypersense_fee_estimation_transaction_view_table")
    }
    let defaultData: overViewFeesBreakdown = {
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

    let handleSelectedTransactionData = selectedData => {
      setSelectedTransaction(_ => selectedData)
      setShowModal(_ => true)
      let regionSet = Set.make()
      filteredTabVales.current = []
      selectedData.regionBasedBreakdown->Array.forEach(item => regionSet->Set.add(item.region))
      regionSet->Set.forEach(item => {
        let value: DynamicTabs.tab = {
          title: item,
          value: item,
          isRemovable: false,
        }
        filteredTabVales.current->Array.push(value)
      })
    }

    let handleFilterApply = (value: string) => {
      let filteredData =
        costBreakDownRawData.overviewBreakdown->Array.filter(item => item.cardBrand == value)
      setFilteredCostBreakDownTableData(_ => filteredData)
    }

    let filterIcon =
      <Icon name="filter" size={16} className="text-nd_gray-600 hover:text-nd_gray-800" />
    <div className="mt-10">
      <div className="flex items-center justify-between gap-2">
        <p className="text-lg font-semibold text-nd_gray-800"> {"Breakdown"->React.string} </p>
        <SingleSelectDropDown
          options={filterValuesOptions}
          name="Card Brand"
          page="costBreakdown"
          isButtonDisabled=false
          onApply={handleFilterApply}
          filterIcon
          globalFilterSelectedFilter=""
          isLoading=false
        />
      </div>
      <div className="grid grid-cols-4 gap-6 my-6">
        {cardBreakdownData
        ->Array.mapWithIndex((_card, index) => {
          <div
            className="flex flex-col rounded-xl w-full gap-4 p-4 border border-nd_br_gray-200"
            key={index->Int.toString}>
            <p className="text-sm font-medium text-nd_gray-400"> {_card.title->React.string} </p>
            <p className="text-xl font-semibold text-nd_gray-800">
              {`${LogicUtils.valueFormatter(_card.value, Amount)}`->React.string}
            </p>
          </div>
        })
        ->React.array}
      </div>
      <LoadedTable
        title="Cost Breakdown Overview"
        actualData={filteredCostBreakDownTableData->Array.map(Nullable.make)}
        totalResults={filteredCostBreakDownTableData->Array.length}
        resultsPerPage=10
        offset
        setOffset
        headingCenter=true
        alignCellContent="flex items-center justify-center"
        entity={FeeEstimationEntity.feeOverviewEstimationEntity(
          ~authorization=userHasAccess(~groupAccess=AnalyticsView),
          ~sendMixpanelEvent,
        )}
        currrentFetchCount={filteredCostBreakDownTableData->Array.length}
        onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
        collapseTableRow=false
        showAutoScroll=true
      />
      <Modal
        showModal
        modalHeading={"Transaction details"}
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-full overflow-y-hidden max-w-[539px] !bg-white dark:!bg-jp-gray-lightgray_background">
        <CostBreakDownSideModal
          selectedTransaction={selectedTransaction} filterTabValues={filteredTabVales.current}
        />
      </Modal>
    </div>
  }
}

module OverviewContainer = {
  @react.component
  let make = () => {
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let defaultValue: overviewFeeEstimate = {
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
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let overViewData =
          FeeEstimationMockData.overViewMockData
          ->LogicUtils.getDictFromJsonObject
          ->FeeEstimationUtils.overviewDataMapper

        setOverviewRawData(_ => overViewData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }

    React.useEffect(() => {
      fetchOverviewData()->ignore
      None
    }, [])

    let cardBreakdownData: array<breakdownCard> = [
      {
        title: "Total Sales",
        value: overviewRawData.totalGrossAmt,
      },
      {
        title: "Total Cost Incurred",
        value: overviewRawData.totalCost,
      },
      {
        title: "Total Scheme Based Fee",
        value: overviewRawData.totalSchemeCost,
      },
      {
        title: "Total Interchange Based Fee",
        value: overviewRawData.totalInterchangeCost,
      },
    ]

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
      customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
      <div>
        <TotalCostIncurred totalIncurredCost={overviewRawData} />
        <FeeBreakdownBasedOnGeoLocation
          feeBreakdownData=overviewRawData.feeBreakdownBasedOnGeoLocation
        />
        <CostBreakDown costBreakDownRawData={overviewRawData} />
      </div>
    </PageLoaderWrapper>
  }
}

module AppliedFeesBreakdown = {
  open FeeEstimationEntity
  @react.component
  let make = (~appliedFeesData: breakdownItem) => {
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = feesBreakdownColumns->Array.map(getFeeBreakdownHeading)
    let rows = [
      [
        Table.Text("Interchange fees"),
        Table.CustomCell(
          <p>
            {`${appliedFeesData.estimateInterchangeVariableRate->Float.toString} % + $ ${appliedFeesData.estimateInterchangeFixedRate->Float.toString}`->React.string}
          </p>,
          "",
        ),
        Table.Text(appliedFeesData.estimateInterchangeCost->Float.toString),
      ],
      [
        Table.Text("Scheme fees"),
        Table.Text("Charged differently"),
        Table.Text(appliedFeesData.estimateSchemeTotalCost->Float.toString),
      ],
    ]

    let collapseClick = idx => {
      let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
      setExpandedRowIndexArray(_ => {
        let array = expandedRowIndexArray->Array.map(item => item)
        array->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])
        array
      })
    }

    let onExpandClick = idx => {
      if idx > 0 {
        setExpandedRowIndexArray(_ => {
          [idx]
        })
      }
    }

    let onExpandIconClick = (isCurrentRowExpanded, rowIndex) => {
      if isCurrentRowExpanded {
        collapseClick(rowIndex)
      } else {
        onExpandClick(rowIndex)
      }
    }

    let rowsSchemeBreakdown =
      <React.Fragment>
        {appliedFeesData.estimateSchemeBreakdown
        ->Array.mapWithIndex((item, index) => {
          <tr
            key={item.feeName ++ index->Int.toString}
            className="group h-full rounded-md bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 text-jp-gray-900 dark:text-jp-gray-text_darktheme text-opacity-75 dark:text-opacity-75 font-fira-code transition duration-300 ease-in-out text-sm}">
            {feesBreakdownColumns
            ->Array.map(colType => {
              <td
                key={(colType :> string)}
                className="h-full p-0 align-top border-t border-jp-gray-500 dark:border-jp-gray-960 px-4 py-3">
                {switch colType {
                | FeeType =>
                  let feeName = item.feeName->LogicUtils.snakeToTitle
                  <div className="flex items-center gap-2">
                    <Icon name="expanded-arrow-icon" size=14 />
                    <span> {feeName->React.string} </span>
                  </div>
                | Rate =>
                  <p>
                    {`${item.variableRate->Float.toString} % ${item.cost->Float.toString}`->React.string}
                  </p>
                | TotalCost =>
                  <p> {`$ ${LogicUtils.valueFormatter(item.cost, Amount)}`->React.string} </p>
                }}
              </td>
            })
            ->React.array}
          </tr>
        })
        ->React.array}
      </React.Fragment>

    let getRowDetails = _ => {
      rowsSchemeBreakdown
    }

    <CustomExpandableTable
      title="Refunds"
      heading
      rows
      onExpandIconClick
      expandedRowIndexArray
      getRowDetails
      showSerial=false
      rowComponentInCell=false
    />
  }
}

module TransactionViewSideModal = {
  @react.component
  let make = (~selectedTransaction: breakdownItem) => {
    <div className="p-2">
      <div className="grid grid-cols-2 gap-y-8 justify-between">
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Payment ID"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.paymentId->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Card Brand"->React.string} </p>
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
          <p className="text-sm text-[#717784] font-medium"> {"Type of Card"->React.string} </p>
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
          <p className="text-sm text-[#717784] font-medium"> {"Regionality"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.regionality->LogicUtils.camelCaseToTitle->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Card Variant"->React.string} </p>
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
      <div className="flex flex-col gap-4 mt-10">
        <p className="text-nd_gray-700 font-semibold"> {"Fee Applied"->React.string} </p>
        <AppliedFeesBreakdown appliedFeesData=selectedTransaction />
      </div>
    </div>
  }
}

module TransactionViewContainer = {
  @react.component
  let make = () => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let defaultData: breakdownItem = {
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
    }

    let fetchData = () => {
      let transactionData =
        FeeEstimationMockData.mockData
        ->LogicUtils.getDictFromJsonObject
        ->FeeEstimationUtils.feeEstimationMapper
      setTransactionData(_ => transactionData.breakdown)
    }

    React.useEffect(_ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        fetchData()->ignore
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
      }
      None
    }, [])

    <div>
      <RenderIf condition={transactionData->Array.length > 0}>
        <PageLoaderWrapper
          screenState
          customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
          customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
          <LoadedTable
            title="Fee Estimate Transaction Overview"
            actualData={transactionData->Array.map(Nullable.make)}
            totalResults={transactionData->Array.length}
            resultsPerPage=10
            offset
            setOffset
            headingCenter=true
            alignCellContent="flex items-center justify-center"
            entity={FeeEstimationEntity.feeEstimationEntity(
              ~authorization=userHasAccess(~groupAccess=AnalyticsView),
              ~sendMixpanelEvent,
            )}
            currrentFetchCount={transactionData->Array.length}
            onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
            collapseTableRow=false
            showAutoScroll=true
          />
        </PageLoaderWrapper>
        <Modal
          showModal
          modalHeading={"Transaction details"}
          setShowModal
          closeOnOutsideClick=true
          modalClass="w-full h-full max-w-[539px] !bg-white dark:!bg-jp-gray-lightgray_background">
          <TransactionViewSideModal selectedTransaction />
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

  let setActiveTab = React.useMemo(() => {
    (str: string) => {
      setActiveTab(_ => [str])
    }
  }, [setActiveTab])

  <div>
    <p className="text-2xl font-semibold text-nd_gray-800"> {"Fee Estimate"->React.string} </p>
    <DynamicTabs
      tabs=filteredTabVales
      maxSelection=3
      tabId="FeeEstimationAnalytics"
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
