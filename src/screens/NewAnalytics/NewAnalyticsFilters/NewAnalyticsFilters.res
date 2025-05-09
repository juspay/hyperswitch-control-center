open LogicUtils
open APIUtils
open NewAnalyticsFiltersUtils
open NewAnalyticsFiltersHelper
open NewAnalyticsTypes

module RefundsFilter = {
  @react.component
  let make = (~filterValueJson, ~dimensions, ~loadFilters, ~screenState, ~updateFilterContext) => {
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    let (currencOptions, setCurrencOptions) = React.useState(_ => [])
    let (selectedCurrency, setSelectedCurrency) = React.useState(_ => defaultCurrency)

    let filterValueModifier = dict => {
      dict->Dict.set((#currency: filters :> string), selectedCurrency.value)
      dict
    }

    let responseHandler = json => {
      let options = json->getOptions
      setCurrencOptions(_ => options)
    }

    React.useEffect(() => {
      if (
        startTimeVal->isNonEmptyString &&
        endTimeVal->isNonEmptyString &&
        dimensions->Array.length > 0
      ) {
        setSelectedCurrency(_ => defaultCurrency)
        loadFilters(responseHandler)->ignore
      }
      None
    }, (startTimeVal, endTimeVal, dimensions))

    React.useEffect(() => {
      updateFilterContext(filterValueModifier)
      None
    }, [selectedCurrency.value])

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

module PaymentsFilter = {
  @react.component
  let make = (~filterValueJson, ~dimensions, ~loadFilters, ~screenState, ~updateFilterContext) => {
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    let (currencOptions, setCurrencOptions) = React.useState(_ => [])
    let (selectedCurrency, setSelectedCurrency) = React.useState(_ => defaultCurrency)
    let isSampleDataEnabled =
      filterValueJson
      ->getString("is_sample_data_enabled", "true")
      ->LogicUtils.getBoolFromString(true)
    let filterValueModifier = dict => {
      dict->Dict.set((#currency: filters :> string), selectedCurrency.value)
      dict
    }

    let responseHandler = json => {
      let options = json->getOptions
      setCurrencOptions(_ => options)
    }

    React.useEffect(() => {
      if (
        startTimeVal->isNonEmptyString &&
        endTimeVal->isNonEmptyString &&
        dimensions->Array.length > 0
      ) {
        setSelectedCurrency(_ => defaultCurrency)
        loadFilters(responseHandler)->ignore
      }
      None
    }, (startTimeVal, endTimeVal, dimensions))

    React.useEffect(() => {
      updateFilterContext(filterValueModifier)
      None
    }, [selectedCurrency.value])

    let setOption = value => {
      setSelectedCurrency(_ => value)
    }

    <PageLoaderWrapper screenState customLoader={<FilterLoader />}>
      <NewAnalyticsHelper.CustomDropDown
        buttonText={selectedCurrency}
        options={currencOptions}
        setOption
        positionClass="left-0"
        disabled=isSampleDataEnabled
      />
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~entityName, ~domain) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson, updateExistingKeys, filterValue} = React.useContext(
    FilterContext.filterContext,
  )
  let (dimensions, setDimensions) = React.useState(_ => [])
  let domainString = (domain: NewAnalyticsTypes.domain :> string)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName, ~methodType=Get, ~id=Some(domainString))
      let infoDetails = await fetchDetails(infoUrl)
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
    } catch {
    | _ => ()
    }
  }

  let loadFilters = async responseHandler => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(~entityName=V1(ANALYTICS_FILTERS), ~methodType=Post, ~id=Some(domainString))

      let body =
        {
          startTime: startTimeVal,
          endTime: endTimeVal,
          groupByNames: HSAnalyticsUtils.getStringListFromArrayDict(dimensions),
          source: "BATCH",
        }
        ->AnalyticsUtils.filterBody
        ->JSON.Encode.object

      let response = await updateDetails(url, body, Post)

      response->responseHandler
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
    }
  }

  let updateFilterContext = valueModifier => {
    let newValue = filterValue->Dict.copy
    newValue->valueModifier->updateExistingKeys
  }

  React.useEffect(() => {
    loadInfo()->ignore
    None
  }, [])

  switch domain {
  | #payments =>
    <PaymentsFilter dimensions loadFilters screenState updateFilterContext filterValueJson />
  | #refunds =>
    <RefundsFilter dimensions loadFilters screenState updateFilterContext filterValueJson />
  | _ => React.null
  }
}
