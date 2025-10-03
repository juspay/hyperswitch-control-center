@react.component
let make = () => {
  open APIUtils
  open CustomersEntity
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")

  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetail = pageDetailDict->Dict.get("customers")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (total, setTotal) = React.useState(_ => 100)
  let limit = 20 // each api calls will retrun 50 results

  let getCustomersList = async searchValue => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let baseParam = `limit=${limit->Int.toString}&offset=${offset->Int.toString}`
      let queryParams = if searchValue->LogicUtils.isNonEmptyString {
        `${baseParam}&customer_id=${searchValue}`
      } else {
        baseParam
      }

      let customersUrl = getURL(
        ~entityName=V1(CUSTOMERS),
        ~methodType=Get,
        ~queryParamerters=Some(queryParams),
      )

      let response = await fetchDetails(customersUrl)
      let data = response->JSON.Decode.array->Option.getOr([])

      let arr = Array.make(~length=offset, Dict.make())
      let dataLen = data->Array.length
      let searchTotal = searchValue->LogicUtils.isNonEmptyString ? dataLen : 100
      setTotal(_ => searchTotal)

      if searchTotal <= offset && offset > 0 {
        let newOffset = offset - limit
        let safeOffset = if newOffset > 0 {
          newOffset
        } else {
          0
        }
        setOffset(_ => safeOffset)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else if searchTotal > 0 && dataLen > 0 {
        let dataArr = data->Belt.Array.keepMap(JSON.Decode.object)

        let customersData =
          arr
          ->Array.concat(dataArr)
          ->Array.map(itemToObjMapper)
          ->Array.map(Nullable.make)

        setCustomersData(_ => customersData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else if dataLen == 0 {
        if searchValue->LogicUtils.isNonEmptyString {
          setScreenState(_ => PageLoaderWrapper.Success)
        } else if offset == 0 {
          setScreenState(_ => PageLoaderWrapper.Custom)
        } else {
          setScreenState(_ => PageLoaderWrapper.Success)
        }
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  let customUI = <NoDataFound message="No results found" renderType={Painting} />

  let handleSearch = (searchValue: string) => {
    setSearchText(_ => searchValue)
    setOffset(_ => 0) // Reset offset when searching
    if searchValue->LogicUtils.isEmptyString {
      getCustomersList("")->ignore
    }
  }

  let handleKeyDown = e => {
    let keyPressed = e->ReactEvent.Keyboard.key
    if keyPressed == "Enter" {
      getCustomersList(searchText)->ignore
    }
  }

  React.useEffect(() => {
    getCustomersList(searchText)->ignore
    None
  }, [offset])

  <PageLoaderWrapper screenState customUI>
    <PageUtils.PageHeading title="Customers" subTitle="View all customers" />
    <div className="relative">
      <div className="absolute top-10 left-0">
        //temporary fix for search input offset
        <SearchInput
          onChange=handleSearch
          inputText=searchText
          placeholder="Search by Customer ID"
          onKeyDown=handleKeyDown
          widthClass="w-80"
          autoFocus=false
        />
      </div>
      <div className="pt-16">
        <LoadedTableWithCustomColumns
          title="Customers"
          hideTitle=true
          actualData=customersData
          entity={customersEntity}
          resultsPerPage=20
          showSerialNumber=true
          totalResults=total
          offset
          setOffset
          currrentFetchCount={customersData->Array.length}
          defaultColumns={defaultColumns}
          customColumnMapper={TableAtoms.customersMapDefaultCols}
          showSerialNumberInCustomizeColumns=false
          showResultsPerPageSelector=false
          sortingBasedOnDisabled=false
          showAutoScroll=true
          isDraggable=true
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
