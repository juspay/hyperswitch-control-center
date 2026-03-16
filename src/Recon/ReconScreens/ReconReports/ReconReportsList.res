@react.component
let make = () => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (selectedId, setSelectedId) = React.useState(_ =>
    Dict.make()->ReconReportUtils.getAllReportPayloadType
  )
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")
  let statusUI = ReportStatus.useGetAllReportStatus(selectedId)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let fetchApi = AuthHooks.useApiFetcher()
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])

  let getReportsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = `${GlobalVars.getHostUrl}/test-data/recon/reconAllReports.json`
      let allReportsResponse = await fetchApi(
        url,
        ~method_=Get,
        ~xFeatureRoute=false,
        ~forceCookies=false,
      )
      let response = await allReportsResponse->(res => res->Fetch.Response.json)
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])
      let reportsList = data->ReconReportUtils.getArrayOfReportsListPayloadType
      setConfiguredReports(_ => reportsList)
      setFilteredReports(_ => reportsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let modalHeading = {
    <div className="flex justify-between border-b">
      <div className="flex gap-4 items-center m-8">
        <p className="font-semibold text-nd_gray-600 text-lg leading-6">
          {`Transaction ID: ${selectedId.transaction_id}`->React.string}
        </p>
        <div> {statusUI} </div>
      </div>
      <Icon
        name="modal-close-icon"
        className="cursor-pointer mr-4"
        size=30
        onClick={_ => setShowModal(_ => false)}
      />
    </div>
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReportsTypes.allReportPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.transaction_id, searchText) ||
          isContainingStringLowercase(obj.order_id, searchText) ||
          isContainingStringLowercase(obj.recon_status, searchText)
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
    <div className="mt-9">
      <RenderIf condition={configuredReports->Array.length === 0}>
        <div className="my-4">
          <NoDataFound message={"No data available"} renderType={Painting} />
        </div>
      </RenderIf>
      <Modal
        setShowModal
        showModal
        closeOnOutsideClick=true
        modalClass="flex flex-col w-1/3 h-screen float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
        childClass="my-6 mx-2 h-full flex flex-col justify-between"
        customModalHeading=modalHeading>
        <ShowAllReports isModal=true setShowModal selectedId />
      </Modal>
      <div className="flex flex-col mx-auto w-full h-full">
        <RenderIf condition={configuredReports->Array.length > 0}>
          <LoadedTableWithCustomColumns
            title="All Reports"
            actualData={filteredReportsData}
            entity={ReportsTableEntity.reportsEntity(
              `v2/recon/reports`,
              ~authorization=userHasAccess(~groupAccess=UsersManage),
            )}
            resultsPerPage=10
            filters={<TableSearchFilter
              data={configuredReports->Array.map(Nullable.make)}
              filterLogic
              placeholder="Search Transaction Id or Order Id or Recon Status"
              customSearchBarWrapperWidth="w-1/3"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            totalResults={filteredReportsData->Array.length}
            offset
            setOffset
            currentFetchCount={configuredReports->Array.map(Nullable.make)->Array.length}
            customColumnMapper=TableAtoms.reconReportsDefaultCols
            defaultColumns={ReportsTableEntity.defaultColumns}
            showSerialNumberInCustomizeColumns=false
            sortingBasedOnDisabled=false
            hideTitle=true
            remoteSortEnabled=true
            onEntityClick={val => {
              setSelectedId(_ => val)
              setShowModal(_ => true)
            }}
            customizeColumnButtonIcon="nd-filter-horizontal"
            hideRightTitleElement=true
            showAutoScroll=true
          />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
