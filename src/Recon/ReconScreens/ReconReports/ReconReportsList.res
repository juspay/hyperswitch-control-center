@react.component
let make = (~configuredReports, ~filteredReportsData, ~setFilteredReports) => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (selectedId, setSelectedId) = React.useState(_ =>
    Dict.make()->ReconReportUtils.getAllReportPayloadType
  )
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")
  let statusUI = ReportStatus.useGetAllReportStatus(selectedId)

  let modalHeading = {
    <div className="flex justify-between border-b">
      <div className="flex gap-4 items-center my-8">
        <p className="font-semibold text-nd_gray-600 px-8 text-lg leading-6">
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
          obj.recon_status->String.toLowerCase->String.startsWith(searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

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
      modalClass="w-1/3 h-screen float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
      childClass="m-2 h-full"
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
          currrentFetchCount={configuredReports->Array.map(Nullable.make)->Array.length}
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
        />
      </RenderIf>
    </div>
  </div>
}
