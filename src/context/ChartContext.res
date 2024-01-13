open AnalyticsTypesUtils
open Promise
open LogicUtils

type chartComponent = {
  topChartData: option<dataState<Js.Json.t>>,
  bottomChartData: option<dataState<Js.Json.t>>,
  topChartLegendData: option<dataState<Js.Json.t>>,
  bottomChartLegendData: option<dataState<Js.Json.t>>,
  setTopChartVisible: (bool => bool) => unit,
  setBottomChartVisible: (bool => bool) => unit,
  setGranularity: (option<string> => option<string>) => unit,
  granularity: option<string>,
}

let chartComponentDefVal = {
  topChartData: None,
  bottomChartData: None,
  topChartLegendData: None,
  bottomChartLegendData: None,
  setTopChartVisible: _ => (),
  setBottomChartVisible: _ => (),
  setGranularity: _ => (),
  granularity: None,
}

let cardinalityMapperToNumber = cardinality => {
  switch cardinality {
  | Some(cardinality) =>
    switch cardinality {
    | "TOP_5" => 5.
    | "TOP_10" => 10.
    | _ => 5.
    }
  | None => 5.
  }
}

let getGranularityMapper = (granularity: string) => {
  let granularityArr = granularity->String.split(" ")->Array.map(item => item->String.trim)

  if granularity === "Daily" {
    (1, "day")
  } else if granularity === "Weekly" {
    (1, "week")
  } else if granularity === "Hourly" {
    (1, "hour")
  } else {
    (
      granularityArr
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault("1")
      ->Belt.Int.fromString
      ->Belt.Option.getWithDefault(1),
      granularityArr->Belt.Array.get(1)->Belt.Option.getWithDefault("week"),
    )
  }
}

let chartContext = React.createContext(chartComponentDefVal)

module Provider = {
  let make = React.Context.provider(chartContext)
}

