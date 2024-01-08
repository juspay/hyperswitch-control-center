open LogicUtils
type response = Error(option<string>) | Success
type timeType = {startTime: string, endTime: string}
let defaultFilter = Recoil.atom(. "defaultFilter", "")

let handleError = (json: Js.Json.t) => {
  switch Js.Json.decodeObject(json) {
  | Some(jsonDict) => {
      let isError = LogicUtils.getBool(jsonDict, "error", true)
      if isError {
        let userMessage = LogicUtils.getString(jsonDict, "errorMessage", "Error Occured")
        Some(userMessage)
      } else {
        None
      }
    }

  | _ => None
  }
}

let useAnalyticsFetch = () => {
  let fetchApi = AuthHooks.useApiFetcher()
  let fetchChartData = (~url, ~body, ~setState, ~setDataLoading) => {
    setDataLoading(_ => true)
    open Promise
    fetchApi(url, ~method_=Fetch.Post, ~bodyStr=body, ())
    ->then(Fetch.Response.json)
    ->then(json => {
      // get total volume and time series and pass that on
      let dataRaw =
        json->getDictFromJsonObject->getJsonObjectFromDict("queryData")->getArrayFromJson([])

      setState(dataRaw)
      setDataLoading(_ => false)
      resolve()
    })
    ->catch(_err => {
      setDataLoading(_ => false)
      resolve()
    })
    ->ignore
  }
  fetchChartData
}

type tabsetHookType = {
  setActiveTab: string => unit,
  activeTab: option<array<string>>,
  updateUrlWithPrefix: Js.Dict.t<string> => unit,
}

let useTabHooks = (~moduleName, ~segmentsOptions) => {
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let getModuleFilters = filterValueJson
  let (activeTav, setActiveTab) = React.useState(_ =>
    getModuleFilters->getStrArrayFromDict(
      `${moduleName}.tabName`,
      [segmentsOptions->Belt.Array.get(0)->Belt.Option.getWithDefault("")],
    )
  )
  let setActiveTab = React.useMemo1(() => {
    (str: string) => {
      setActiveTab(_ => str->String.split(","))
    }
  }, [setActiveTab])

  let updateUrlWithPrefix = React.useMemo1(() => {
    (dict: Js.Dict.t<string>) => {
      let currentDict =
        dict
        ->Dict.toArray
        ->Belt.Array.keepMap(item => {
          let (key, value) = item
          if value !== "" {
            Some((`${moduleName}.${key}`, value))
          } else {
            None
          }
        })
      updateExistingKeys(currentDict->Dict.fromArray)
    }
  }, [updateExistingKeys])
  let activeTab = React.useMemo1(() => {
    Some(
      getModuleFilters
      ->getOptionStrArrayFromDict(`${moduleName}.tabName`)
      ->Belt.Option.getWithDefault(activeTav)
      ->Js.Array2.filter(item => item !== ""),
    )
  }, [getModuleFilters])

  {
    setActiveTab,
    activeTab,
    updateUrlWithPrefix,
  }
}
