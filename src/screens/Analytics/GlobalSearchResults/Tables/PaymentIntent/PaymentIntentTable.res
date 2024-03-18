let setData = (offset, setOffset, total, data, setTotalCount, setTableData, setScreenState) => {
  let arr = Array.make(~length=offset, Dict.make())
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let dataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)

    let orderData =
      arr->Array.concat(dataDictArr)->Array.map(PaymentIntentEntity.tableItemToObjMapper)

    let list = orderData->Array.map(Nullable.make)
    setTotalCount(_ => total)
    setTableData(_ => list)
    setScreenState(_ => PageLoaderWrapper.Success)
  } else {
    setScreenState(_ => PageLoaderWrapper.Custom)
  }
}

let getData = async (
  ~updateDetails: (
    string,
    JSON.t,
    Fetch.requestMethod,
    ~bodyFormData: Fetch.formData=?,
    ~headers: Dict.t<'a>=?,
    ~contentType: AuthHooks.contentType=?,
    unit,
  ) => promise<JSON.t>,
  ~setTableData,
  ~setScreenState,
  ~setOffset,
  ~setTotalCount,
  ~offset,
  ~query,
) => {
  open LogicUtils
  setScreenState(_ => PageLoaderWrapper.Loading)
  let filters = Dict.make()
  filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
  filters->Dict.set("count", 10->Int.toFloat->JSON.Encode.float)
  filters->Dict.set("query", query->JSON.Encode.string)

  try {
    let url = "https://sandbox.hyperswitch.io/analytics/v1/search/payment_intents"
    let res = await updateDetails(url, filters->JSON.Encode.object, Fetch.Post, ())
    let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("hits", [])
    let total = res->getDictFromJsonObject->getInt("count", 0)

    setData(offset, setOffset, total, data, setTotalCount, setTableData, setScreenState)
  } catch {
  | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
  }
}

module PreviewTable = {
  @react.component
  let make = (~tableData) => {
    open PaymentIntentEntity
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
  open PaymentIntentEntity
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
      getData(
        ~updateDetails,
        ~setTableData=setData,
        ~setScreenState,
        ~setOffset,
        ~setTotalCount,
        ~offset,
        ~query={searchText},
      )->ignore
    }

    None
  }, (offset, searchText))

  let customTitleStyle = ""

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <PageUtils.PageHeading title="Payment Intent" customTitleStyle />
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
