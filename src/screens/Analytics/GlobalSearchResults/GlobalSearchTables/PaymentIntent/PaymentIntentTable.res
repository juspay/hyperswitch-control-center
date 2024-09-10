module PreviewTable = {
  @react.component
  let make = (~data) => {
    open GlobalSearchTypes
    open PaymentIntentEntity
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let tableData =
      data
      ->Array.map(item => {
        let data = item.texts->Array.get(0)->Option.getOr(Dict.make()->JSON.Encode.object)
        data->JSON.Decode.object->Option.getOr(Dict.make())
      })
      ->Array.filter(dict => dict->Dict.keysToArray->Array.length > 0)
      ->Array.map(item => item->tableItemToObjMapper->Nullable.make)

    open ResultsTableUtils
    <LoadedTable
      visibleColumns
      title=domain
      hideTitle=true
      actualData={tableData}
      entity=tableEntity
      resultsPerPage=10
      totalResults={tableData->Array.length}
      offset={0}
      setOffset={_ => ()}
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
  open PaymentIntentEntity
  let updateDetails = useUpdateMethod()
  let fetchTableData = ResultsTableUtils.useGetData()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let widthClass = "w-full"
  let heightClass = ""
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let setPageDetails = Recoil.useSetRecoilState(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get(domain)->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let searchText = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("query", "")

  let clearPageDetails = () => {
    let newDict = pageDetailDict->Dict.toArray->Dict.fromArray
    newDict->Dict.set(domain, defaultValue)
    setPageDetails(_ => newDict)
  }

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)

    try {
      let (data, total) = await fetchTableData(
        ~updateDetails,
        ~offset,
        ~query={searchText},
        ~path=domain,
      )

      let arr = Array.make(~length=offset, Dict.make())
      if total <= offset {
        setOffset(_ => 0)
      }

      if total > 0 {
        let dataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
        let orderData = arr->Array.concat(dataDictArr)->Array.map(tableItemToObjMapper)
        let list = orderData->Array.map(Nullable.make)

        setTotalCount(_ => total)
        setData(_ => list)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    if searchText->String.length > 0 {
      getData()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }

    Some(
      () => {
        clearPageDetails()
      },
    )
  }, (offset, searchText))

  open ResultsTableUtils

  <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
    <PageUtils.PageHeading title="Payment Intent" />
    <PageLoaderWrapper screenState>
      <LoadedTable
        visibleColumns
        title=domain
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
