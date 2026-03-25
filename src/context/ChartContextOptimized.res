// ChartContextOptimized.res
// Performance optimization for Issue #4559
// Hybrid approach: Context for stable functions, Recoil for high-frequency chart data
//
// This implementation replaces the monolithic ChartContext with:
// 1. Recoil atoms for high-frequency chart data (topChartData, bottomChartData, legendData)
// 2. React Context for stable action functions (setTopChartVisible, setGranularity)
// 3. Recoil atoms for configuration state (granularity, visibility)
//
// Benefits:
// - Chart components only re-render when their specific data atom changes
// - Top chart updates don't re-render bottom chart consumers
// - Better separation of data and actions

open AnalyticsTypesUtils
open Promise
open LogicUtils

type chartActions = {
  setTopChartVisible: (bool => bool) => unit,
  setBottomChartVisible: (bool => bool) => unit,
  setGranularity: (option<string> => option<string>) => unit,
}

let defaultActions = {
  setTopChartVisible: _ => (),
  setBottomChartVisible: _ => (),
  setGranularity: _ => (),
}

let chartActionsContext = React.createContext(defaultActions)

module Provider = {
  let make = React.Context.provider(chartActionsContext)
}

@react.component
let make = (~children, ~chartEntity: DynamicChart.entity, ~chartId="", ~defaultFilter=?) => {
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let getAllFilter = filterValueJson
  let (activeTab, activeTabStr) = React.useMemo(() => {
    let activeTabOptionalArr =
      getAllFilter->getOptionStrArrayFromDict(`${chartEntity.moduleName}.tabName`)
    (activeTabOptionalArr, activeTabOptionalArr->Option.getOr([])->Array.joinWith(","))
  }, [getAllFilter])

  let parentToken = AuthWrapperUtils.useTokenParent(Original)
  let addLogsAroundFetch = AnalyticsLogUtilsHook.useAddLogsAroundFetchNew()
  let betaEndPointConfig = React.useContext(BetaEndPointConfigProvider.betaEndPointConfig)
  let fetchApi = AuthHooks.useApiFetcher()
  let jsonTransFormer = switch chartEntity {
  | {jsonTransformer} => jsonTransformer
  | _ => (_val, arr) => arr
  }

  // Recoil setters for chart data (instead of React.useState)
  let setTopChartData = Recoil.useSetRecoilState(ChartAtoms.topChartDataAtom)
  let setBottomChartData = Recoil.useSetRecoilState(ChartAtoms.bottomChartDataAtom)
  let setTopChartDataLegendData = Recoil.useSetRecoilState(ChartAtoms.topChartLegendDataAtom)
  let setBottomChartDataLegendData = Recoil.useSetRecoilState(ChartAtoms.bottomChartLegendDataAtom)

  // Local state for visibility and granularity (synced to Recoil)
  let (topChartVisible, setTopChartVisibleLocal) = React.useState(_ => false)
  let (bottomChartVisible, setBottomChartVisibleLocal) = React.useState(_ => false)
  let (granularity, setGranularityLocal) = React.useState(_ => None)

  // Recoil setters for configuration (synced from local state)
  let setGranularityAtom = Recoil.useSetRecoilState(ChartAtoms.granularityAtom)
  let setTopChartVisibleAtom = Recoil.useSetRecoilState(ChartAtoms.topChartVisibleAtom)
  let setBottomChartVisibleAtom = Recoil.useSetRecoilState(ChartAtoms.bottomChartVisibleAtom)

  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let getGranularity = LineChartUtils.getGranularityNewStr
  let {filterValue} = React.useContext(FilterContext.filterContext)
  let (currentTopMatrix, currentBottomMetrix) = chartEntity.currentMetrics
  let (startTimeFilterKey, endTimeFilterKey) = chartEntity.dateFilterKeys
  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]

  let {allFilterDimension} = chartEntity
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let sortingParams = React.useMemo((): option<AnalyticsNewUtils.sortedBasedOn> => {
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
  let getTopLevelChartFilter = React.useMemo(() => {
    getAllFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Array.get(0)->Option.getOr("")
      if prefix === chartId && prefix->isNonEmptyString {
        None
      } else {
        Some((prefix, value))
      }
    })
    ->Dict.fromArray
  }, [getAllFilter])

  let (topFiltersToSearchParam, customFilter) = React.useMemo(() => {
    let filterSearchParam =
      getTopLevelChartFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        if allFilterKeys->Array.includes(key) {
          switch value->JSON.Classify.classify {
          | String(str) => `${key}=${str}`->Some
          | Number(num) => `${key}=${num->String.make}`->Some
          | Array(arr) => `${key}=[${arr->String.make}]`->Some
          | _ => None
          }
        } else {
          None
        }
      })
      ->Array.joinWith("&")

    (filterSearchParam, getTopLevelChartFilter->getString(customFilterKey, ""))
  }, [getTopLevelChartFilter])
  let customFilter = switch defaultFilter {
  | Some(defaultFilter) =>
    customFilter->isEmptyString ? defaultFilter : `${defaultFilter} and ${customFilter}`
  | _ => customFilter
  }

  let getChartCompFilters = React.useMemo(() => {
    getAllFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Array.get(0)->Option.getOr("")
      let fitlerName = keyArr->Array.get(1)->Option.getOr("")

      // when chart id is not there then there won't be any prefix so the prefix will the filter name
      if chartId->isEmptyString {
        Some((prefix, value))
      } else if prefix === chartId && fitlerName->isNonEmptyString {
        Some((fitlerName, value))
      } else {
        None
      }
    })
    ->Dict.fromArray
  }, [getAllFilter])

  let (startTimeFromUrl, endTimeFromUrl, filterValueFromUrl) = React.useMemo(() => {
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
      ->JSON.Encode.object
      ->Some
    (startTimeFromUrl, endTimeFromUrl, filterValueFromUrl)
  }, [topFiltersToSearchParam])

  let cardinalityFromUrl = getChartCompFilters->getString("cardinality", "TOP_5")
  let chartTopMetricFromUrl = getChartCompFilters->getString("chartTopMetric", currentTopMatrix)
  let chartBottomMetricFromUrl =
    getChartCompFilters->getString("chartBottomMetric", currentBottomMetrix)

  let current_granularity = if (
    startTimeFromUrl->isNonEmptyString && endTimeFromUrl->isNonEmptyString
  ) {
    getGranularity(~startTime=startTimeFromUrl, ~endTime=endTimeFromUrl)
  } else {
    []
  }

  // Sync local state to Recoil atoms
  React.useEffect(() => {
    setGranularityAtom(_ => granularity)
    None
  }, [granularity])

  React.useEffect(() => {
    setTopChartVisibleAtom(_ => topChartVisible)
    None
  }, [topChartVisible])

  React.useEffect(() => {
    setBottomChartVisibleAtom(_ => bottomChartVisible)
    None
  }, [bottomChartVisible])

  React.useEffect(() => {
    setGranularityLocal(prev => {
      current_granularity->Array.includes(prev->Option.getOr(""))
        ? prev
        : current_granularity->Array.get(0)
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

  React.useEffect(() => {
    let chartType =
      getChartCompFilters->getString(
        "chartType",
        chartEntity.chartTypes->Array.get(0)->Option.getOr(Line)->DynamicChart.chartMapper,
      )
    if (
      startTimeFromUrl->isNonEmptyString &&
      endTimeFromUrl->isNonEmptyString &&
      parentToken->Option.isSome &&
      (granularity->Option.isSome || chartType !== "Line Chart") &&
      current_granularity->Array.includes(granularity->Option.getOr(""))
    ) {
      setTopChartFetchWithCurrentDependecyChange(_ => false)
    }

    None
  }, (
    parentToken,
    current_granularity->Array.joinWith("-") ++
    granularity->Option.getOr("") ++
    cardinalityFromUrl ++
    chartTopMetricFromUrl ++
    customFilter ++
    startTimeFromUrl ++
    endTimeFromUrl,
    activeTabStr,
    filterValueFromUrl,
    sortingParams,
  ))

  React.useEffect(() => {
    let chartType =
      getChartCompFilters->getString(
        "chartType",
        chartEntity.chartTypes->Array.get(0)->Option.getOr(Line)->DynamicChart.chartMapper,
      )
    if (
      startTimeFromUrl->isNonEmptyString &&
      endTimeFromUrl->isNonEmptyString &&
      parentToken->Option.isSome &&
      (granularity->Option.isSome || chartType !== "Line Chart") &&
      current_granularity->Array.includes(granularity->Option.getOr(""))
    ) {
      setBottomChartFetchWithCurrentDependecyChange(_ => false)
    }

    None
  }, (
    parentToken,
    current_granularity->Array.joinWith("-") ++
    granularity->Option.getOr("") ++
    chartBottomMetricFromUrl ++
    startTimeFromUrl ++
    cardinalityFromUrl ++
    customFilter ++
    endTimeFromUrl,
    activeTabStr,
    filterValueFromUrl,
    sortingParams,
  ))

  // Fetch top chart data and write to Recoil atoms
  React.useEffect(() => {
    if !topChartFetchWithCurrentDependecyChange && topChartVisible {
      setTopChartFetchWithCurrentDependecyChange(_ => true)

      switch chartEntity.uriConfig->Array.find(item => {
        let metrics = switch item.metrics->Array.get(0) {
        | Some(metrics) => metrics.metric_label
        | None => ""
        }
        metrics === chartTopMetricFromUrl
      }) {
      | Some(value) => {
          setTopChartDataLegendData(_ => Loading)
          setTopChartData(_ => Loading)
          let cardinality = ChartContext.cardinalityMapperToNumber(Some(cardinalityFromUrl))
          let timeObj = Dict.fromArray([
            ("start", startTimeFromUrl->JSON.Encode.string),
            ("end", endTimeFromUrl->JSON.Encode.string),
          ])
          let (metric, secondaryMetrics) = switch value.metrics->Array.get(0) {
          | Some(metrics) => (metrics.metric_name_db, metrics.secondryMetrics)
          | None => ("", None)
          }
          let timeCol = value.timeCol

          let metricsArr = switch secondaryMetrics {
          | Some(value) => [value.metric_name_db, metric]
          | None => [metric]
          }

          let granularityConfig =
            granularity->Option.getOr("")->ChartContext.getGranularityMapper

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
                ~domain=value.domain->Option.getOr(""),
              )->JSON.stringify,
              ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
              ~betaEndpointConfig=?betaEndPointConfig,
              ~xFeatureRoute,
              ~forceCookies,
              ~merchantId,
              ~profileId,
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
                    ->JSON.Encode.object
                  },
                )
                resolve(jsonTransFormer(metric, jsonObj)->JSON.Encode.array)
              },
            )
            ->catch(
              _err => {
                resolve(JSON.Encode.null)
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
                    ~dictKey=Array.concat(activeTab->Option.getOr([]), ["time"]),
                  )->JSON.Encode.array,
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
              ~domain=value.domain->Option.getOr(""),
            )->JSON.stringify,
            ~headers=[("QueryType", "Chart Legend")]->Dict.fromArray,
            ~betaEndpointConfig=?betaEndPointConfig,
            ~xFeatureRoute,
            ~forceCookies,
            ~merchantId,
            ~profileId,
          )
          ->addLogsAroundFetch(~logTitle=`Chart legend Data`)
          ->then(text => {
            let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)->JSON.Encode.array
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

  // Fetch bottom chart data and write to Recoil atoms
  React.useEffect(() => {
    if !bottomChartFetchWithCurrentDependecyChange && bottomChartVisible {
      setBottomChartFetchWithCurrentDependecyChange(_ => true)
      switch chartEntity.uriConfig->Array.find(item => {
        let metrics = switch item.metrics->Array.get(0) {
        | Some(metrics) => metrics.metric_label
        | None => ""
        }
        metrics === chartBottomMetricFromUrl
      }) {
      | Some(value) => {
          setBottomChartDataLegendData(_ => Loading)
          setBottomChartData(_ => Loading)

          let cardinality = ChartContext.cardinalityMapperToNumber(Some(cardinalityFromUrl))
          let timeObj = Dict.fromArray([
            ("start", startTimeFromUrl->JSON.Encode.string),
            ("end", endTimeFromUrl->JSON.Encode.string),
          ])
          let (metric, secondaryMetrics) = switch value.metrics->Array.get(0) {
          | Some(metrics) => (metrics.metric_name_db, metrics.secondryMetrics)
          | None => ("", None)
          }
          let metricsArr = switch secondaryMetrics {
          | Some(value) => [value.metric_name_db, metric]
          | None => [metric]
          }
          let timeCol = value.timeCol

          let granularityConfig =
            granularity->Option.getOr("")->ChartContext.getGranularityMapper
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
                ~domain=value.domain->Option.getOr(""),
              )->JSON.stringify,
              ~headers=[("QueryType", "Chart Time Series")]->Dict.fromArray,
              ~betaEndpointConfig=?betaEndPointConfig,
              ~xFeatureRoute,
              ~forceCookies,
              ~merchantId,
              ~profileId,
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
                    ->JSON.Encode.object
                  },
                )
                resolve(jsonTransFormer(metric, jsonObj)->JSON.Encode.array)
              },
            )
            ->catch(
              _err => {
                resolve(JSON.Encode.null)
              },
            )
          })
          ->Promise.all
          ->then(metricsArr => {
            let data =
              dataMerge(
                ~dataArr=metricsArr->Array.map(item => item->getArrayFromJson([])),
                ~dictKey=Array.concat(activeTab->Option.getOr([]), ["time"]),
              )->JSON.Encode.array

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
              ~domain=value.domain->Option.getOr(""),
            )->JSON.stringify,
            ~headers=[("QueryType", "Chart Legend")]->Dict.fromArray,
            ~betaEndpointConfig=?betaEndPointConfig,
            ~xFeatureRoute,
            ~forceCookies,
            ~merchantId,
            ~profileId,
          )
          ->addLogsAroundFetch(~logTitle=`Chart legend Data`)
          ->then(text => {
            let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)->JSON.Encode.array
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

  // Only expose stable action functions through context
  let actions = React.useMemo(() => {
    {
      setTopChartVisible: setTopChartVisibleLocal,
      setBottomChartVisible: setBottomChartVisibleLocal,
      setGranularity: setGranularityLocal,
    }
  }, ())

  <Provider value=actions> children </Provider>
}

// Hook for accessing chart actions (stable, won't cause re-renders)
let useChartActions = () => React.useContext(chartActionsContext)
