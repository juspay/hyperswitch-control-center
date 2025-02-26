@react.component
let make = () => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (selectedId, setSelectedId) = React.useState(_ =>
    Dict.make()->ReportsTableEntity.getAllReportPayloadType
  )
  let (showModal, setShowModal) = React.useState(_ => false)

  let getReportsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      // let response = await fetchReportListResponse(~startDate, ~endDate)
      let response = {
        "data": [
          {
            "transaction_id": "Txn_1234",
            "order_id": "Ord_5678",
            "payment_gateway": "Stripe",
            "payment_method": "Credit Card",
            "txn_amount": 324.0,
            "settlement_amount": 324.0,
            "recon_status": "Reconciled",
            "transaction_date": "Jan 22, 2025 03:25PM",
            "actions": "",
          },
        ],
      }->Identity.genericTypeToJson
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])
      let reportsList = data->ReportsTableEntity.getArrayOfReportsListPayloadType
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

  <div className="mt-8">
    <RenderIf condition={screenState == Success && configuredReports->Array.length === 0}>
      <div className="my-4">
        <NoDataFound message={"No data available"} renderType={Painting} />
      </div>
    </RenderIf>
    <Modal
      setShowModal
      showModal
      closeOnOutsideClick=true
      modalClass="w-1/3 h-screen float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
      childClass="p-2 m-2 h-full"
      modalHeading={`${selectedId.transaction_id}`}>
      <ShowAllReports isModal=true setShowModal />
    </Modal>
    <div className="flex flex-col mx-auto w-full h-full mt-5  ">
      <PageLoaderWrapper screenState>
        <div className="-mt-12">
          <LoadedTableWithCustomColumns
            title="All Recon Reports"
            actualData={configuredReports->Array.map(Nullable.make)}
            entity={ReportsTableEntity.reportsEntity(
              `v2/recon/reports`,
              ~authorization=userHasAccess(~groupAccess=UsersManage),
            )}
            resultsPerPage=20
            showSerialNumber=false
            totalResults={filteredReportsData->Array.length}
            offset
            setOffset
            currrentFetchCount={filteredReportsData->Array.length}
            customColumnMapper=TableAtoms.reconReportsDefaultCols
            defaultColumns={ReportsTableEntity.defaultColumns}
            showSerialNumberInCustomizeColumns=false
            sortingBasedOnDisabled=false
            hideTitle=true
            remoteSortEnabled=true
            showAutoScroll=true
            onEntityClick={val => {
              setSelectedId(_ => val)
              setShowModal(_ => true)
            }}
          />
        </div>
      </PageLoaderWrapper>
    </div>
  </div>
}