@react.component
let make = (~children, ~chartEntity: DynamicChart.entity, ~chartId="", ~defaultFilter=?) => {
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let getAllFilter = filterValueJson
  let (activeTab, activeTabStr) = React.useMemo1(() => {
    let activeTabOptionalArr =
      getAllFilter->getOptionStrArrayFromDict(`${chartEntity.moduleName}.tabName`)
    (
      activeTabOptionalArr,
      activeTabOptionalArr->Belt.Option.getWithDefault([])->Array.joinWith(","),
    )
  }, [getAllFilter])

  let parentToken = AuthWrapperUtils.useTokenParent(Original)
  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetchNew()
  let betaEndPointConfig = React.useContext(BetaEndPointConfigProvider.betaEndPointConfig)
  let fetchApi = AuthHooks.useApiFetcher(~betaEndpointConfig=?betaEndPointConfig, ())
  let jsonTransFormer = switch chartEntity {
  | {jsonTransformer} => jsonTransformer
  | _ => (_val, arr) => arr
  }
  let (topChartData, setTopChartData) = React.useState(_ => Loading)
  let (topChartVisible, setTopChartVisible) = React.useState(_ => false)
  let (bottomChartData, setBottomChartData) = React.useState(_ => Loading)
  let (bottomChartVisible, setBottomChartVisible) = React.useState(_ => false)
  let (topChartDataLegendData, setTopChartDataLegendData) = React.useState(_ => Loading)
  let (bottomChartDataLegendData, setBottomChartDataLegendData) = React.useState(_ => Loading)

  let getGranularity = LineChartUtils.getGranularityNewStr
  let {filterValue} = React.useContext(FilterContext.filterContext)
  let (currentTopMatrix, currentBottomMetrix) = chartEntity.currentMetrics
  let (startTimeFilterKey, endTimeFilterKey) = chartEntity.dateFilterKeys
  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]

  let {allFilterDimension} = chartEntity

  let sortingParams = React.useMemo1((): option<AnalyticsNewUtils.sortedBasedOn> => {
    switch chartEntity {
    | {sortingColumnLegend} =>
      Some({
        sortDimension: sortingColumnLegend,
        ordering: #Desc,
      })
    | _ => None
    }
  }, [chartEntity.sortingColumnLegend])

  let allFilterKeys = Array.concat(defaultFilters, allFilterDimension)
  let customFilterKey = switch chartEntity {
  | {customFilterKey} => customFilterKey
  | _ => ""
  }
  let getAllFilter =
    filterValue
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      (key, value->UrlFetchUtils.getFilterValue)
    })
    ->Dict.fromArray
  let getTopLevelChartFilter = React.useMemo1(() => {
    getAllFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      if prefix === chartId && prefix !== "" {
        None
      } else {
        Some((prefix, value))
      }
    })
    ->Dict.fromArray
  }, [getAllFilter])

  let (topFiltersToSearchParam, customFilter) = React.useMemo1(() => {
    let filterSearchParam =
      getTopLevelChartFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        if allFilterKeys->Array.includes(key) {
          switch value->Js.Json.classify {
          | JSONString(str) => `${key}=${str}`->Some
          | JSONNumber(num) => `${key}=${num->String.make}`->Some
          | JSONArray(arr) => `${key}=[${arr->String.make}]`->Some
          | _ => None
          }
        } else {
          None
        }
      })
      ->Array.joinWith("&")

    (filterSearchParam, getTopLevelChartFilter->LogicUtils.getString(customFilterKey, ""))
  }, [getTopLevelChartFilter])
  let customFilter = switch defaultFilter {
  | Some(defaultFilter) =>
    customFilter == "" ? defaultFilter : `${defaultFilter} and ${customFilter}`
  | _ => customFilter
  }

  let getChartCompFilters = React.useMemo1(() => {
    getAllFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      let fitlerName = keyArr->Belt.Array.get(1)->Belt.Option.getWithDefault("")

      // when chart id is not there then there won't be any prefix so the prefix will the filter name
      if chartId === "" {
        Some((prefix, value))
      } else if prefix === chartId && fitlerName !== "" {
        Some((fitlerName, value))
      } else {
        None
      }
    })
    ->Dict.fromArray
  }, [getAllFilter])

  let (startTimeFromUrl, endTimeFromUrl, filterValueFromUrl) = React.useMemo1(() => {
    let startTimeFromUrl = getTopLevelChartFilter->getString(startTimeFilterKey, "")
    let endTimeFromUrl = getTopLevelChartFilter->getString(endTimeFilterKey, "")
    let filterValueFromUrl =
      getTopLevelChartFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entries => {
        let (key, value) = entries
        chartEntity.allFilterDimension->Array.includes(key) ? Some((key, value)) : None
      })
      ->Dict.fromArray
      ->Js.Json.object_
      ->Some
    (startTimeFromUrl, endTimeFromUrl, filterValueFromUrl)
  }, [topFiltersToSearchParam])

  let cardinalityFromUrl = getChartCompFilters->getString("cardinality", "TOP_5")
  let chartTopMetricFromUrl = getChartCompFilters->getString("chartTopMetric", currentTopMatrix)
  let chartBottomMetricFromUrl =
    getChartCompFilters->getString("chartBottomMetric", currentBottomMetrix)

  let (granularity, setGranularity) = React.useState(_ => None)
  let current_granularity = if startTimeFromUrl !== "" && endTimeFromUrl !== "" {
    getGranularity(~startTime=startTimeFromUrl, ~endTime=endTimeFromUrl)
  } else {
    []
  }

  React.useEffect2(() => {
    setGranularity(prev => {
      current_granularity->Array.includes(prev->Belt.Option.getWithDefault(""))
        ? prev
        : current_granularity->Belt.Array.get(0)
    })
    None
  }, (startTimeFromUrl, endTimeFromUrl))

  let (
    topChartFetchWithCurrentDependecyChange,
    setTopChartFetchWithCurrentDependecyChange,
  ) = React.useState(_ => false)

  let (
    bottomChartFetchWithCurrentDependecyChange,
    setBottomChartFetchWithCurrentDependecyChange,
  ) = React.useState(_ => false)

  React.useEffect5(() => {
    let chartType =
      getChartCompFilters->getString(
        "chartType",
        chartEntity.chartTypes
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault(Line)
        ->DynamicChart.chartMapper,
      )
    if (
      startTimeFromUrl !== "" &&
      endTimeFromUrl !== "" &&
      parentToken->Belt.Option.isSome &&
      (granularity->Belt.Option.isSome || chartType !== "Line Chart") &&
      current_granularity->Array.includes(granularity->Belt.Option.getWithDefault(""))
    ) {
      setTopChartFetchWithCurrentDependecyChange(_ => false)
    }

    None
  }, (
    parentToken,
    current_granularity->Array.joinWith("-") ++
    granularity->Belt.Option.getWithDefault("") ++
    cardinalityFromUrl ++
    chartTopMetricFromUrl ++
    customFilter ++
    startTimeFromUrl ++
    endTimeFromUrl,
    activeTabStr,
    filterValueFromUrl,
    sortingParams,
  ))

  React.useEffect5(() => {
    let chartType =
      getChartCompFilters->getString(
        "chartType",
        chartEntity.chartTypes
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault(Line)
        ->DynamicChart.chartMapper,
      )
    if (
      startTimeFromUrl !== "" &&
      endTimeFromUrl !== "" &&
      parentToken->Belt.Option.isSome &&
      (granularity->Belt.Option.isSome || chartType !== "Line Chart") &&
      current_granularity->Array.includes(granularity->Belt.Option.getWithDefault(""))
    ) {
      setBottomChartFetchWithCurrentDependecyChange(_ => false)
    }

    None
  }, (
    parentToken,
    current_granularity->Array.joinWith("-") ++
    granularity->Belt.Option.getWithDefault("") ++
    chartBottomMetricFromUrl ++
    startTimeFromUrl ++
    cardinalityFromUrl ++
    customFilter ++
    endTimeFromUrl,
    activeTabStr,
    filterValueFromUrl,
    sortingParams,
  ))

  React.useEffect2(() => {
    if !topChartFetchWithCurrentDependecyChange && topChartVisible {
      setTopChartFetchWithCurrentDependecyChange(_ => true)

      switch chartEntity.uriConfig->Array.find(item => {
        let metrics = switch item.metrics->Belt.Array.get(0) {
        | Some(metrics) => metrics.metric_label
        | None => ""
        }
        metrics === chartTopMetricFromUrl
      }) {
      | Some(value) => {
          setTopChartDataLegendData(_ => Loading)
          setTopChartData(_ => Loading)
          let cardinality = cardinalityMapperToNumber(Some(cardinalityFromUrl))
          let timeObj = Dict.fromArray([
            ("start", startTimeFromUrl->Js.Json.string),
            ("end", endTimeFromUrl->Js.Json.string),
          ])
          let (metric, secondaryMetrics) = switch value.metrics->Belt.Array.get(0) {
          | Some(metrics) => (metrics.metric_name_db, metrics.secondryMetrics)
          | None => ("", None)
          }
          let timeCol = value.timeCol

          let metricsArr = switch secondaryMetrics {
          | Some(value) => [value.metric_name_db, metric]
          | None => [metric]
          }

          let granularityConfig = granularity->Belt.Option.getWithDefault("")->getGranularityMapper

          metricsArr
          ->Array.map(metric => {
            fetchApi(
              `${value.uri}?api-type=Chart-timeseries&metrics=${metric}`,
              ~method_=Post,
              ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
                ~timeObj,
                ~groupBy=?activeTab,
                ~metric,
                ~filterValueFromUrl?,
                ~cardinality,
                ~granularityConfig,
                ~customFilterValue=customFilter,
                ~sortingParams?,
                ~timeCol,
                ~domain=value.domain->Belt.Option.getWithDefault(""),
                (),
              )->Js.Json.stringify,
              ~authToken=parentToken,
              ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
              (),
            )
            ->addLogsAroundFetch(~logTitle=`Chart fetch`)
            ->then(
              text => {
                let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)->Array.map(
                  item => {
                    item
                    ->getDictFromJsonObject
                    ->Dict.toArray
                    ->Array.map(
                      dictEn => {
                        let (key, value) = dictEn
                        (key === `${timeCol}_time` ? "time" : key, value)
                      },
                    )
                    ->Dict.fromArray
                    ->Js.Json.object_
                  },
                )
                resolve(jsonTransFormer(metric, jsonObj)->Js.Json.array)
              },
            )
            ->catch(
              _err => {
                resolve(Js.Json.null)
              },
            )
          })
          ->Promise.all
          ->then(metricsArr => {
            resolve(
              setTopChartData(
                _ => Loaded(
                  dataMerge(
                    ~dataArr=metricsArr->Array.map(item => item->getArrayFromJson([])),
                    ~dictKey=Belt.Array.concat(activeTab->Belt.Option.getWithDefault([]), ["time"]),
                  )->Js.Json.array,
                ),
              ),
            )
          })
          ->ignore

          fetchApi(
            `${value.uri}?api-type=Chart-legend&metrics=${metric}`,
            ~method_=Post,
            ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
              ~timeObj,
              ~groupBy=?activeTab,
              ~metric,
              ~cardinality,
              ~filterValueFromUrl?,
              ~customFilterValue=customFilter,
              ~sortingParams?,
              ~domain=value.domain->Belt.Option.getWithDefault(""),
              (),
            )->Js.Json.stringify,
            ~authToken=parentToken,
            ~headers=[("QueryType", "Chart Legend")]->Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(~logTitle=`Chart legend Data`)
          ->then(text => {
            let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)->Js.Json.array
            resolve(setTopChartDataLegendData(_ => Loaded(jsonObj)))
          })
          ->catch(_err => {
            resolve(setTopChartDataLegendData(_ => LoadedError))
          })
          ->ignore
        }

      | None => ()
      }
    }
    None
  }, (topChartFetchWithCurrentDependecyChange, topChartVisible))

  React.useEffect2(() => {
    if !bottomChartFetchWithCurrentDependecyChange && bottomChartVisible {
      setBottomChartFetchWithCurrentDependecyChange(_ => true)
      switch chartEntity.uriConfig->Array.find(item => {
        let metrics = switch item.metrics->Belt.Array.get(0) {
        | Some(metrics) => metrics.metric_label
        | None => ""
        }
        metrics === chartBottomMetricFromUrl
      }) {
      | Some(value) => {
          setBottomChartDataLegendData(_ => Loading)
          setBottomChartData(_ => Loading)

          let cardinality = cardinalityMapperToNumber(Some(cardinalityFromUrl))
          let timeObj = Dict.fromArray([
            ("start", startTimeFromUrl->Js.Json.string),
            ("end", endTimeFromUrl->Js.Json.string),
          ])
          let (metric, secondaryMetrics) = switch value.metrics->Belt.Array.get(0) {
          | Some(metrics) => (metrics.metric_name_db, metrics.secondryMetrics)
          | None => ("", None)
          }
          let metricsArr = switch secondaryMetrics {
          | Some(value) => [value.metric_name_db, metric]
          | None => [metric]
          }
          let timeCol = value.timeCol

          let granularityConfig = granularity->Belt.Option.getWithDefault("")->getGranularityMapper
          metricsArr
          ->Array.map(metric => {
            fetchApi(
              `${value.uri}?api-type=Chart-timeseries&metrics=${metric}`,
              ~method_=Post,
              ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
                ~timeObj,
                ~groupBy=?activeTab,
                ~metric,
                ~filterValueFromUrl?,
                ~cardinality,
                ~granularityConfig,
                ~customFilterValue=customFilter,
                ~sortingParams?,
                ~timeCol=value.timeCol,
                ~domain=value.domain->Belt.Option.getWithDefault(""),
                (),
              )->Js.Json.stringify,
              ~authToken=parentToken,
              ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
              (),
            )
            ->addLogsAroundFetch(~logTitle=`Chart fetch bottomChart`)
            ->then(
              text => {
                let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)->Array.map(
                  item => {
                    item
                    ->getDictFromJsonObject
                    ->Dict.toArray
                    ->Array.map(
                      dictEn => {
                        let (key, value) = dictEn
                        (key === `${timeCol}_time` ? "time" : key, value)
                      },
                    )
                    ->Dict.fromArray
                    ->Js.Json.object_
                  },
                )
                resolve(jsonTransFormer(metric, jsonObj)->Js.Json.array)
              },
            )
            ->catch(
              _err => {
                resolve(Js.Json.null)
              },
            )
          })
          ->Promise.all
          ->then(metricsArr => {
            let data =
              dataMerge(
                ~dataArr=metricsArr->Array.map(item => item->getArrayFromJson([])),
                ~dictKey=Belt.Array.concat(activeTab->Belt.Option.getWithDefault([]), ["time"]),
              )->Js.Json.array

            resolve(setBottomChartData(_ => Loaded(data)))
          })
          ->ignore

          fetchApi(
            `${value.uri}?api-type=Chart-legend&metrics=${metric}`,
            ~method_=Post,
            ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
              ~timeObj,
              ~groupBy=?activeTab,
              ~metric,
              ~cardinality,
              ~filterValueFromUrl?,
              ~customFilterValue=customFilter,
              ~sortingParams?,
              ~domain=value.domain->Belt.Option.getWithDefault(""),
              (),
            )->Js.Json.stringify,
            ~authToken=parentToken,
            ~headers=[("QueryType", "Chart Legend")]->Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(~logTitle=`Chart legend Data`)
          ->then(text => {
            let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)->Js.Json.array
            resolve(setBottomChartDataLegendData(_ => Loaded(jsonObj)))
          })
          ->catch(_err => {
            resolve(setBottomChartDataLegendData(_ => LoadedError))
          })
          ->ignore
        }

      | None => ()
      }
    }
    None
  }, (bottomChartFetchWithCurrentDependecyChange, bottomChartVisible))

  let chartData = React.useMemo4(() => {
    (topChartData, topChartDataLegendData, bottomChartData, bottomChartDataLegendData)
  }, (topChartData, topChartDataLegendData, bottomChartData, bottomChartDataLegendData))

  let value = React.useMemo5(() => {
    let (
      topChartData,
      topChartDataLegendData,
      bottomChartData,
      bottomChartDataLegendData,
    ) = chartData
    {
      topChartData: Some(topChartData),
      bottomChartData: Some(bottomChartData),
      topChartLegendData: Some(topChartDataLegendData),
      bottomChartLegendData: Some(bottomChartDataLegendData),
      setTopChartVisible,
      setBottomChartVisible,
      setGranularity,
      granularity,
    }
  }, (chartData, setTopChartVisible, setBottomChartVisible, setGranularity, granularity))

  <Provider value> children </Provider>
}

