open FeeEstimationTypes
open FeeEstimationHelper
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
          {`${totalIncurredCost.currency} ${LogicUtils.valueFormatter(
              totalIncurredCost.totalCost,
              Amount,
            )}`->React.string}
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
            labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Amount),
          },
          ~yMax=Math.Int.max(totalIncurredCost.totalCost->Math.ceil->Int.fromFloat, 1),
          ~labelItemDistance={isMiniLaptopView ? 45 : 90},
        )}
      />
    </div>
  }
}

module FeeBreakdownBasedOnGeoLocation = {
  @react.component
  let make = (~feeBreakdownData: array<feeBreakdownGeoLocation>, ~currency: string) => {
    let payload = FeeEstimationHelper.feeBreakdownBasedOnGeoLocationPayload(
      ~feeBreakdownData,
      ~currency,
    )
    let maxFeeValue = React.useMemo(() => {
      feeBreakdownData->Array.reduce(0.0, (acc, item) => {
        Math.max(acc, item.fees)
      })
    }, [feeBreakdownData])

    let tickInterval = {
      let exp = Math.floor(Math.log10(maxFeeValue))
      Math.pow(10.0, ~exp=exp -. 1.0) *. if maxFeeValue /. Math.pow(10.0, ~exp) < 1.5 {
        1.0
      } else if maxFeeValue /. Math.pow(10.0, ~exp) < 3.0 {
        2.0
      } else if maxFeeValue /. Math.pow(10.0, ~exp) < 7.0 {
        5.0
      } else {
        10.0
      }
    }

    let options = BarGraphUtils.getBarGraphOptions(
      payload,
      ~pointWidth=24,
      ~borderRadius=5,
      ~borderWidth=0.2,
      ~gridLineWidthXAxis=0,
      ~gridLineWidthYAxis=0,
      ~height=Some(264.0),
      ~tickWidth=0,
      ~tickInterval,
      ~yMax=Math.Int.max(maxFeeValue->Math.ceil->Int.fromFloat, 0),
      ~xAxisLineWidth=Some(0),
      ~yAxisLabelFormatter=Some(FeeEstimationHelper.labelFormatter(currency)),
    )

    <div className="border border-nd_gray-200 rounded-xl">
      <div className="bg-nd_gray-25 py-4 px-4 rounded-t-xl">
        <p className="font-semibold text-nd_gray-600">
          {"Fee Breakdown Based on Geolocation"->React.string}
        </p>
      </div>
      <div className="border-t border-t-nd_gray-200">
        <BarGraph options className="h-[270px]" />
      </div>
    </div>
  }
}

