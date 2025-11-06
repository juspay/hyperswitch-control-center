open FeeEstimationTypes
open FeeEstimationOverview
open FeeEstimationTransactionView
open FeeEstimationHelper
open Typography
open LogicUtils

module OverviewBreakdown = {
  @react.component
  let make = (~monthFilters) => {
    let getURL = APIUtils.useGetURL()
    let showToast = ToastState.useShowToast()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
    let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
    let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
    let pageDetail = pageDetailDict->Dict.get(costBreakDownTableKey)->Option.getOr(defaultValue)

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (overViewBreakdownRawData, setOverViewBreakdownRawData) = React.useState(_ =>
      Dict.make()->FeeEstimationUtils.overviewBreakdownMapper
    )
    let (overViewBreakdownTableData, setOverViewBreakdownTableData) = React.useState(_ => [])

    let fetchOverviewTableData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=V1(FEE_OVERVIEW_ESTIMATE_BREAKDOWN), ~methodType=Post)
        let body = {
          "offset": pageDetail.offset,
          "limit": pageDetail.resultsPerPage,
          "startDate": monthFilters["startDate"],
          "endDate": monthFilters["endDate"],
        }->Identity.genericTypeToJson

        let response = await updateDetails(url, body, Fetch.Post)
        let overViewBreakdownDataResponse =
          response
          ->getDictFromJsonObject
          ->getDictfromDict("response")
          ->FeeEstimationUtils.overviewBreakdownMapper

        Console.log2("overview breakdown data fetched:", overViewBreakdownDataResponse)
        setOverViewBreakdownRawData(_ => overViewBreakdownDataResponse)
        setOverViewBreakdownTableData(_ => overViewBreakdownDataResponse.overviewBreakdown)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Error(""))
          showToast(
            ~message="Error while fetching overview data. Please try again",
            ~toastType=ToastError,
          )
        }
      }
    }

    React.useEffect(() => {
      fetchOverviewTableData()->ignore
      None
    }, [pageDetail.offset, pageDetail.resultsPerPage])
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
      customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
      <CostBreakDown overViewBreakdownRawData overViewBreakdownTableData />
    </PageLoaderWrapper>
  }
}

module OverviewContainer = {
  @react.component
  let make = (~monthFilters) => {
    let getURL = APIUtils.useGetURL()
    let showToast = ToastState.useShowToast()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (overviewRawData, setOverviewRawData) = React.useState(_ =>
      Dict.make()->FeeEstimationUtils.overviewDataMapper
    )

    let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
    let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
    let pageDetail = pageDetailDict->Dict.get(costBreakDownTableKey)->Option.getOr(defaultValue)

    let fetchOverviewData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=V1(FEE_OVERVIEW_ESTIMATE), ~methodType=Post)
        let body = {
          "payload": {
            "offset": pageDetail.offset,
            "limit": pageDetail.resultsPerPage,
            "startDate": monthFilters["startDate"],
            "endDate": monthFilters["endDate"],
          },
        }->Identity.genericTypeToJson

        let response = await updateDetails(url, body, Fetch.Post)
        let overViewData =
          response
          ->getDictFromJsonObject
          ->getDictfromDict("response")
          ->FeeEstimationUtils.overviewDataMapper

        setOverviewRawData(_ => overViewData)
        Console.log2("overview data fetched:", overViewData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Error(""))
          showToast(
            ~message="Error while fetching overview data. Please try again",
            ~toastType=ToastError,
          )
        }
      }
    }

    React.useEffect(() => {
      fetchOverviewData()->ignore
      None
    }, [])

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
      customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
      <TotalCostIncurred totalIncurredCost={overviewRawData} />
      <FeeBreakdownBasedOnGeoLocation
        feeBreakdownData=overviewRawData.feeBreakdownBasedOnGeoLocation
        currency=overviewRawData.currency
      />
      <OverviewBreakdown monthFilters />
    </PageLoaderWrapper>
  }
}

