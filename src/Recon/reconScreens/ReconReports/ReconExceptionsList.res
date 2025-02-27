@react.component
let make = () => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let getReportsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      //   let response = await fetchReportListResponse(~startDate, ~endDate)
      let response = {
        "data": [
          {
            "transaction_id": "1234",
            "order_id": "Ord_5678",
            "payment_gateway": "Stripe",
            "payment_method": "Credit Card",
            "txn_amount": 324.0,
            "mismatch_amount": 93.0,
            "exception_status": "Under Review",
            "exception_type": "Status Mismatch",
            "last_updated": "Jan 22, 2025 03:25PM",
            "actions": "View",
          },
        ],
      }->Identity.genericTypeToJson
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])

      let reportsList = data->ReportsExceptionTableEntity.getArrayOfReportsListPayloadType

      setConfiguredReports(_ => reportsList)
      setFilteredReports(_ => reportsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getReportsList()->ignore
    None
  }, [])

  <>
    <RenderIf condition={screenState == Success && configuredReports->Array.length === 0}>
      <div className="my-4">
        <NoDataFound message={"No data available"} renderType={Painting} />
      </div>
    </RenderIf>
    <LoadedTableWithCustomColumns
      title="All Recon Reports"
      actualData={configuredReports->Array.map(Nullable.make)}
      entity={ReportsExceptionTableEntity.reportsEntity(
        `v2/recon/reports`,
        ~authorization=userHasAccess(~groupAccess=UsersManage),
      )}
      resultsPerPage=10
      showSerialNumber=false
      totalResults={filteredReportsData->Array.length}
      offset
      setOffset
      currrentFetchCount={filteredReportsData->Array.length}
      customColumnMapper=TableAtoms.reconExceptionReportsDefaultCols
      defaultColumns={ReportsExceptionTableEntity.defaultColumns}
      showSerialNumberInCustomizeColumns=false
      sortingBasedOnDisabled=false
      hideTitle=true
      remoteSortEnabled=true
      showAutoScroll=true
    />
  </>
}
