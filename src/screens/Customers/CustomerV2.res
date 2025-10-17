@react.component
let make = () => {
  open APIUtils
  open CustomersEntity
  open CustomerUtils
  open HSwitchRemoteFilter
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  let {filterValueJson, updateExistingKeys, reset} = React.useContext(
    FilterContext.filterContext,
  )
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetail = pageDetailDict->Dict.get("customers")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (total, setTotal) = React.useState(_ => 100)
  let limit = 20
  let (lastApiCallParams, setLastApiCallParams) = React.useState(_ => "")
  let (lastFilterState, setLastFilterState) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->JSON.stringify
  )

  let sanitizeSearchInput = searchValue => {
    searchValue
    ->String.trim
    ->String.replaceRegExp(%re("/[^a-zA-Z0-9_-]/g"), "")
  }

  let getCustomersList = async searchValue => {
    try {
      setScreenState(_ => Loading)

      let sanitizedSearchValue = searchValue->sanitizeSearchInput

        let localFilterValue = if sanitizedSearchValue->isNonEmptyString {
          let searchDict = Dict.make()
          searchDict->setOptionString("customer_id", Some(sanitizedSearchValue))
          searchDict
        } else {
        let listDict = Dict.make()
        filterValueJson
        ->Dict.toArray
        ->Array.forEach(((key, value)) => {
          if key !== "customer_id" {
            listDict->Dict.set(key, value)
          }
        })
        listDict->setOptionInt("limit", Some(limit))
        listDict->setOptionInt("offset", Some(offset))
        listDict
      }

      let queryParams =
        localFilterValue
        ->Dict.toArray
        ->Array.map(((key, value)) => {
          let valueStr = switch value->JSON.Classify.classify {
          | String(str) => str
          | Number(num) => num->Float.toString
          | Array(arr) => arr->getStrArrayFromJsonArray->Array.joinWith(",")
          | _ => ""
          }
          `${key}=${valueStr}`
        })
        ->Array.joinWith("&")

      if queryParams === lastApiCallParams {
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setLastApiCallParams(_ => queryParams)

        let customersUrl = getURL(
          ~entityName=V1(CUSTOMERS_COUNT),
          ~methodType=Get,
          ~queryParamerters=Some(queryParams),
        )

        let res = await fetchDetails(customersUrl)

        let jsonObj = res->getDictFromJsonObject
        let data = jsonObj->getArrayFromDict("data", [])
        let totalCount = jsonObj->getInt("total_count", 0)

        let dataLen = data->Array.length
        let searchTotal = sanitizedSearchValue->isNonEmptyString ? dataLen : totalCount
        setTotal(_ => searchTotal)

        if searchTotal > 0 && dataLen > 0 {
          let displayOffset = sanitizedSearchValue->isNonEmptyString ? 0 : offset
          let arr = Array.make(~length=displayOffset, Dict.make())
          let dataArr = data->Belt.Array.keepMap(JSON.Decode.object)

          let customersData =
            arr
            ->Array.concat(dataArr)
            ->Array.map(itemToObjMapper)
            ->Array.map(Nullable.make)

          setCustomersData(_ => customersData)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          setTotal(_ => 0)
          setCustomersData(_ => [])
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let customUI = <NoDataFound message="No results found" renderType={Painting} />

  let filtersUI =
    <Filter
      customLeftView={<SearchBarFilter
        placeholder="Search for Customer ID" setSearchVal=setSearchText searchVal=searchText
      />}
      defaultFilters={""->JSON.Encode.string}
      fixedFilters={initialFixedFilter(version)}
      requiredSearchFieldsList=[]
      localFilters=[]
      localOptions=[]
      remoteOptions=[]
      remoteFilters=[]
      autoApply=false
      submitInputOnEnter=false
      defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
      updateUrlWith=updateExistingKeys
      clearFilters={() => {
        reset()
      }}
      title="Customers"
    />

  React.useEffect(() => {
    let currentFilterState = {
      let filterDict = Dict.make()
      filterValueJson
      ->Dict.toArray
      ->Array.forEach(((key, value)) => {
        if key !== "offset" && key !== "limit" {
          filterDict->Dict.set(key, value)
        }
      })
      filterDict->JSON.Encode.object->JSON.stringify
    }

    if currentFilterState !== lastFilterState && searchText === "" {
      setLastFilterState(_ => currentFilterState)
      if offset !== 0 {
        setOffset(_ => 0)
      } else {
        getCustomersList(searchText)->ignore
      }
    } else {
      getCustomersList(searchText)->ignore
    }
    None
  }, (filterValueJson, offset, searchText))

  <div>
    <PageUtils.PageHeading title="Customers" subTitle="View all customers" />
    <div className="flex-1"> {filtersUI} </div>
    <PageLoaderWrapper screenState customUI>
      <div className="relative">
        <div className="pt-0">
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
            showResultsPerPageSelector=true
            sortingBasedOnDisabled=false
            showAutoScroll=true
            isDraggable=true
          />
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
