module PreviewTable = {
  open PaymentAttemptEntity
  open ResultsTableUtils
  @react.component
  let make = (~tableData) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

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
  open LogicUtils
  open PaymentAttemptEntity
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let widthClass = "w-full"
  let heightClass = ""
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)

  React.useEffect0(() => {
    switch GlobalSearchBarUtils.sessionStorage.getItem(. "results")->Nullable.toOption {
    | Some(value) => {
        let valueDict = value->JSON.parseExn->JSON.Decode.object->Option.getOr(Dict.make())
        let searchText = valueDict->getString("searchText", "")
        setSearchText(_ => searchText)
      }
    | None => ()
    }

    None
  })

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
        ~path="payment_attempts",
        ~mapper=tableItemToObjMapper,
      )->ignore
    }

    None
  }, (offset, searchText))

  open ResultsTableUtils
  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <PageUtils.PageHeading title="Payment Attempt" />
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
  </ErrorBoundary>
}
