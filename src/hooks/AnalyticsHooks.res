open LogicUtils
type response = Error(option<string>) | Success
type timeType = {startTime: string, endTime: string}
let defaultFilter = Recoil.atom(. "defaultFilter", "")

let filterToKeyMapper = json => {
  let arrjson =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("queryData", [])
    ->Belt.Array.keepMap(item => {
      let strr = item->getDictFromJsonObject->getString("dimension", "")
      strr == "" ? None : Some(strr)
    })
  arrjson
}

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

let useGetCalendarTime = () => {
  let url = RescriptReactRouter.useUrl()
  let urlSplit =
    url.search
    ->Js.Global.decodeURI
    ->Js.String2.split("&")
    ->Js.Array2.map(item => {
      let arr = Js.String.split("=", item)
      (
        arr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        arr->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
      )
    })
    ->Js.Dict.fromArray

  let startTime = switch Js.Dict.get(urlSplit, "startTime") {
  | Some(a) => a
  | None => ""
  }

  let endTime = switch Js.Dict.get(urlSplit, "endTime") {
  | Some(b) => b
  | None => ""
  }
  let calendarTime = React.useMemo2(() => {
    {
      startTime,
      endTime,
    }
  }, (startTime, endTime))
  calendarTime
}

let useGetFiltersData = () => {
  let (filterData, setFilterData) = React.useState(_ => None)
  let timeFilters = UrlUtils.useGetFilterDictFromUrl("")
  let startTimeVal = timeFilters->LogicUtils.getString("startTime", "")

  let endTimeVal = timeFilters->LogicUtils.getString("endTime", "")
  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetch()

  let fetchApi = AuthHooks.useApiFetcher()

  (uri, method, filterBody) => {
    open Promise

    React.useEffect3(() => {
      setFilterData(_ => None)

      if startTimeVal !== "" && endTimeVal !== "" {
        fetchApi(
          uri,
          ~method_=method,
          ~bodyStr=filterBody,
          ~headers=[("QueryType", "Filter")]->Js.Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="Filter Data Api")
        ->thenResolve(json => setFilterData(_ => json->Some))
        ->catch(_err => resolve())
        ->ignore
      }
      None
    }, (startTimeVal, endTimeVal, filterBody))
    filterData
  }
}

let useGetLiveFiltersData = () => {
  let (filterData, setFilterData) = React.useState(_ => None)

  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetch()

  let fetchApi = AuthHooks.useApiFetcher()

  (uri, method, filterBody) => {
    open Promise

    React.useEffect1(() => {
      let endTimeVal = Js.Date.make()->Js.Date.toISOString
      let endTimeInMs = Js.Date.make()->Js.Date.getTime
      let ttlTime = 1.0 *. 3600.0 *. 1000.0
      let startTimeInMs = endTimeInMs -. ttlTime
      let startTimeVal = Js.Date.fromFloat(startTimeInMs)->Js.Date.toISOString
      setFilterData(_ => None)

      if startTimeVal !== "" && endTimeVal !== "" {
        fetchApi(
          uri,
          ~method_=method,
          ~bodyStr=filterBody,
          ~headers=[("QueryType", "Filter")]->Js.Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="Filter Data Api")
        ->thenResolve(json => setFilterData(_ => json->Some))
        ->catch(_err => resolve())
        ->ignore
      }
      None
    }, [filterBody])
    filterData
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

let useSaveView = () => {
  let fetchApi = AuthHooks.useApiFetcher()
  (~bodyStr: string) => {
    let url = "/api/ec/v1/savedView"

    open Promise
    fetchApi(url, ~bodyStr, ~method_=Post, ())
    ->then(res => {
      if res->Fetch.Response.status == 200 {
        resolve(Success)
      } else {
        Fetch.Response.json(res)->thenResolve(json => {
          json->handleError->Error
        })
      }
    })
    ->catch(_ => resolve(Error(Some("Something went wrong"))))
  }
}

let useUpdateSaveView = () => {
  let fetchApi = AuthHooks.useApiFetcher()
  (~bodyStr: string, ~id: string) => {
    let url = `/api/ec/v1/savedView/${id}`

    open Promise
    fetchApi(url, ~method_=Put, ~bodyStr, ())
    ->then(res => {
      if res->Fetch.Response.status == 200 {
        resolve(Success)
      } else {
        Fetch.Response.json(res)->thenResolve(json => {
          json->handleError->Error
        })
      }
    })
    ->catch(_ => resolve(Error(Some("Something went wrong"))))
  }
}

let useDeleteSaveView = () => {
  let fetchApi = AuthHooks.useApiFetcher()
  (~id: string) => {
    let url = `/api/ec/v1/savedView/${id}`

    open Promise
    fetchApi(url, ~method_=Delete, ())
    ->then(res => {
      if res->Fetch.Response.status == 200 {
        resolve(Success)
      } else {
        Fetch.Response.json(res)->thenResolve(json => {
          json->handleError->Error
        })
      }
    })
    ->catch(_ => resolve(Error(Some("Something went wrong"))))
  }
}

let useSaveViewListFetcher = () => {
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  (~process) => {
    let url = "/api/ec/v1/savedView/list"

    open Promise
    fetchApi(url, ~method_=Get, ())
    ->then(Fetch.Response.json)
    ->thenResolve(json => {
      let dict = json->getDictFromJsonObject
      let hasError = LogicUtils.getBool(dict, "error", false)
      if hasError {
        let errorMessage = LogicUtils.getString(
          dict,
          "errorMessage",
          "Error occurred on switching Merchant",
        )
        showToast(~toastType=ToastError, ~message=errorMessage, ())
      } else {
        let rows = dict->getJsonObjectFromDict("rows")
        process(rows)
      }
    })
    ->catch(_ => {
      showToast(~toastType=ToastError, ~message="SomeThing Went Wrong", ())
      resolve()
    })
    ->ignore
  }
}

type tabsetHookType = {
  setActiveTab: string => unit,
  activeTab: option<array<string>>,
  updateUrlWithPrefix: Js.Dict.t<string> => unit,
}

let useTabHooks = (~moduleName, ~segmentsOptions) => {
  let {updateExistingKeys} = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
  let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
  let (activeTav, setActiveTab) = React.useState(_ =>
    getModuleFilters->getStrArrayFromDict(
      `${moduleName}.tabName`,
      [segmentsOptions->Belt.Array.get(0)->Belt.Option.getWithDefault("")],
    )
  )
  let setActiveTab = React.useMemo1(() => {
    (str: string) => {
      setActiveTab(_ => str->Js.String2.split(","))
    }
  }, [setActiveTab])

  let updateUrlWithPrefix = React.useMemo1(() => {
    (dict: Js.Dict.t<string>) => {
      let currentDict =
        dict
        ->Js.Dict.entries
        ->Belt.Array.keepMap(item => {
          let (key, value) = item
          if value !== "" {
            Some((`${moduleName}.${key}`, value))
          } else {
            None
          }
        })
      updateExistingKeys(currentDict->Js.Dict.fromArray)
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
