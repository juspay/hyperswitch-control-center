module PaymentsTabFilter = {
  open LogicUtils
  open Promise
  open APIUtils
  open NewAnalyticsFiltersUtils
  open NewAnalyticsFiltersHelper
  open NewAnalyticsTypes
  @react.component
  let make = () => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let updateDetails = useUpdateMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (currencOptions, setCurrencOptions) = React.useState(_ => [])
    let {filterValueJson, updateExistingKeys, filterValue} = React.useContext(
      FilterContext.filterContext,
    )
    let (selectedCurrency, setSelectedCurrency) = React.useState(_ => defaultCurrency)
    let (dimensions, setDimensions) = React.useState(_ => [])
    let domain = (#payments: NewAnalyticsTypes.domain :> string)
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")

    let loadInfo = async () => {
      try {
        let infoUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some(domain))
        let infoDetails = await fetchDetails(infoUrl)
        setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      } catch {
      | _ => ()
      }
    }

    let loadFilters = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(~entityName=ANALYTICS_FILTERS, ~methodType=Post, ~id=Some(domain))

        let body =
          {
            startTime: startTimeVal,
            endTime: endTimeVal,
            groupByNames: HSAnalyticsUtils.getStringListFromArrayDict(dimensions),
            source: "BATCH",
          }
          ->AnalyticsUtils.filterBody
          ->JSON.Encode.object

        updateDetails(url, body, Post)
        ->thenResolve(json => {
          let options = json->getOptions
          setCurrencOptions(_ => options)
          setScreenState(_ => PageLoaderWrapper.Success)
        })
        ->catch(_ => resolve())
        ->ignore
      } catch {
      | _ => ()
      }
    }

    let updateFilterContext = () => {
      filterValue->Dict.set((#currency: filters :> string), selectedCurrency.value)
      filterValue->updateExistingKeys
    }

    React.useEffect(() => {
      loadInfo()->ignore
      None
    }, [])

    React.useEffect(() => {
      if (
        startTimeVal->isNonEmptyString &&
        endTimeVal->isNonEmptyString &&
        dimensions->Array.length > 0
      ) {
        setSelectedCurrency(_ => defaultCurrency)
        updateFilterContext()
        loadFilters()->ignore
      }
      None
    }, (startTimeVal, endTimeVal, dimensions))

    let setOption = value => {
      setSelectedCurrency(_ => value)
    }

    <PageLoaderWrapper screenState customLoader={<FilterLoader />}>
      <NewAnalyticsHelper.CustomDropDown
        buttonText={selectedCurrency} options={currencOptions} setOption positionClass="left-0"
      />
    </PageLoaderWrapper>
  }
}
