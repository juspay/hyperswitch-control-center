open FeeEstimationTypes
open FeeEstimationHelper
open LogicUtils
open Typography
open FeeEstimationUtils
open CurrencyFormatUtils

module TotalCostIncurred = {
  @react.component
  let make = (~totalIncurredCost: overviewFeeEstimate) => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")

    <div className="flex flex-col gap-2 rounded-xl border border-nd_br_gray-200 pt-3 p-4 my-6">
      <div className="flex flex-col gap-2">
        <p className={`${body.sm.medium} text-nd_gray-400`}>
          {"Total Cost Incurred"->React.string}
        </p>
        <p className={`${heading.lg.semibold} text-nd_gray-800`}>
          {`${totalIncurredCost.currency} ${valueFormatter(
              totalIncurredCost.totalCost,
              Amount,
            )}`->React.string}
        </p>
      </div>
      <StackedBarGraph
        options={getTotalCostIncurredGraphOptions(totalIncurredCost, isMiniLaptopView)}
      />
    </div>
  }
}

module FeeBreakdownBasedOnGeoLocation = {
  @react.component
  let make = (~feeBreakdownData: array<feeBreakdownGeoLocation>, ~currency: string) => {
    let payload = feeBreakdownBasedOnGeoLocationPayload(~feeBreakdownData, ~currency)
    let maxFeeValue = React.useMemo(() => {
      feeBreakdownData->Array.reduce(0.0, (acc, item) => {
        Math.max(acc, item.fees)
      })
    }, [feeBreakdownData])

    let options = BarGraphUtils.getBarGraphOptions(
      payload,
      ~pointWidth=24,
      ~borderRadius=5,
      ~borderWidth=0.2,
      ~gridLineWidthXAxis=0,
      ~gridLineWidthYAxis=0,
      ~height=Some(264.0),
      ~tickWidth=0,
      ~tickInterval=getTotalCostIncurredGraphTickInterval(maxFeeValue),
      ~yMax=Math.Int.max(maxFeeValue->Math.ceil->Int.fromFloat, 0),
      ~xAxisLineWidth=Some(0),
      ~yAxisLabelFormatter=Some(labelFormatter(currency)),
    )

    <div className="border border-nd_gray-200 rounded-xl overflow-hidden">
      <div className="bg-nd_gray-25 py-4 px-4 rounded-t-xl">
        <p className={`${body.lg.semibold} text-nd_gray-600`}>
          {"Fee Breakdown Based on Geolocation"->React.string}
        </p>
      </div>
      <div className="border-t border-t-nd_gray-200">
        <BarGraph options className="h-270-px" />
      </div>
    </div>
  }
}

module CostBreakdownSummary = {
  @react.component
  let make = (~selectedTransaction, ~fundingSourceGroupedValue) => {
    <div>
      <p className={`text-center ${body.sm.medium} text-nd_gray-600`}>
        {`Fees (${selectedTransaction.transactionCurrency})`->React.string}
      </p>
      <div
        className="flex flex-col gap-2 mt-6 p-3 rounded-xl bg-nd_gray-25 border border-nd_br_gray-150">
        <p className={`${body.sm.semibold} text-nd_gray-400`}> {"Summary"->React.string} </p>
        <ol className="flex flex-col gap-2">
          {fundingSourceGroupedValue
          ->Array.map(((funding, value, txns)) => {
            <li
              key={randomString(~length=10)}
              className={`text-nd_gray-600 list-disc marker:text-nd_gray-600 ml-5 ${body.sm.medium}`}>
              {`${funding->camelCaseToTitle} processed ${txns->Int.toString} txns, with a total cost incurred ${selectedTransaction.transactionCurrency} ${valueFormatter(
                  value,
                  Amount,
                )}`->React.string}
            </li>
          })
          ->React.array}
        </ol>
      </div>
    </div>
  }
}

