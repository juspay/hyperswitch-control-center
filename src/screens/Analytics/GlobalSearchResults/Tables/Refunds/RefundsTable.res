module PreviewTable = {
  @react.component
  let make = (~tableData) => {
    open RefundsTableEntity
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    open ResultsTableUtils
    <LoadedTable
      visibleColumns
      title=" "
      hideTitle=true
      actualData={tableData}
      entity=tableEntity
      resultsPerPage=10
      totalResults={tableData->Array.length}
      offset
      setOffset
      defaultSort
      currrentFetchCount={tableData->Array.length}
      tableLocalFilter=false
      tableheadingClass=tableBorderClass
      tableBorderClass
      ignoreHeaderBg=true
      tableDataBorderClass=tableBorderClass
      isAnalyticsModule=false
      showResultsPerPageSelector=false
      paginationClass="hidden"
    />
  }
}

@react.component
let make = () => {
  open APIUtils
  open RefundsTableEntity
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let widthClass = "w-full"
  let heightClass = ""
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("refunds")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let searchText = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("query", "")

  React.useEffect2(() => {
    if searchText->String.length > 0 {
      ResultsTableUtils.getData(
        ~updateDetails,
        ~setTableData=setData,
        ~setScreenState,
        ~setOffset,
        ~setTotalCount,
        ~offset,
        ~query={searchText},
        ~path="refunds",
        ~mapper=tableItemToObjMapper,
      )->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }

    None
  }, (offset, searchText))

  open ResultsTableUtils

  <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
    <PageUtils.PageHeading title="Refunds" />
    <PageLoaderWrapper screenState>
      <LoadedTable
        visibleColumns
        title=" "
        hideTitle=true
        actualData=data
        entity=tableEntity
        resultsPerPage=10
        showSerialNumber=true
        totalResults={totalCount}
        offset
        setOffset
        currrentFetchCount={data->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=false
        showResultsPerPageSelector=false
      />
    </PageLoaderWrapper>
  </div>
}
