module CustomerInfo = {
  open CustomersEntity
  module Details = {
    @react.component
    let make = (
      ~data,
      ~getHeading,
      ~getCell,
      ~excludeColKeys=[],
      ~detailsFields,
      ~justifyClassName="justify-start",
      ~widthClass="w-1/4",
      ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
      ~children=?,
    ) => {
      <OrderUtils.Section
        customCssClass={`border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 ${bgColor} rounded-md p-5`}>
        <FormRenderer.DesktopRow>
          <div
            className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
            {detailsFields
            ->Array.mapWithIndex((colType, i) => {
              <RenderIf
                condition={!(excludeColKeys->Array.includes(colType))} key={Int.toString(i)}>
                <div className={`flex ${widthClass} items-center`}>
                  <OrderUtils.DisplayKeyValueParams
                    heading={getHeading(colType)}
                    value={getCell(data, colType)}
                    customMoneyStyle="!font-normal !text-sm"
                    labelMargin="!py-0 mt-2"
                    overiddingHeadingStyles="text-black text-sm font-medium"
                    textColor="!font-normal !text-jp-gray-700"
                  />
                </div>
              </RenderIf>
            })
            ->React.array}
          </div>
        </FormRenderer.DesktopRow>
        <RenderIf condition={children->Option.isSome}>
          {children->Option.getOr(React.null)}
        </RenderIf>
      </OrderUtils.Section>
    }
  }
  @react.component
  let make = (~dict) => {
    let customerData = itemToObjMapper(dict)
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details data=customerData getHeading getCell detailsFields=allColumns />
    </>
  }
}

module CustomerDetails = {
  open GlobalSearchBarUtils
  open GlobalSearchTypes
  open APIUtils
  @react.component
  let make = (~id) => {
    let getURL = useGetURL()
    let fetchData = APIUtils.useUpdateMethod()
    let (searchResults, setSearchResults) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getSearchResults = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post, ())

        let body = [("query", id->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson

        let response = await fetchData(url, body, Post, ())

        let remote_results = response->parseResponse

        let data = {
          local_results: [],
          remote_results,
          searchText: id,
        }

        let (results, _) = data->SearchResultsPageUtils.getSearchresults

        setSearchResults(_ => results)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Success)
      }
    }

    React.useEffect(() => {
      getSearchResults()->ignore
      None
    }, [])

    <PageLoaderWrapper screenState>
      <div className="mt-5">
        <SearchResultsPage.SearchResultsComponent searchResults searchText={id} />
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => JSON.Encode.null)

  let fetchCustomersData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let customersUrl = getURL(~entityName=CUSTOMERS, ~methodType=Get, ~id=Some(id), ())
      let response = await fetchDetails(customersUrl)
      setCustomersData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    fetchCustomersData()->ignore
    None
  }, [])
  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center">
          <div>
            <PageUtils.PageHeading title="Customers" />
            <BreadCrumbNavigation
              path=[{title: "Customers", link: "/customers"}]
              currentPageTitle=id
              cursorStyle="cursor-pointer"
            />
          </div>
          <div />
        </div>
      </div>
      <CustomerInfo dict={customersData->LogicUtils.getDictFromJsonObject} />
      <CustomerDetails id />
    </div>
  </PageLoaderWrapper>
}
