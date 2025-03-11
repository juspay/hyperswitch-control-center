@react.component
let make = (~sampleReport, ~setSampleReport) => {
  open PageUtils
  open APIUtils
  open VaultCustomersEntity

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetail = pageDetailDict->Dict.get("customers")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let total = 100 // TODO: take this value from API response [currenctly set to 5 pages]
  let limit = 10 // each api calls will return 50 results
  
  let handleSampleReportButtonClick = () => {
    setSampleReport(_ => true)
  }
  let getCustomersList = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let customersUrl = getURL(
        ~entityName=V2(CUSTOMERS),
        ~methodType=Get,
        ~queryParamerters=Some(`limit=${limit->Int.toString}&offset=${offset->Int.toString}`),
      )

      let response = sampleReport ? VaultSampleData.customersList : await fetchDetails(customersUrl)

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

  React.useEffect(() => {
    getCustomersList()->ignore
    None
  }, [sampleReport])

  <PageLoaderWrapper screenState>
    <PageHeading
      title="Customers & Tokens" subTitle="List of customers and their vaulted payment tokens"
    />
    <RenderIf condition={customersData->Array.length == 0}>
      <div className="flex flex-col  items-center gap-4 justify-center h-[75vh]">
        <div className="flex flex-col items-center">
          <p className=" text-nd_gray-700 font-semibold text-lg">
            {"No Data Available"->React.string}
          </p>
          <p className="font-medium text-nd_gray-500">
            {"You can generate sample data to gain a better understanding of the product."->React.string}
          </p>
        </div>
        <Button
          text="Generate Sample Data"
          onClick={_ => handleSampleReportButtonClick()}
          buttonType={Primary}
        />
      </div>
    </RenderIf>
    <RenderIf condition={customersData->Array.length > 0}>
      <LoadedTableWithCustomColumns
        title=" "
        hideTitle=true
        actualData=customersData
        entity={customersEntity}
        resultsPerPage=10
        showSerialNumber=true
        totalResults=total
        offset
        setOffset
        currrentFetchCount={customersData->Array.length}
        defaultColumns={defaultColumns}
        customColumnMapper={vaultCustomersMapDefaultCols}
        showSerialNumberInCustomizeColumns=false
        showResultsPerPageSelector=false
        sortingBasedOnDisabled=false
        showAutoScroll=true
      />
    </RenderIf>
  </PageLoaderWrapper>
}
