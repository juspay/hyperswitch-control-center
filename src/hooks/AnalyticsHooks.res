let defaultFilter = Recoil.atom(. "defaultFilter", "")

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
