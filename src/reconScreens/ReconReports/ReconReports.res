@react.component
let make = () => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let fetchReportListResponse = ReportsData.useFetchReportsList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReportsTypes.reportPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.payment_entity_txn_id, searchText) ||
          isContainingStringLowercase(obj.txn_type, searchText) ||
          isContainingStringLowercase(obj.recon_status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

  let getReportsList = async _ => {
    try {
      let response = await fetchReportListResponse()
      let data = response->getDictFromJsonObject->Dict.get("data")->Option.getOr(Js.Json.array([]))
      let reportsList = data->ReportsListMapper.getArrayOfReportsListPayloadType
      setConfiguredReports(_ => reportsList)
      setFilteredReports(_ => reportsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => reportsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getReportsList()->ignore
    None
  }, [])

  <div>
    <PageUtils.PageHeading
      title={"Reconciliation Reports"} subTitle={"View all the reconciliation reports here"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <RenderIf condition={configuredReports->Array.length > 0}>
          <LoadedTable
            title="Search Reports"
            actualData=filteredReportsData
            totalResults={filteredReportsData->Array.length}
            resultsPerPage=10
            entity={ReportsTableEntity.reportsEntity(
              `v2/recon/reports`,
              ~authorization=userHasAccess(~groupAccess=UsersManage),
            )}
            filters={<TableSearchFilter
              data={previouslyConnectedData}
              filterLogic
              placeholder="Search Payment Entity Txn Id, Txn Type, Recon Status"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              customInputBoxWidth="w-full"
              searchVal={searchText}
              setSearchVal={setSearchText}
            />}
            offset
            setOffset
            currrentFetchCount={configuredReports->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
