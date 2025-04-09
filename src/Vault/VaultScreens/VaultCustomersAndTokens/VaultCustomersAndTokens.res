module NoDataFoundComponent = {
  @react.component
  let make = (
    ~setSampleReport,
    ~setCustomersData,
    ~setFilteredCustomersData,
    ~offset,
    ~setOffset,
    ~total,
    ~fieldArray,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let handleSampleReportButtonClick = () => {
      mixpanelEvent(~eventName="vault_get_sample_data")
      let response = VaultSampleData.customersList
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
          ->Array.map(VaultCustomersEntity.itemToObjMapper)
          ->Array.map(Nullable.make)

        setCustomersData(_ => customersData)
        setFilteredCustomersData(_ => customersData)
        setSampleReport(_ => true)
      }
    }

    <div className="mt-7">
      <div
        className="flex bg-nd_gray-50 h-11 gap-72-px border rounded-t-lg overflow-x-auto whitespace-nowrap">
        {fieldArray
        ->Array.map(item =>
          <p className="pl-6 font-medium text-fs-13 text-nd_gray-400 p-3">
            {`${item->VaultCustomersEntity.colToStringMapper}`->React.string}
          </p>
        )
        ->React.array}
      </div>
      <div className="border border-t-0 h-1/2">
        <div className="flex flex-col  items-center gap-4 justify-center h-[55vh]">
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
  }
}
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
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let getCustomersList = async () => {
    try {
      let customersUrl = getURL(
        ~entityName=V2(CUSTOMERS),
        ~methodType=Get,
        ~queryParamerters=Some(`limit=${limit->Int.toString}&offset=${offset->Int.toString}`),
      )
      let response = await fetchDetails(customersUrl, ~version=V2)
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
    setSampleReport(_ => false)
    None
  }, [offset])

  let fieldArray: array<VaultCustomersType.customersColsType> = [
    CustomerId,
    Name,
    Email,
    Phone,
    PhoneCountryCode,
    Address,
    CreatedAt,
  ]
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

  let callMixpanel = eventName => {
    mixpanelEvent(~eventName)
  }
  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-5">
      <PageHeading title="Customers & Tokens" />
      <div className="-mt-2">
        <VaultCustomersTotalDataView sampleReport custCount={customersData->Array.length} />
      </div>
      <RenderIf condition={customersData->Array.length == 0}>
        <NoDataFoundComponent
          setSampleReport
          setCustomersData
          setFilteredCustomersData
          offset
          setOffset
          total
          fieldArray
        />
      </RenderIf>
      <RenderIf condition={customersData->Array.length > 0}>
        <div className="flex flex-col gap-1">
          <p className="text-xl font-semibold"> {"Customer Details"->React.string} </p>
          <p className="text-base text-nd_gray-400">
            {"Click on a customer entry to view their details and vaulted payment methods."->React.string}
          </p>
        </div>
        <LoadedTable
          title=" "
          hideTitle=true
          actualData=filteredCustomersData
          entity={customersEntity(callMixpanel)}
          resultsPerPage=20
          filters={<TableSearchFilter
            data={customersData}
            filterLogic
            placeholder="Search any customer ID"
            searchVal
            setSearchVal
          />}
          totalResults={filteredCustomersData->Array.length}
          offset
          setOffset
          currrentFetchCount={filteredCustomersData->Array.length}
          showResultsPerPageSelector=false
          showAutoScroll=true
          collapseTableRow=false
        />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
