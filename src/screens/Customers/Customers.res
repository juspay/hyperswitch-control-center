@react.component
let make = () => {
  open APIUtils
  open CustomersEntity
  open HSwitchRemoteFilter
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetail = pageDetailDict->Dict.get("customers")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (customerId, setcustomerId) = React.useState(_ => "")
  let limit = 100
  let getCustomersList = (~offsetOverride=?) => {
    let actualOffset = offsetOverride->Option.getOr(offset)
    async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let trimmedCustomerId = customerId->String.trim
        let baseParams = `limit=${limit->Int.toString}&offset=${actualOffset->Int.toString}`
        let queryParams = if trimmedCustomerId == "" {
          baseParams
        } else {
          `${baseParams}&customer_id=${trimmedCustomerId}`
        }
        let customersUrl = getURL(
          ~entityName=V1(CUSTOMERS),
          ~methodType=Get,
          ~queryParamerters=Some(queryParams),
        )

        let response = await fetchDetails(customersUrl)
        let data = response->getArrayFromJson([])
        let total = data->Array.length
        let arr = Array.make(~length=actualOffset, Dict.make())

        if total <= actualOffset {
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
          setTotalCount(_ => total)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else if total == 0 {
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let customUI = <NoDataFound message="No results found" renderType={Painting} />

  React.useEffect(() => {
    //On search changes fetch with offset=0
    setOffset(_ => 0)
    getCustomersList(~offsetOverride=0)()->ignore
    None
  }, [customerId->String.trim])

  React.useEffect(() => {
    getCustomersList()->ignore
    None
  }, [offset->Int.toString])

  // Temporary use of SearchBarFilter until customer filter API is available
  let searchComponent = React.useMemo(
    () =>
      <SearchBarFilter
        placeholder="Search by customer Id" setSearchVal=setcustomerId searchVal=customerId
      />,
    [customerId],
  )

  <>
    <PageUtils.PageHeading title="Customers" subTitle="View all customers" />
    <div className="relative">
      <RenderIf condition={totalCount > 0}>
        <div className="absolute top-0 left-0 z-10"> {searchComponent} </div>
      </RenderIf>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Customers"
          hideTitle=true
          actualData=customersData
          entity={customersEntity}
          resultsPerPage=20
          showSerialNumber=true
          totalResults=totalCount
          offset
          setOffset
          currrentFetchCount={customersData->Array.length}
          defaultColumns={defaultColumns}
          customColumnMapper={TableAtoms.customersMapDefaultCols}
          showSerialNumberInCustomizeColumns=true
          showResultsPerPageSelector=false
          sortingBasedOnDisabled=false
          showAutoScroll=true
          isDraggable=true
        />
      </PageLoaderWrapper>
    </div>
  </>
}
