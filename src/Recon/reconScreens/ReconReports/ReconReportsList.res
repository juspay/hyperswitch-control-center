@react.component
let make = (~configuredReports, ~filteredReportsData, ~setFilteredReports) => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (selectedId, setSelectedId) = React.useState(_ =>
    Dict.make()->ReportsTableEntity.getAllReportPayloadType
  )
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")

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

  <div className="mt-8">
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
      childClass="p-2 m-2 h-full"
      modalHeading={`${selectedId.transaction_id}`}>
      <ShowAllReports isModal=true setShowModal />
    </Modal>
    <div className="flex flex-col mx-auto w-full h-full mt-5  ">
      <RenderIf condition={configuredReports->Array.length > 0}>
        <LoadedTableWithCustomColumns
          title="All Reports"
          actualData={filteredReportsData}
          entity={ReportsTableEntity.reportsEntity(
            `v2/recon/reports`,
            ~authorization=userHasAccess(~groupAccess=UsersManage),
          )}
          filters={<TableSearchFilter
            data={configuredReports->Array.map(Nullable.make)}
            filterLogic
            placeholder="Search Transaction Id or Order Id or Status"
            customSearchBarWrapperWidth="w-full lg:w-1/2"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          resultsPerPage=20
          showSerialNumber=true
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
          showAutoScroll=true
          onEntityClick={val => {
            setSelectedId(_ => val)
            setShowModal(_ => true)
          }}
        />
      </RenderIf>
    </div>
  </div>
}
