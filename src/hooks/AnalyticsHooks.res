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
