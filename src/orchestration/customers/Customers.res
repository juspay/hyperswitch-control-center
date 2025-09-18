@react.component
let make = () => {
  open APIUtils
  open CustomersEntity
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetail = pageDetailDict->Dict.get("customers")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let total = 100 // TODO: take this value from API response [currenctly set to 5 pages]
  let limit = 20 // each api calls will retrun 50 results

  let getCustomersList = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let customersUrl = getURL(
        ~entityName=V1(CUSTOMERS),
        ~methodType=Get,
        ~queryParamerters=Some(`limit=${limit->Int.toString}&offset=${offset->Int.toString}`),
      )

      let response = await fetchDetails(customersUrl)
      let data = response->JSON.Decode.array->Option.getOr([])

      let arr = Array.make(~length=offset, Dict.make())

      if total <= offset {
        setOffset(_ => 0)
      }

      if total > 0 {
        let dataArr = data->Belt.Array.keepMap(JSON.Decode.object)

        let customersData =
          arr
          ->Array.concat(dataArr)
          ->Array.map(itemToObjMapper)
          ->Array.map(Nullable.make)

        setCustomersData(_ => customersData)
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  React.useEffect(() => {
    getCustomersList()->ignore
    None
  }, [offset])

  <PageLoaderWrapper screenState>
    <PageUtils.PageHeading title="Customers" subTitle="View all customers" />
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
  </PageLoaderWrapper>
}