module CostBreakDownSideModal = {
  @react.component
  let make = React.memo((~selectedTransaction) => {
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

    let firstFilterValue = filterTabValues->getValueFromArray(
      0,
      {
        title: "",
        value: "",
        isRemovable: false,
      },
    )

    let (activeTab, setActiveTab) = React.useState(_ => [firstFilterValue.value])

    let (fundingSourceGroupedRef, maxFeeContribution) = React.useMemo(() => {
      fundingSourceGrouped(activeTab, selectedTransaction.regionBasedBreakdown)
    }, (activeTab, selectedTransaction))

    let options = React.useMemo(() => {
      let breakdownContributions = fundingSourceGroupedRef->Array.map(
        ((brand, value, _)) => {
          cardBrand: brand,
          currency: selectedTransaction.transactionCurrency,
          value,
        },
      )

      let maxValue = Math.max(maxFeeContribution->Math.ceil, 0.0)

      costBreakDownBasedOnGeoLocationPayload(
        ~costBreakDownData=breakdownContributions,
        ~currency=selectedTransaction.transactionCurrency,
      )->BarGraphUtils.getBarGraphOptions(
        ~pointWidth=24,
        ~borderRadius=4,
        ~borderWidth=0.2,
        ~gridLineWidthXAxis=0,
        ~gridLineWidthYAxis=0,
        ~tickInterval=Math.pow(10.0, ~exp=Math.floor(Math.log10(maxValue +. 1.0)) -. 1.0),
        ~yMax=Math.Int.max(maxFeeContribution->Math.ceil->Int.fromFloat, 0),
        ~height=Some(140.0),
        ~tickWidth=0,
        ~xAxisLineWidth=Some(0),
        ~yAxisLineWidth=Some(1),
      )
    }, (fundingSourceGroupedRef, selectedTransaction))

    let modalInfoData = modalInfoDataOverview(selectedTransaction)

    let modalSubHeading = `Breakdown of fee contribution ${filterTabValues->Array.length == 1
        ? `- ${activeTab->getValueFromArray(0, "")->snakeToTitle}`
        : ""}`

    <div className="overflow-y-auto flex flex-col gap-24 min-h-screen">
      <div className="flex flex-col gap-12 p-2">
        <div className="grid grid-cols-2 gap-y-8 justify-between">
          <FeeEstimationHelper.ModalInfoSection modalInfoData />
        </div>
        <div>
          <p className={`${body.lg.semibold} text-nd_gray-700`}>
            {modalSubHeading->React.string}
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
            <CostBreakdownSummary
              selectedTransaction fundingSourceGroupedValue={fundingSourceGroupedRef}
            />
          </div>
        </div>
      </div>
    </div>
  })
}

module CostBreakDown = {
  @react.component
  let make = (~overViewBreakdownRawData: overViewBreakdownData, ~overViewBreakdownTableData) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let (checkedFields, setCheckedFields) = React.useState(_ => [])
    let (filteredCostBreakDownTableData, setFilteredCostBreakDownTableData) = React.useState(_ =>
      overViewBreakdownTableData
    )
    let (selectedTransaction, setSelectedTransaction) = React.useState(_ =>
      JSON.Encode.null->overviewBreakdownItemMapper
    )

    let (sortAtomValue, _) = Recoil.useRecoilState(LoadedTable.sortAtom)

    let filterValuesOptions = React.useMemo(() => {
      let cardBrandsSet = Set.make()
      overViewBreakdownRawData.overviewBreakdown->Array.forEach(value => {
        cardBrandsSet->Set.add(value.cardBrand)
      })
      let cardBrandsArray = []
      cardBrandsSet->Set.forEach(value => {
        cardBrandsArray->Array.push(value)
      })
      cardBrandsArray
    }, [overViewBreakdownRawData])

    let cardBreakdownData = React.useMemo(() => {
      let dataToUse =
        checkedFields->Array.length == 0
          ? overViewBreakdownRawData.topValuesBasedOnCardBrand
          : overViewBreakdownRawData.topValuesBasedOnCardBrand->Array.filter(item =>
              checkedFields->Array.includes(item.cardBrand)
            )

      calculateCardBreakdownData(dataToUse, overViewBreakdownRawData.currency)
    }, (checkedFields, overViewBreakdownRawData.topValuesBasedOnCardBrand))

