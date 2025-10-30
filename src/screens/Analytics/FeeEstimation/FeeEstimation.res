open FeeEstimationTypes
open FeeEstimationOverview
open FeeEstimationTransactionView
open FeeEstimationHelper

module OverviewContainer = {
  @react.component
  let make = () => {
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
    let {userInfo: {merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)

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
          },
          "merchant_id": merchantId,
          "profile_id": profileId,
        }->Identity.genericTypeToJson

        let response = switch GlobalVars.hostType {
        | Local | Integ => FeeEstimationMockData.overViewMockData
        | _ => await updateDetails(url, body, Fetch.Post)
        }

        let overViewData =
          response
          ->Identity.genericTypeToJson
          ->LogicUtils.getDictFromJsonObject
          ->LogicUtils.getDictfromDict("response")
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
    }, [pageDetail.offset, pageDetail.resultsPerPage])

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
      customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
      {<>
        <TotalCostIncurred totalIncurredCost={overviewRawData} />
        <FeeBreakdownBasedOnGeoLocation
          feeBreakdownData=overviewRawData.feeBreakdownBasedOnGeoLocation
          currency=overviewRawData.currency
        />
        <CostBreakDown costBreakDownRawData={overviewRawData} />
      </>}
    </PageLoaderWrapper>
  }
}

module TransactionViewContainer = {
  @react.component
  let make = () => {
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
    let {userInfo: {merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (offset, setOffset) = React.useState(_ => 0)
    let (showModal, setShowModal) = React.useState(_ => false)
    let (selectedTransaction, setSelectedTransaction) = React.useState(_ =>
      JSON.Encode.object(Dict.make())->FeeEstimationUtils.feeEstimateBreakdownMapper
    )
    let (transactionData, setTransactionData) = React.useState(_ =>
      Dict.make()->FeeEstimationUtils.feeEstimationMapper
    )

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
            "offset": pageDetail.offset,
            "limit": pageDetail.resultsPerPage,
          },
          "merchant_id": merchantId,
          "profile_id": profileId,
        }->Identity.genericTypeToJson
        let response = switch GlobalVars.hostType {
        | Local | Integ => FeeEstimationMockData.mockData
        | _ => await updateDetails(url, body, Fetch.Post)
        }

        let transactionData =
          response
          ->Identity.genericTypeToJson
          ->LogicUtils.getDictFromJsonObject
          ->LogicUtils.getDictfromDict("response")
          ->FeeEstimationUtils.feeEstimationMapper
        setTransactionData(_ => transactionData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }

    React.useEffect(_ => {
      fetchData()->ignore
      None
    }, [pageDetail.offset, pageDetail.resultsPerPage])

    <div className="py-6">
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-56" message="No data available" />}
        customLoader={<Shimmer styleClass="w-full h-56 rounded-xl" />}>
        {switch transactionData.breakdown->Array.length {
        | 0 => <NoDataFound message="No data available for selected month" />
        | _ =>
          <LoadedTable
            title=transactionViewTableKey
            hideTitle=true
            actualData={transactionData.breakdown->Array.map(Nullable.make)}
            totalResults={transactionData.totalRecords}
            resultsPerPage=10
            offset
            setOffset
            headingCenter=false
            alignCellContent="flex items-center"
            entity={FeeEstimationEntity.feeEstimationEntity()}
            currrentFetchCount={transactionData.breakdown->Array.length}
            onEntityClick={selectedData => handleSelectedTransactionData(selectedData)}
            collapseTableRow=false
            showAutoScroll=true
          />
        }}
      </PageLoaderWrapper>
      <Modal
        showModal
        modalHeading={"Transaction details"}
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-full max-w-[539px] !bg-white dark:!bg-jp-gray-lightgray_background">
        <TransactionViewSideModal selectedTransaction />
      </Modal>
    </div>
  }
}

@react.component
let make = () => {
  let (monthFilters, setMonthFilters) = React.useState(_ => {
    "startDate": "2025-10-01",
    "endDate": "2025-10-31",
  })
  let tabs: array<Tabs.tab> = [
    {
      title: "Overview",
      renderContent: () => <OverviewContainer />,
    },
    {
      title: "Transactions View",
      renderContent: () => <TransactionViewContainer />,
    },
  ]

  <div>
    <div className="flex justify-between items-center">
      <p className="text-2xl font-semibold text-nd_gray-800"> {"Fee Estimate"->React.string} </p>
      <FeeEstimationHelper.MonthRangeSelector
        isDisabled=true
        updateDateRange={(~startDate, ~endDate) => {
          setMonthFilters(_ => {
            "startDate": startDate,
            "endDate": endDate,
          })
        }}
        initialStartDate={monthFilters["startDate"]}
        initialEndDate={monthFilters["endDate"]}
      />
    </div>
    <Tabs
      initialIndex={0}
      tabs
      disableIndicationArrow=true
      showBorder=true
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      textStyle="text-blue-600"
      selectTabBottomBorderColor="bg-blue-600"
    />
  </div>
}