module CostBreakDownSideModal = {
  @react.component
  let make = React.memo((~selectedTransaction: overViewFeesBreakdown) => {
    let filterTabValues = React.useMemo(() => {
      let regionSet = Set.make()
      let filterTab = ref([])
      selectedTransaction.regionBasedBreakdown->Array.forEach(
        item => regionSet->Set.add(item.region),
      )
      regionSet->Set.forEach(
        item => {
          let value: DynamicTabs.tab = {
            title: item,
            value: item,
            isRemovable: false,
          }
          filterTab.contents->Array.push(value)
        },
      )
      filterTab.contents
    }, [])

    let firstFilterValue =
      filterTabValues
      ->Array.at(0)
      ->Option.getOr({
        title: "",
        value: "",
        isRemovable: false,
      })
    let (activeTab, setActiveTab) = React.useState(_ => [firstFilterValue.value])

    let maxFeeContribution = React.useRef(0.0)

    let fundingSourceGroupedRef = React.useMemo(() => {
      maxFeeContribution.current = 0.0
      let currentTab = activeTab->Array.at(0)->Option.getOr("domestic")
      let costDict = Dict.make()
      let txnDict = Dict.make()

      selectedTransaction.regionBasedBreakdown
      ->Array.filter(item => currentTab->String.toLowerCase == item.region->String.toLowerCase)
      ->Array.forEach(
        item => {
          let funding = item.fundingSource
          let value = item.totalCostIncurred
          let txns = item.transactionCount

          let prevCost = costDict->Dict.get(funding)->Option.getOr(0.0)
          costDict->Dict.set(funding, prevCost +. value)
          let prevTxn = txnDict->Dict.get(funding)->Option.getOr(0)
          txnDict->Dict.set(funding, prevTxn + txns)
        },
      )

      costDict
      ->Dict.toArray
      ->Array.map(
        ((k, v)) => {
          let txn = txnDict->Dict.get(k)->Option.getOr(0)
          maxFeeContribution.current = Math.max(maxFeeContribution.current, v)
          (k, v, txn)
        },
      )
    }, (activeTab, selectedTransaction))

    let options = React.useMemo(() => {
      let breakdownContributions = fundingSourceGroupedRef->Array.map(
        ((brand, value, _otherValue)) => {
          cardBrand: brand,
          currency: selectedTransaction.transactionCurrency,
          value,
        },
      )

      let maxValue = Math.max(maxFeeContribution.current->Math.ceil, 0.0)

      FeeEstimationHelper.costBreakDownBasedOnGeoLocationPayload(
        ~costBreakDownData=breakdownContributions,
        ~currency=selectedTransaction.transactionCurrency,
      )->BarGraphUtils.getBarGraphOptions(
        ~pointWidth=24,
        ~borderRadius=4,
        ~borderWidth=0.2,
        ~gridLineWidthXAxis=0,
        ~gridLineWidthYAxis=0,
        ~tickInterval=Math.pow(10.0, ~exp=Math.floor(Math.log10(maxValue +. 1.0)) -. 1.0),
        ~yMax=Math.Int.max(maxFeeContribution.current->Math.ceil->Int.fromFloat, 0),
        ~height=Some(140.0),
        ~tickWidth=0,
        ~xAxisLineWidth=Some(0),
        ~yAxisLineWidth=Some(1),
      )
    }, (fundingSourceGroupedRef, selectedTransaction))

    <div className="overflow-y-auto flex flex-col gap-24 min-h-screen">
      <div className="flex flex-col gap-12 p-2">
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
              {LogicUtils.valueFormatter(
                selectedTransaction.contributionPercentage,
                Rate,
              )->React.string}
            </p>
          </div>
        </div>
        <div>
          <p className="font-semibold text-nd_gray-700">
            {`Breakdown of fee contribution ${filterTabValues->Array.length == 1
                ? `- ${activeTab->Array.at(0)->Option.getOr("")->LogicUtils.snakeToTitle}`
                : ""}`->React.string}
          </p>
          <RenderIf condition={filterTabValues->Array.length > 1}>
            <DynamicTabs
              tabs=filterTabValues
              maxSelection=3
              tabId="Fee Contribution Breakdown"
              setActiveTab={tab => setActiveTab(_ => [tab])}
              tabContainerClass="!mt-4"
              initalTab=activeTab
              showAddMoreTabs=false
            />
          </RenderIf>
          <div className="border border-nd_br_gray-150 pt-6 p-4 mt-3 rounded-xl">
            <BarGraph options />
            <p className="text-center text-xs text-nd_gray-600">
              {`Fees (${selectedTransaction.transactionCurrency})`->React.string}
            </p>
            <div
              className="flex flex-col gap-2 mt-6 p-3 rounded-xl bg-nd_gray-25 border border-nd_br_gray-150">
              <p className="text-xs text-nd_gray-400 font-semibold"> {"Summary"->React.string} </p>
              <ol className="flex flex-col gap-2">
                {fundingSourceGroupedRef
                ->Array.mapWithIndex(((funding, value, txns), index) => {
                  <li
                    key={index->Int.toString}
                    className="text-nd_gray-600 list-disc marker:text-nd_gray-600 ml-5 text-sm font-medium">
                    {`${funding->LogicUtils.camelCaseToTitle} processed ${txns->Int.toString} txns, with a total cost incurred ${selectedTransaction.transactionCurrency} ${LogicUtils.valueFormatter(
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
  })
}

module CostBreakDown = {
  @react.component
  let make = (~costBreakDownRawData: overviewFeeEstimate) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let (checkedFields, setCheckedFields) = React.useState(_ => [])
    let (filteredCostBreakDownTableData, setFilteredCostBreakDownTableData) = React.useState(_ =>
      costBreakDownRawData.overviewBreakdown
    )
    let (selectedTransaction, setSelectedTransaction) = React.useState(_ =>
      JSON.Encode.object(Dict.make())->FeeEstimationUtils.overviewBreakdownItemMapper
    )

    let (sortAtomValue, _) = Recoil.useRecoilState(LoadedTable.sortAtom)

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

    let cardBreakdownData = React.useMemo(() => {
      let dataToUse = switch checkedFields->Array.length {
      | 0 => costBreakDownRawData.topValuesBasedOnCardBrand
      | _ =>
        costBreakDownRawData.topValuesBasedOnCardBrand->Array.filter(item =>
          checkedFields->Array.includes(item.cardBrand)
        )
      }

      let (
        totalGrossAmt,
        totalCost,
        totalSchemeCost,
        totalInterchangeCost,
      ) = dataToUse->Array.reduce((0.0, 0.0, 0.0, 0.0), (
        (grossAcc, costAcc, schemeAcc, interchangeAcc),
        item,
      ) => {
        (
          grossAcc +. item.totalGrossAmt,
          costAcc +. item.totalCost,
          schemeAcc +. item.totalSchemeCost,
          interchangeAcc +. item.totalInterchangeCost,
        )
      })

      [
        {
          title: "Total Sales",
          value: totalGrossAmt,
          currency: costBreakDownRawData.currency,
        },
        {
          title: "Total Cost Incurred",
          value: totalCost,
          currency: costBreakDownRawData.currency,
        },
        {
          title: "Total Scheme Based Fee",
          value: totalSchemeCost,
          currency: costBreakDownRawData.currency,
        },
        {
          title: "Total Interchange Based Fee",
          value: totalInterchangeCost,
          currency: costBreakDownRawData.currency,
        },
      ]
    }, (checkedFields, costBreakDownRawData.topValuesBasedOnCardBrand))

    let handleSelectedTransactionData = selectedData => {
      setSelectedTransaction(_ => selectedData)
      setShowModal(_ => true)
    }

    let onChangeSelect = ev => {
      let fieldNameArr = ev->Identity.formReactEventToArrayOfString
      let filteredData = if fieldNameArr->Array.length > 0 {
        costBreakDownRawData.overviewBreakdown->Array.filter(item =>
          fieldNameArr->Array.includes(item.cardBrand)
        )
      } else {
        costBreakDownRawData.overviewBreakdown
      }

      setCheckedFields(_ => fieldNameArr)
      setFilteredCostBreakDownTableData(_ => filteredData)
    }

    React.useEffect(() => {
      let costBreakDownAtomValue =
        sortAtomValue
        ->Dict.get(costBreakDownTableKey)
        ->Option.getOr({sortKey: "", sortType: DSC})
      switch costBreakDownAtomValue.sortType {
      | ASC =>
        setFilteredCostBreakDownTableData(_ =>
          filteredCostBreakDownTableData->Array.toSorted(
            (a, b) => LogicUtils.compareLogic(b.contributionPercentage, a.contributionPercentage),
          )
        )
      | DSC =>
        setFilteredCostBreakDownTableData(_ =>
          filteredCostBreakDownTableData->Array.toSorted(
            (a, b) => LogicUtils.compareLogic(a.contributionPercentage, b.contributionPercentage),
          )
        )
      }
      None
    }, [sortAtomValue])

    <div className="mt-10">
      <div className="flex items-center justify-between gap-2">
        <p className="text-lg font-semibold text-nd_gray-800"> {"Breakdown"->React.string} </p>
        <CustomInputSelectBox
          onChange=onChangeSelect
          options={filterValuesOptions->SelectBox.makeOptions}
          allowMultiSelect=true
          buttonText={switch checkedFields->Array.length {
          | 0 => "Select Card Brand"
          | _ => `Selected Card Brand (${checkedFields->Array.length->Int.toString})`
          }}
          isDropDown=true
          hideMultiSelectButtons=true
          buttonType={Secondary}
          value={checkedFields->Array.map(JSON.Encode.string)->JSON.Encode.array}
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
              {`${_card.currency} ${LogicUtils.valueFormatter(_card.value, Amount)}`->React.string}
            </p>
          </div>
        })
        ->React.array}
      </div>
      {switch filteredCostBreakDownTableData->Array.length {
      | 0 => <NoDataFound message="No data available for selected month" />
      | _ =>
        <LoadedTable
          title=costBreakDownTableKey
          hideTitle=true
          actualData={filteredCostBreakDownTableData->Array.map(Nullable.make)}
          totalResults={costBreakDownRawData.totalRecords}
          resultsPerPage=10
          offset
          setOffset
          headingCenter=false
          alignCellContent="flex items-center text-left"
          entity={FeeEstimationEntity.feeOverviewEstimationEntity()}
          currrentFetchCount={filteredCostBreakDownTableData->Array.length}
          onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
          collapseTableRow=false
          showAutoScroll=true
        />
      }}
      <Modal
        showModal
        modalHeading={"Transaction details"}
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-full overflow-y-hidden max-w-[539px] !bg-white dark:!bg-jp-gray-lightgray_background">
        <CostBreakDownSideModal selectedTransaction />
      </Modal>
    </div>
  }
}
