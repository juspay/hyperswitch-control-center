@react.component
let make = () => {
  open APIUtils
  open CustomersEntity
  open HSwitchRemoteFilter
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetail = pageDetailDict->Dict.get("customers")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (totalCount, setTotalCount) = React.useState(_ => 100)
  let (customerId, setcustomerId) = React.useState(_ => "")
  let limit = 50

  let getCustomersList = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let customersUrl = getURL(
        ~entityName=V1(CUSTOMERS),
        ~methodType=Get,
        ~queryParamerters=Some(
          `limit=${limit->Int.toString}&offset=${offset->Int.toString}&customer_id=${customerId->String.trim}`,
        ),
      )

      let response = await fetchDetails(customersUrl)
      let data = response->JSON.Decode.array->Option.getOr([])

      let arr = Array.make(~length=offset, Dict.make())

      if totalCount <= offset {
        setOffset(_ => 0)
      }

      if totalCount > 0 {
        let dataArr = data->Belt.Array.keepMap(JSON.Decode.object)

        let customersData =
          arr
          ->Array.concat(dataArr)
          ->Array.map(itemToObjMapper)
          ->Array.map(Nullable.make)

        setCustomersData(_ => customersData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else if totalCount == 0 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let customUI = <NoDataFound customCssClass="my-6" message="No results found" />

  React.useEffect(() => {
    getCustomersList()->ignore
    None
  }, [offset->Int.toString, customerId->String.trim])

  let searchComponent = React.useMemo(
    () =>
      <SearchBarFilter
        placeholder="Search by customer Id" setSearchVal=setcustomerId searchVal=customerId
      />,
    [customerId],
  )

  <>
    <PageUtils.PageHeading title="Customers" subTitle="View all customers" />
    {searchComponent}
    <PageLoaderWrapper screenState customUI>
      <LoadedTableWithCustomColumns
        title="Customers"
        hideTitle=true
        actualData=customersData
        entity={customersEntity}
        resultsPerPage=10
        showSerialNumber=true
        totalResults=totalCount
        offset
        setOffset
        currrentFetchCount={customersData->Array.length}
        defaultColumns={defaultColumns}
        customColumnMapper={TableAtoms.customersMapDefaultCols}
        showSerialNumberInCustomizeColumns=true
        showResultsPerPageSelector=true
        sortingBasedOnDisabled=false
        showAutoScroll=true
        isDraggable=true
      />
    </PageLoaderWrapper>
  </>
}
