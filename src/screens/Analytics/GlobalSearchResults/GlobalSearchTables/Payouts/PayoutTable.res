open LogicUtils
module PreviewTable = {
  open PayoutTableEntity
  open GlobalSearchTypes
  open ResultsTableUtils

  @react.component
  let make = (~data) => {
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let tableData =
      data
      ->Array.map(item => {
        let data = item.texts->getValueFromArray(0, Dict.make()->JSON.Encode.object)
        data->JSON.Decode.object->Option.getOr(Dict.make())
      })
      ->Array.filter(dict => dict->Dict.keysToArray->Array.length > 0)
      ->Array.map(item => item->tableItemToObjMapper->Nullable.make)

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
  open PayoutTableEntity
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let fetchTableData = ResultsTableUtils.useGetData()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => [])
  let (rawData, setRawData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let widthClass = "w-full"
  let heightClass = ""
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 50}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let setPageDetails = Recoil.useSetRecoilState(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get(domain)->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let searchText = UrlUtils.useGetFilterDictFromUrl("")->getString("query", "")
  let path = UrlUtils.useGetFilterDictFromUrl("")->getString("source", "")

  let clearPageDetails = () => {
    let newDict = pageDetailDict->Dict.toArray->Dict.fromArray
    newDict->Dict.set(domain, defaultValue)
    setPageDetails(_ => newDict)
  }

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)

    try {
      let (data, total) = await fetchTableData(~updateDetails, ~offset, ~query={searchText}, ~path)

      let arr = Array.make(~length=offset, Dict.make())
      if data->Array.length == 0 && total <= offset {
        setOffset(_ => 0)
      }

      if total > 0 {
        let dataDictArr = data->Array.map(item => item->getDictFromJsonObject)
        let orderData = arr->Array.concat(dataDictArr)->Array.map(tableItemToObjMapper)
        let list = orderData->Array.map(Nullable.make)

        setTotalCount(_ => total)
        setData(_ => list)
        setRawData(_ => data)
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

  let downloadData = () => {
    try {
      let csvHeadersKeys = csvHeaders->Array.map(item => {
        let (key, _) = item
        key
      })
      let csvCustomHeaders = csvHeaders->Array.map(item => {
        let (_, title) = item
        title
      })

      let data = rawData->Array.map(item => {
        item->getDictFromJsonObject->tableItemToObjMapper->itemToCSVMapping
      })

      let csvContent =
        data->DownloadUtils.convertArrayToCSVWithCustomHeaders(csvHeadersKeys, csvCustomHeaders)
      DownloadUtils.download(
        ~fileName=`payouts_${searchText}.csv`,
        ~content=csvContent,
        ~fileType="text/csv",
      )
    } catch {
    | _ => showToast(~message="Failed to download CSV", ~toastType=ToastError)
    }
  }

  open ResultsTableUtils
  <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
    <div className="flex justify-between items-center mb-4">
      <PageUtils.PageHeading title="Payouts" />
      <Button
        text={`Export current page (${rawData->Array.length->Int.toString} records)`}
        buttonType={Primary}
        leftIcon={Button.CustomIcon(<Icon name="nd-download-bar-down" size=16 />)}
        onClick={_ => downloadData()}
        buttonSize={Small}
      />
    </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        visibleColumns
        title=domain
        hideTitle=true
        actualData=data
        entity=tableEntity
        resultsPerPage=50
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