    let handleSelectedTransactionData = selectedData => {
      setSelectedTransaction(_ => selectedData)
      setShowModal(_ => true)
    }

    let onChangeSelect = ev => {
      let fieldNameArr = ev->Identity.formReactEventToArrayOfString
      let filteredData = if fieldNameArr->Array.length > 0 {
        overViewBreakdownRawData.overviewBreakdown->Array.filter(item =>
          fieldNameArr->Array.includes(item.cardBrand)
        )
      } else {
        overViewBreakdownRawData.overviewBreakdown
      }

      setCheckedFields(_ => fieldNameArr)
      setFilteredCostBreakDownTableData(_ => filteredData)
    }

    let costBreakDownAtomValue = React.useCallback(() => {
      let sortDictValue =
        sortAtomValue
        ->Dict.get(costBreakDownTableKey)
        ->Option.getOr({sortKey: "", sortType: DSC})
      switch sortDictValue.sortType {
      | ASC =>
        setFilteredCostBreakDownTableData(_ =>
          filteredCostBreakDownTableData->Array.toSorted(
            (a, b) => compareLogic(b.contributionPercentage, a.contributionPercentage),
          )
        )
      | DSC =>
        setFilteredCostBreakDownTableData(_ =>
          filteredCostBreakDownTableData->Array.toSorted(
            (a, b) => compareLogic(a.contributionPercentage, b.contributionPercentage),
          )
        )
      }
    }, [sortAtomValue])

    React.useEffect(() => {
      costBreakDownAtomValue()->ignore
      None
    }, (sortAtomValue, costBreakDownAtomValue))

    <div className="mt-10">
      <div className="flex items-center justify-between gap-2">
        <p className={`${heading.md.semibold} text-nd_gray-800`}> {"Breakdown"->React.string} </p>
        <CustomInputSelectBox
          onChange=onChangeSelect
          options={filterValuesOptions->SelectBox.makeOptions}
          allowMultiSelect=true
          buttonText={checkedFields->Array.length == 0
            ? "Select Card Brand"
            : `Selected Card Brand (${checkedFields->Array.length->Int.toString})`}
          isDropDown=true
          hideMultiSelectButtons=true
          buttonType={Secondary}
          value={checkedFields->Array.map(JSON.Encode.string)->JSON.Encode.array}
        />
      </div>
      <div className="grid grid-cols-4 gap-6 my-6">
        {cardBreakdownData
        ->Array.map(card => {
          <div
            className="flex flex-col rounded-xl w-full gap-4 p-4 border border-nd_br_gray-200"
            key={randomString(~length=10)}>
            <p className={`${body.sm.medium} text-nd_gray-400`}> {card.title->React.string} </p>
            <p className={`${heading.md.semibold} text-nd_gray-800`}>
              {`${card.currency} ${valueFormatter(card.value, Amount)}`->React.string}
            </p>
          </div>
        })
        ->React.array}
      </div>
      <RenderIf condition={filteredCostBreakDownTableData->Array.length == 0}>
        <NoDataFound message="No data available for selected month" />
      </RenderIf>
      <RenderIf condition={filteredCostBreakDownTableData->Array.length > 0}>
        <LoadedTable
          title=costBreakDownTableKey
          hideTitle=true
          actualData={overViewBreakdownTableData->Array.map(Nullable.make)}
          totalResults={overViewBreakdownRawData.totalRecords}
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
      </RenderIf>
      <Modal
        showModal
        modalHeading="Transaction details"
        setShowModal
        closeOnOutsideClick=true
        modalClass="overflow-y-hidden w-540-px !bg-white dark:!bg-jp-gray-lightgray_background">
        <CostBreakDownSideModal selectedTransaction />
      </Modal>
    </div>
  }
}