module TransactionViewContainer = {
  @react.component
  let make = (~monthFilters) => {
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
    let showToast = ToastState.useShowToast()

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let (selectedTransaction, setSelectedTransaction) = React.useState(_ =>
      JSON.Encode.null->FeeEstimationUtils.feeEstimateBreakdownMapper
    )
    let (transactionRawData, setTransactionRawData) = React.useState(_ =>
      Dict.make()->FeeEstimationUtils.feeEstimationMapper
    )
    let (transactionData, setTransactionData) = React.useState(_ => [])

    let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
    let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
    let pageDetail = pageDetailDict->Dict.get(transactionViewTableKey)->Option.getOr(defaultValue)

    let handleSelectedTransactionData = selectedData => {
      setSelectedTransaction(_ => selectedData)
      setShowModal(_ => true)
    }

    let fetchData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=V1(FEE_TRANSACTION_ESTIMATE), ~methodType=Post)
        let body = {
          "payload": {
            "offset": offset,
            "limit": pageDetail.resultsPerPage,
            "startDate": monthFilters["startDate"],
            "endDate": monthFilters["endDate"],
          },
        }->Identity.genericTypeToJson

        let response = await updateDetails(url, body, Fetch.Post)
        let transactionData =
          response
          ->getDictFromJsonObject
          ->getDictfromDict("response")
          ->FeeEstimationUtils.feeEstimationMapper

        let paddedRows = Array.make(
          ~length=offset,
          JSON.Encode.object(Dict.make())
          ->FeeEstimationUtils.feeEstimateBreakdownMapper
          ->Nullable.make,
        )
        let paginatedTransactionData =
          paddedRows->Array.concat(transactionData.breakdown->Array.map(Nullable.make))

        setTransactionRawData(_ => transactionData)
        setTransactionData(_ => paginatedTransactionData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Error(""))
          showToast(
            ~message="Error while fetching transaction data. Please try again",
            ~toastType=ToastError,
          )
        }
      }
    }

    React.useEffect(_ => {
      fetchData()->ignore
      None
    }, [offset, pageDetail.resultsPerPage])

    <div className="py-6">
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
        customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
        <RenderIf condition={transactionData->Array.length == 0}>
          <NoDataFound message="No data available for selected month" />
        </RenderIf>
        <RenderIf condition={transactionData->Array.length > 0}>
          <LoadedTableWithCustomColumns
            title=transactionViewTableKey
            hideTitle=true
            actualData={transactionData}
            entity={FeeEstimationEntity.feeEstimationEntity()}
            resultsPerPage=pageDetail.resultsPerPage
            totalResults=transactionRawData.totalRecords
            offset
            setOffset
            currrentFetchCount={transactionData->Array.length}
            defaultColumns={FeeEstimationEntity.defaultColumns}
            customColumnMapper={TableAtoms.feeEstimationTransactionViewMapDefaultCols}
            showSerialNumberInCustomizeColumns=false
            onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
            showResultsPerPageSelector=true
            sortingBasedOnDisabled=false
            showAutoScroll=true
            isDraggable=true
            allowNullableRows=true
          />
        </RenderIf>
      </PageLoaderWrapper>
      <Modal
        showModal
        modalHeading="Transaction details"
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-540-px !bg-white dark:!bg-jp-gray-lightgray_background">
        <TransactionViewSideModal selectedTransaction />
      </Modal>
    </div>
  }
}

@react.component
let make = () => {
  let formattedDate = date => date->Date.toString->DateTimeUtils.getFormattedDate("YYYY-MM-DD")
  let (monthFilters, setMonthFilters) = React.useState(_ =>
    {
      "startDate": Date.makeWithYMDH(~month=8, ~year=2025, ~date=1, ~hours=10)->formattedDate,
      "endDate": Date.makeWithYMDH(~month=9, ~year=2025, ~date=0, ~hours=10)->formattedDate,
    }
  )
  let tabs: array<Tabs.tab> = [
    {
      title: "Overview",
      renderContent: () => <OverviewContainer monthFilters />,
    },
    {
      title: "Transactions View",
      renderContent: () => <TransactionViewContainer monthFilters />,
    },
  ]

  <>
    <div className="flex justify-between items-center">
      <p className={`${heading.lg.semibold} text-nd_gray-800`}> {"Fee Estimate"->React.string} </p>
      <MonthRangeSelector
        isDisabled=true
        updateDateRange={(~startDate, ~endDate) => {
          setMonthFilters(_ =>
            {
              "startDate": startDate,
              "endDate": endDate,
            }
          )
        }}
        initialStartDate={monthFilters["startDate"]}
        initialEndDate={monthFilters["endDate"]}
      />
    </div>
    <Tabs
      initialIndex=0
      tabs
      disableIndicationArrow=true
      showBorder=true
      includeMargin=false
      lightThemeColor="black"
      defaultClasses={`font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 ${body.lg.semibold} text-body`}
      textStyle="text-nd_primary_blue-450"
      selectTabBottomBorderColor="bg-nd_primary_blue-600"
    />
  </>
}