module SDKAnalyticsChartContext = {
  @react.component
  let make = (
    ~children,
    ~chartEntity: DynamicChart.entity,
    ~selectedTrends,
    ~filterMapper,
    ~chartId="",
    ~defaultFilter=?,
    ~dataMergerAndTransformer,
    ~segmentValue: option<array<string>>=?,
    ~differentTimeValues: option<array<AnalyticsUtils.timeRanges>>=?,
  ) => {
    let parentToken = AuthWrapperUtils.useTokenParent(Original)
    let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetchNew()
    let betaEndPointConfig = React.useContext(BetaEndPointConfigProvider.betaEndPointConfig)
    let fetchApi = AuthHooks.useApiFetcher(~betaEndpointConfig=?betaEndPointConfig, ())
    let jsonTransFormer = switch chartEntity {
    | {jsonTransformer} => jsonTransformer
    | _ => (_val, arr) => arr
    }

    let (topChartData, setTopChartData) = React.useState(_ => Loading)
    let (topChartVisible, setTopChartVisible) = React.useState(_ => false)
    let bottomChartData = Loading
    let (_bottomChartVisible, setBottomChartVisible) = React.useState(_ => false)
    let (topChartDataLegendData, setTopChartDataLegendData) = React.useState(_ => Loading)
    let bottomChartDataLegendData = Loading

    let getGranularity = LineChartUtils.getGranularityNewStr
    let {filterValue} = React.useContext(FilterContext.filterContext)
    let (currentTopMatrix, currentBottomMetrix) = chartEntity.currentMetrics
    let (startTimeFilterKey, endTimeFilterKey) = chartEntity.dateFilterKeys
    let defaultFilters = [startTimeFilterKey, endTimeFilterKey]

    let {allFilterDimension} = chartEntity
    let allFilterKeys = Array.concat(defaultFilters, allFilterDimension)
    let customFilterKey = switch chartEntity {
    | {customFilterKey} => customFilterKey
    | _ => ""
    }
    let getAllFilter =
      filterValue
      ->Dict.toArray
      ->Array.map(item => {
        let (key, value) = item
        (key, value->UrlFetchUtils.getFilterValue)
      })
      ->Dict.fromArray
    let getTopLevelChartFilter = React.useMemo1(() => {
      getAllFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(item => {
        let (key, value) = item
        let keyArr = key->String.split(".")
        let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        if prefix === chartId && prefix !== "" {
          None
        } else {
          Some((prefix, value))
        }
      })
      ->Dict.fromArray
    }, [getAllFilter])

    let (topFiltersToSearchParam, customFilter) = React.useMemo1(() => {
      let filterSearchParam =
        getTopLevelChartFilter
        ->Dict.toArray
        ->Belt.Array.keepMap(entry => {
          let (key, value) = entry
          if allFilterKeys->Array.includes(key) {
            switch value->Js.Json.classify {
            | JSONString(str) => `${key}=${str}`->Some
            | JSONNumber(num) => `${key}=${num->String.make}`->Some
            | JSONArray(arr) => `${key}=[${arr->String.make}]`->Some
            | _ => None
            }
          } else {
            None
          }
        })
        ->Array.joinWith("&")

      (filterSearchParam, getTopLevelChartFilter->LogicUtils.getString(customFilterKey, ""))
    }, [getTopLevelChartFilter])
    let customFilter = switch defaultFilter {
    | Some(defaultFilter) =>
      customFilter == "" ? defaultFilter : `${defaultFilter} and ${customFilter}`
    | _ => customFilter
    }

    let getChartCompFilters = React.useMemo1(() => {
      getAllFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(item => {
        let (key, value) = item
        let keyArr = key->String.split(".")
        let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let fitlerName = keyArr->Belt.Array.get(1)->Belt.Option.getWithDefault("")

        // when chart id is not there then there won't be any prefix so the prefix will the filter name
        if chartId === "" {
          Some((prefix, value))
        } else if prefix === chartId && fitlerName !== "" {
          Some((fitlerName, value))
        } else {
          None
        }
      })
      ->Dict.fromArray
    }, [getAllFilter])

    let (startTimeFromUrl, endTimeFromUrl, filterValueFromUrl) = React.useMemo1(() => {
      let startTimeFromUrl = getTopLevelChartFilter->getString(startTimeFilterKey, "")
      let endTimeFromUrl = getTopLevelChartFilter->getString(endTimeFilterKey, "")
      let filterValueFromUrl =
        getTopLevelChartFilter
        ->Dict.toArray
        ->Belt.Array.keepMap(entries => {
          let (key, value) = entries
          chartEntity.allFilterDimension->Array.includes(key) ? Some((key, value)) : None
        })
        ->Dict.fromArray
        ->Js.Json.object_
        ->Some
      (startTimeFromUrl, endTimeFromUrl, filterValueFromUrl)
    }, [topFiltersToSearchParam])
    let currentTimeRanges: AnalyticsUtils.timeRanges = {
      fromTime: startTimeFromUrl,
      toTime: endTimeFromUrl,
    }
    let differentTimeValues = Belt.Array.concat(
      [currentTimeRanges],
      differentTimeValues->Belt.Option.getWithDefault([]),
    )
    let cardinalityFromUrl = getChartCompFilters->getString("cardinality", "TOP_5")
    let _chartTopMetricFromUrl = getChartCompFilters->getString("chartTopMetric", currentTopMatrix)
    let _chartBottomMetricFromUrl =
      getChartCompFilters->getString("chartBottomMetric", currentBottomMetrix)

    let (granularity, setGranularity) = React.useState(_ => None)
    let current_granularity = if startTimeFromUrl !== "" && endTimeFromUrl !== "" {
      getGranularity(~startTime=startTimeFromUrl, ~endTime=endTimeFromUrl)
    } else {
      []
    }

    React.useEffect2(() => {
      setGranularity(prev => {
        current_granularity->Array.includes(prev->Belt.Option.getWithDefault(""))
          ? prev
          : current_granularity->Belt.Array.get(0)
      })
      None
    }, (startTimeFromUrl, endTimeFromUrl))

    let (
      topChartFetchWithCurrentDependecyChange,
      setTopChartFetchWithCurrentDependecyChange,
    ) = React.useState(_ => false)

    React.useEffect4(() => {
      let chartType =
        getChartCompFilters->getString(
          "chartType",
          chartEntity.chartTypes
          ->Belt.Array.get(0)
          ->Belt.Option.getWithDefault(Line)
          ->DynamicChart.chartMapper,
        )
      if (
        startTimeFromUrl !== "" &&
        endTimeFromUrl !== "" &&
        parentToken->Belt.Option.isSome &&
        (granularity->Belt.Option.isSome || chartType !== "Line Chart") &&
        current_granularity->Array.includes(granularity->Belt.Option.getWithDefault(""))
      ) {
        setTopChartFetchWithCurrentDependecyChange(_ => false)
      }

      None
    }, (
      parentToken,
      current_granularity->Array.joinWith("-") ++
      granularity->Belt.Option.getWithDefault("") ++
      cardinalityFromUrl ++
      selectedTrends->Array.joinWith(",") ++
      customFilter ++
      startTimeFromUrl ++
      segmentValue->Belt.Option.getWithDefault([])->Array.joinWith(",") ++
      endTimeFromUrl,
      filterValueFromUrl,
      differentTimeValues->Array.map(item => `${item.fromTime}${item.toTime}`)->Array.joinWith(","),
    ))

    React.useEffect2(() => {
      if !topChartFetchWithCurrentDependecyChange && topChartVisible {
        setTopChartFetchWithCurrentDependecyChange(_ => true)
        let metricsSDK = "total_volume"
        switch chartEntity.uriConfig->Array.find(item => {
          let metrics = switch item.metrics->Belt.Array.get(0) {
          | Some(metrics) => metrics.metric_name_db
          | None => ""
          }
          metrics === metricsSDK
        }) {
        | Some(value) => {
            let timeCol = value.timeCol
            setTopChartDataLegendData(_ => Loading)
            setTopChartData(_ => Loading)
            let cardinality = cardinalityMapperToNumber(Some(cardinalityFromUrl))

            let metric = switch value.metrics->Belt.Array.get(0) {
            | Some(metrics) => metrics.metric_name_db
            | None => ""
            }

            let granularityConfig =
              granularity->Belt.Option.getWithDefault("")->getGranularityMapper
            switch differentTimeValues->Belt.Array.get(0) {
            | Some(timeObjOrig) => {
                let timeObj = Dict.fromArray([
                  ("start", timeObjOrig.fromTime->Js.Json.string),
                  ("end", timeObjOrig.toTime->Js.Json.string),
                ])

                fetchApi(
                  `${value.uri}?api-type=Chart-timeseries&metrics=${metric}&top5`,
                  ~method_=Post,
                  ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
                    ~timeObj,
                    ~groupBy=?segmentValue,
                    ~metric,
                    ~cardinality,
                    ~filterValueFromUrl?,
                    ~customFilterValue=customFilter,
                    ~timeCol,
                    ~domain=value.domain->Belt.Option.getWithDefault(""),
                    (),
                  )->Js.Json.stringify,
                  ~authToken=parentToken,
                  ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
                  (),
                )
                ->addLogsAroundFetch(~logTitle=`Chart fetch`)
                ->then(text => {
                  let groupedArr = convertNewLineSaperatedDataToArrayOfJson(text)->Array.map(
                    item => {
                      item
                      ->getDictFromJsonObject
                      ->Dict.toArray
                      ->Belt.Array.keepMap(
                        dictOrigItem => {
                          let (key, value) = dictOrigItem
                          segmentValue->Belt.Option.getWithDefault([])->Array.includes(key)
                            ? Some(value->Js.Json.decodeString->Belt.Option.getWithDefault(""))
                            : None
                        },
                      )
                      ->Array.joinWith("-dimension-")
                    },
                  )

                  selectedTrends
                  ->Array.map(
                    item => {
                      fetchApi(
                        `${value.uri}?api-type=Chart-timeseries&metrics=${metric}&trend=${item}`,
                        ~method_=Post,
                        ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
                          ~timeObj,
                          ~groupBy=?segmentValue,
                          ~metric,
                          ~filterValueFromUrl?,
                          ~granularityConfig,
                          ~customFilterValue=customFilter,
                          ~timeCol,
                          ~jsonFormattedFilter=item->filterMapper,
                          ~domain=value.domain->Belt.Option.getWithDefault(""),
                          (),
                        )->Js.Json.stringify,
                        ~authToken=parentToken,
                        ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
                        (),
                      )
                      ->addLogsAroundFetch(~logTitle=`Chart fetch`)
                      ->then(
                        text =>
                          resolve((
                            item,
                            `${timeObjOrig.fromTime} to ${timeObjOrig.toTime}`,
                            jsonTransFormer(
                              metric,
                              convertNewLineSaperatedDataToArrayOfJson(text)->Belt.Array.keepMap(
                                item => {
                                  let origDictArr =
                                    item
                                    ->getDictFromJsonObject
                                    ->Dict.toArray
                                    ->Belt.Array.keepMap(
                                      origDictArrItem => {
                                        let (key, value) = origDictArrItem
                                        segmentValue
                                        ->Belt.Option.getWithDefault([])
                                        ->Array.includes(key)
                                          ? Some(
                                              value
                                              ->Js.Json.decodeString
                                              ->Belt.Option.getWithDefault(""),
                                            )
                                          : None
                                      },
                                    )
                                    ->Array.joinWith("-dimension-")

                                  groupedArr->Array.includes(origDictArr)
                                    ? Some(
                                        item
                                        ->getDictFromJsonObject
                                        ->Dict.toArray
                                        ->Array.map(
                                          dictEn => {
                                            let (key, value) = dictEn
                                            (key === `${timeCol}_time` ? "time" : key, value)
                                          },
                                        )
                                        ->Dict.fromArray
                                        ->Js.Json.object_,
                                      )
                                    : None
                                },
                              ),
                            )->Js.Json.array,
                          )),
                      )
                      ->catch(_err => resolve((item, "", []->Js.Json.array)))
                    },
                  )
                  ->Promise.all
                  ->Promise.thenResolve(
                    dataArr => {
                      setTopChartData(
                        _ => Loaded(
                          dataMergerAndTransformer(
                            ~selectedTrends,
                            ~data=dataArr,
                            ~segments=?segmentValue,
                            ~startTime=startTimeFromUrl,
                            ~endTime=endTimeFromUrl,
                            ~granularityConfig,
                            (),
                          ),
                        ),
                      )
                    },
                  )
                  ->ignore

                  resolve()
                })
                ->catch(_err => resolve())
                ->ignore
              }
            | None => ()
            }
          }

        | None => ()
        }
      }
      None
    }, (topChartFetchWithCurrentDependecyChange, topChartVisible))

    // React.useEffect2(() => {
    //   if !bottomChartFetchWithCurrentDependecyChange && bottomChartVisible {
    //     setBottomChartFetchWithCurrentDependecyChange(_ => true)
    //     let metricsSDK = "total_volume"
    //     switch chartEntity.uriConfig->Array.find(item => {
    //       let metrics = switch item.metrics->Belt.Array.get(0) {
    //       | Some(metrics) => metrics.metric_name_db
    //       | None => ""
    //       }
    //       metrics === metricsSDK
    //     }) {
    //     | Some(value) => {
    //         setBottomChartDataLegendData(_ => Loading)
    //         setBottomChartData(_ => Loading)
    //         let cardinality = cardinalityMapperToNumber(Some(cardinalityFromUrl))
    //         let metric = switch value.metrics->Belt.Array.get(0) {
    //         | Some(metrics) => metrics.metric_name_db
    //         | None => ""
    //         }

    //         let granularityConfig =
    //           granularity->Belt.Option.getWithDefault("")->getGranularityMapper

    //         differentTimeValues
    //         ->Array.map(timeObjOrig => {
    //           let timeObj = Dict.fromArray([
    //             ("start", timeObjOrig.fromTime->Js.Json.string),
    //             ("end", timeObjOrig.toTime->Js.Json.string),
    //           ])
    //           selectedTrends->Array.map(
    //             item => {
    //               fetchApi(
    //                 `${value.uri}?api-type=Chart-timeseries&metrics=${metric}&trend=${item}`,
    //                 ~method_=Post,
    //                 ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
    //                   ~timeObj,
    //                   ~groupBy=?segmentValue,
    //                   ~metric,
    //                   ~filterValueFromUrl?,
    //                   ~cardinality,
    //                   ~customFilterValue=customFilter,
    //                   ~jsonFormattedFilter=item->filterMapper,
    //                   ~domain=value.domain->Belt.Option.getWithDefault(""),
    //                   (),
    //                 )->Js.Json.stringify,
    //                 ~authToken=parentToken,
    //                 ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
    //                 (),
    //               )
    //               ->addLogsAroundFetch(~logTitle=`Chart fetch`)
    //               ->then(
    //                 text =>
    //                   resolve((
    //                     item,
    //                     `${timeObjOrig.fromTime} to ${timeObjOrig.toTime}`,
    //                     convertNewLineSaperatedDataToArrayOfJson(text)->Js.Json.array,
    //                   )),
    //               )
    //               ->catch(_err => resolve((item, "", []->Js.Json.array)))
    //             },
    //           )
    //         })
    //         ->Belt.Array.concatMany
    //         ->Promise.all
    //         ->Promise.thenResolve(dataArr => {
    //           setBottomChartData(
    //             _ => Loaded(
    //               dataMergerAndTransformer(
    //                 ~selectedTrends,
    //                 ~data=dataArr,
    //                 ~segments=?segmentValue,
    //                 ~startTime=startTimeFromUrl,
    //                 ~endTime=endTimeFromUrl,
    //                 ~granularityConfig,
    //                 (),
    //               ),
    //             ),
    //           )
    //         })
    //         ->ignore
    //       }

    //     | None => ()
    //     }
    //   }
    //   None
    // }, (bottomChartFetchWithCurrentDependecyChange, bottomChartVisible))

    let chartData = React.useMemo4(() => {
      (topChartData, topChartDataLegendData, bottomChartData, bottomChartDataLegendData)
    }, (topChartData, topChartDataLegendData, bottomChartData, bottomChartDataLegendData))

    let value = React.useMemo5(() => {
      let (
        topChartData,
        topChartDataLegendData,
        bottomChartData,
        bottomChartDataLegendData,
      ) = chartData
      {
        topChartData: Some(topChartData),
        bottomChartData: Some(bottomChartData),
        topChartLegendData: Some(topChartDataLegendData),
        bottomChartLegendData: Some(bottomChartDataLegendData),
        setTopChartVisible,
        setBottomChartVisible,
        setGranularity,
        granularity,
      }
    }, (chartData, setTopChartVisible, setBottomChartVisible, setGranularity, granularity))

    <Provider value> children </Provider>
  }
}
