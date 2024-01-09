@react.component
let make = () => {
  open APIUtils
  open CustomersEntity
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)

  let getCustomersList = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let customersUrl = getURL(~entityName=CUSTOMERS, ~methodType=Get, ())
      let response = await fetchDetails(customersUrl)
      let data = response->LogicUtils.getArrayDataFromJson(itemToObjMapper)
      setCustomersData(_ => data->Array.map(Js.Nullable.return))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  React.useEffect0(() => {
    getCustomersList()->ignore
    None
  })

  <PageLoaderWrapper screenState>
    <PageUtils.PageHeading title="Customers" subTitle="View all customers" />
    <LoadedTableWithCustomColumns
      title=" "
      hideTitle=true
      actualData=customersData
      entity={customersEntity}
      resultsPerPage=10
      showSerialNumber=true
      totalResults={customersData->Array.length}
      offset
      setOffset
      currrentFetchCount={customersData->Array.length}
      defaultColumns={defaultColumns}
      customColumnMapper={customersMapDefaultCols}
      showSerialNumberInCustomizeColumns=false
      sortingBasedOnDisabled=false
    />
  </PageLoaderWrapper>
}
