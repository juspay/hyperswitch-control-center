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
  let (filteredCustomersData, setFilteredCustomersData) = React.useState(_ => [])
  let (searchVal, setSearchVal) = React.useState(_ => "")
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
        setFilteredCustomersData(_ => customersData)
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
  }, (sampleReport, offset))

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<VaultCustomersType.customers>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.id, searchText) ||
          isContainingStringLowercase(obj.name, searchText) ||
          isContainingStringLowercase(obj.phone, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredCustomersData(_ => filteredList)
  }, ~wait=200)

  <PageLoaderWrapper screenState>
    <PageHeading
      title="Customers & Tokens" subTitle="List of customers and their vaulted payment tokens"
    />
    <VaultCustomersTotalDataView />
    <RenderIf condition={customersData->Array.length == 0}>
      {<>
        <TableSearchFilter placeholder="Search any customer ID" searchVal setSearchVal data="" />
        <div className="-mt-7">
          <div className="flex bg-nd_gray-50 h-11 gap-20 border rounded-t-lg overflow-clip ">
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3 w-fit">
              {"S.No"->React.string}
            </p>
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3 w-fit">
              {"Customer Id"->React.string}
            </p>
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3 w-fit">
              {"Customer Name"->React.string}
            </p>
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3">
              {"Email"->React.string}
            </p>
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3">
              {"Phone Country Code"->React.string}
            </p>
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3">
              {"Phone"->React.string}
            </p>
            <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3">
              {"Description"->React.string}
            </p>
          </div>
          <div className="border border-t-0 h-1/2">
            <div className="flex flex-col  items-center gap-4 justify-center h-[65vh]">
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
          </div>
        </div>
      </>}
    </RenderIf>
    <RenderIf condition={customersData->Array.length > 0}>
      <LoadedTable
        title=" "
        hideTitle=true
        actualData=filteredCustomersData
        entity={customersEntity}
        resultsPerPage=10
        showSerialNumber=true
        filters={<TableSearchFilter
          data={customersData}
          filterLogic
          placeholder="Search any customer ID"
          searchVal
          setSearchVal
        />}
        totalResults=total
        offset
        setOffset
        currrentFetchCount={customersData->Array.length}
        showResultsPerPageSelector=false
        showAutoScroll=true
      />
    </RenderIf>
  </PageLoaderWrapper>
}
