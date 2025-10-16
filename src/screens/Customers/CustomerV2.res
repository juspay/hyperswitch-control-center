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
  let {filterValueJson, filterValue, updateExistingKeys} = React.useContext(
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
        searchDict->Dict.set("customer_id", sanitizedSearchValue->JSON.Encode.string)
        searchDict
      } else {
        let listDict = Dict.make()
        filterValueJson
        ->Dict.toArray
        ->Array.forEach(((key, value)) => {
          listDict->Dict.set(key, value)
        })
        listDict->Dict.delete("customer_id")
        listDict->Dict.set("limit", limit->Int.toFloat->JSON.Encode.float)
        listDict->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        listDict
      }

      let queryParams =
        localFilterValue
        ->Dict.toArray
        ->Array.map(item => {
          let (key, value) = item
          let value = switch value->JSON.Classify.classify {
          | String(str) => str
          | Number(num) => num->Float.toString
          | Array(arr) => {
              let valueString = arr->getStrArrayFromJsonArray->Array.joinWith(",")
              valueString
            }
          | _ => ""
          }
          `${key}=${value}`
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

        switch res->JSON.Classify.classify {
        | Object(_) => {
            let jsonObj = res->getDictFromJsonObject
            let data =
              jsonObj
              ->Dict.get("data")
              ->Option.flatMap(JSON.Decode.array)
              ->Option.getOr([])

            let totalCount =
              jsonObj
              ->Dict.get("total_count")
              ->Option.flatMap(JSON.Decode.float)
              ->Option.getOr(0.0)
              ->Float.toInt

            let dataLen = data->Array.length
            let searchTotal =
              sanitizedSearchValue->LogicUtils.isNonEmptyString ? dataLen : totalCount
            setTotal(_ => searchTotal)

            if searchTotal > 0 && dataLen > 0 {
              let dataArr = data->Belt.Array.keepMap(JSON.Decode.object)

              let displayOffset = if sanitizedSearchValue->isNonEmptyString {
                0
              } else {
                offset
              }
              let arr = Array.make(~length=displayOffset, Dict.make())

              let customersData =
                arr
                ->Array.concat(dataArr)
                ->Array.map(itemToObjMapper)
                ->Array.map(Nullable.make)

              setCustomersData(_ => customersData)
              setScreenState(_ => PageLoaderWrapper.Success)
            } else if dataLen == 0 {
              setScreenState(_ => PageLoaderWrapper.Custom)
            } else if searchTotal <= offset && offset > 0 {
              let newOffset = offset - limit
              let safeOffset = if newOffset > 0 {
                newOffset
              } else {
                0
              }
              setOffset(_ => safeOffset)
              setScreenState(_ => PageLoaderWrapper.Success)
            }
          }
        | _ => if sanitizedSearchValue->isNonEmptyString {
            setTotal(_ => 0)
            setCustomersData(_ => [])
            setScreenState(_ => PageLoaderWrapper.Custom)
          } else {
            setScreenState(_ => PageLoaderWrapper.Error("Invalid response format"))
          }
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
        let {reset} = FilterContext.filterContext->React.useContext
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
