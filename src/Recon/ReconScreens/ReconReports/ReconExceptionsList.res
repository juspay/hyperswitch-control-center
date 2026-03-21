@react.component
let make = () => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchText, setSearchText) = React.useState(_ => "")
  let fetchApi = AuthHooks.useApiFetcher()

  let getReportsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = `${GlobalVars.getHostUrl}/test-data/recon/reconExceptions.json`
      let exceptionsResponse = await fetchApi(
        url,
        ~method_=Get,
        ~xFeatureRoute=false,
        ~forceCookies=false,
      )
      let response = await exceptionsResponse->(res => res->Fetch.Response.json)
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])

      let reportsList = data->ReconExceptionsUtils.getArrayOfReportsListPayloadType

      setConfiguredReports(_ => reportsList)
      setFilteredReports(_ => reportsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReportsTypes.reportExceptionsPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.transaction_id, searchText) ||
          isContainingStringLowercase(obj.order_id, searchText) ||
          isContainingStringLowercase(obj.exception_type, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

  React.useEffect(() => {
    getReportsList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="mt-8">
      <RenderIf condition={configuredReports->Array.length === 0}>
        <div className="my-4">
          <NoDataFound message={"No data available"} renderType={Painting} />
        </div>
      </RenderIf>
      <div className="flex flex-col mx-auto w-full h-full mt-5 ">
        <RenderIf condition={configuredReports->Array.length > 0}>
          <LoadedTableWithCustomColumns
            title="Exception Reports"
            actualData={filteredReportsData}
            entity={ReportsExceptionTableEntity.exceptionReportsEntity(
              `v2/recon/reports`,
              ~authorization=userHasAccess(~groupAccess=UsersManage),
            )}
            resultsPerPage=10
            filters={<TableSearchFilter
              data={configuredReports->Array.map(Nullable.make)}
              filterLogic
              placeholder="Search Transaction Id or Order Id or Exception Type"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            showSerialNumber=false
            totalResults={filteredReportsData->Array.length}
            offset
            setOffset
            currentFetchCount={configuredReports->Array.length}
            customColumnMapper=TableAtoms.reconExceptionReportsDefaultCols
            defaultColumns={ReportsExceptionTableEntity.defaultColumns}
            showSerialNumberInCustomizeColumns=false
            sortingBasedOnDisabled=false
            hideTitle=true
            remoteSortEnabled=true
            customizeColumnButtonIcon="nd-filter-horizontal"
            hideRightTitleElement=true
            showAutoScroll=true
          />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
