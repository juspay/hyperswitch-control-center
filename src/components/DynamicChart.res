type cardinality = Top_5 | Top_10
type granularity =
  | G_THIRTYSEC
  | G_ONEMIN
  | G_FIVEMIN
  | G_FIFTEENMIN
  | G_THIRTYMIN
  | G_ONEHOUR
  | G_ONEDAY
type chartEntity = {
  uri: string,
  metrics: array<LineChartUtils.metricsConfig>,
  groupByNames: option<array<string>>,
  start_time: string,
  end_time: string,
  filters: option<Js.Json.t>,
  granularityOpts: option<string>,
  delta: bool,
  startDateTime: string,
  cardinality: option<string>,
  mode: option<string>,
  prefix?: string,
  source: string,
  customFilter?: string,
}

let getTimeSeriesChart = (chartEntity: chartEntity) => {
  let metricsArr = chartEntity.metrics->Array.map(item => {
    item.metric_name_db
  })
  [
    AnalyticsUtils.getFilterRequestBody(
      ~groupByNames=chartEntity.groupByNames,
      ~granularity=chartEntity.granularityOpts,
      ~filter=chartEntity.filters,
      ~metrics=Some(metricsArr),
      ~delta=chartEntity.delta,
      ~startDateTime=chartEntity.start_time,
      ~endDateTime=chartEntity.end_time,
      ~cardinality=chartEntity.cardinality,
      ~mode=chartEntity.mode,
      ~customFilter=chartEntity.customFilter->Belt.Option.getWithDefault(""),
      ~prefix=chartEntity.prefix,
      ~source=chartEntity.source,
      (),
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}

let getLegendBody = (chartEntity: chartEntity) => {
  let metricsArr = chartEntity.metrics->Array.map(item => {
    item.metric_name_db
  })
  [
    AnalyticsUtils.getFilterRequestBody(
      ~groupByNames=chartEntity.groupByNames,
      ~filter=chartEntity.filters,
      ~metrics=Some(metricsArr),
      ~delta=chartEntity.delta,
      ~startDateTime=chartEntity.start_time,
      ~endDateTime=chartEntity.end_time,
      ~cardinality=chartEntity.cardinality,
      ~mode=chartEntity.mode,
      ~customFilter=chartEntity.customFilter->Belt.Option.getWithDefault(""),
      ~prefix=chartEntity.prefix,
      ~source=chartEntity.source,
      (),
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}

type chartUrl = String(string) | Func(Dict.t<Js.Json.t> => string)
type chartType = Line | Bar | SemiDonut | HorizontalBar | Funnel

type uriConfig = {
  uri: string,
  timeSeriesBody: chartEntity => string,
  legendBody?: chartEntity => string,
  metrics: array<LineChartUtils.metricsConfig>,
  timeCol: string,
  filterKeys: array<string>,
  prefix?: string,
  domain?: string,
}

type urlToDataMap = {
  metricsUrl: string,
  rawData: array<Js.Json.t>,
  legendData: array<Js.Json.t>,
}

type fetchDataConfig = {
  url: string,
  body: string,
  legendBody?: string,
  metrics: array<LineChartUtils.metricsConfig>,
  timeCol: string,
}
// a will be of time (xAxis = time, yAxis = float)
type entity = {
  uri: chartUrl,
  chartConfig: option<chartEntity>,
  allFilterDimension: array<string>,
  dateFilterKeys: (string, string),
  currentMetrics: (string, string),
  cardinality?: array<cardinality>,
  granularity: array<granularity>,
  chartTypes: array<chartType>,
  uriConfig: array<uriConfig>,
  moduleName: string,
  source: string,
  customFilterKey?: string,
  getGranularity?: (~startTime: string, ~endTime: string) => array<string>,
  enableLoaders?: bool,
  chartDescription?: string,
  sortingColumnLegend?: string,
  jsonTransformer?: (string, array<Js.Json.t>) => array<Js.Json.t>,
}

let chartMapper = str => {
  switch str {
  | Line => "Line chart"
  | Bar => "Bar Chart"
  | SemiDonut => "SemiDonut Chart"
  | HorizontalBar => "Horizontal Bar Chart"
  | Funnel => "Funnel Chart"
  }
}

type chartDimension = OneDimension | TwoDimension | ThreeDimension | No_Dims

let chartReverseMappers = str => {
  switch str {
  | "Line Chart" => Line
  | "Bar Chart" => Bar
  | "SemiDonut Chart" => SemiDonut
  | "Horizontal Bar Chart" => HorizontalBar
  | "Funnel Chart" => Funnel
  | _ => Line
  }
}

let makeEntity = (
  ~uri,
  ~chartConfig=?,
  ~filterKeys: array<string>=[],
  ~dateFilterKeys: (string, string),
  ~currentMetrics: (string, string),
  ~cardinality: option<array<cardinality>>=?,
  ~granularity=[G_ONEDAY],
  ~chartTypes=[Line],
  ~uriConfig,
  ~moduleName: string,
  ~source: string="BATCH",
  ~customFilterKey: option<string>=?,
  ~getGranularity: option<(~startTime: string, ~endTime: string) => array<string>>=?,
  ~enableLoaders: bool=true,
  ~chartDescription: option<string>=?,
  ~sortingColumnLegend: option<string>=?,
  ~jsonTransformer: option<(string, array<Js.Json.t>) => array<Js.Json.t>>=?,
  (),
) => {
  let granularity = granularity->Array.length === 0 ? [G_ONEDAY] : granularity
  let chartTypes = chartTypes->Array.length === 0 ? [Line] : chartTypes

  {
    uri,
    chartConfig,
    allFilterDimension: filterKeys,
    dateFilterKeys,
    currentMetrics,
    ?cardinality,
    granularity,
    chartTypes,
    uriConfig,
    moduleName,
    source,
    ?customFilterKey,
    ?getGranularity,
    enableLoaders,
    ?chartDescription,
    ?sortingColumnLegend,
    ?jsonTransformer,
  }
}

let useChartFetch = (~setStatusDict) => {
  let fetchApi = AuthHooks.useApiFetcher()
  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetch()
  let fetchChartData = (updatedChartBody: array<fetchDataConfig>, setState) => {
    open Promise

    updatedChartBody
    ->Array.map(item => {
      fetchApi(
        item.url,
        ~method_=Fetch.Post,
        ~bodyStr=item.body,
        ~headers=[("QueryType", "Chart")]->Dict.fromArray,
        (),
      )
      ->addLogsAroundFetch(~logTitle="Chart Data Api", ~setStatusDict)
      ->then(json => {
        // get total volume and time series and pass that on
        let dataRawTimeSeries =
          json
          ->LogicUtils.getDictFromJsonObject
          ->LogicUtils.getJsonObjectFromDict("queryData")
          ->LogicUtils.getArrayFromJson([])

        switch item {
        | {legendBody} =>
          fetchApi(
            item.url,
            ~method_=Fetch.Post,
            ~bodyStr=legendBody,
            ~headers=[("QueryType", "Chart")]->Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(~logTitle="Chart Data Api", ~setStatusDict)
          ->then(
            legendJson => {
              let dataRawLegend =
                legendJson
                ->LogicUtils.getDictFromJsonObject
                ->LogicUtils.getJsonObjectFromDict("queryData")
                ->LogicUtils.getArrayFromJson([])

              resolve(
                Some({
                  metricsUrl: item.url,
                  rawData: dataRawTimeSeries,
                  legendData: dataRawLegend,
                }),
              )
            },
          )
          ->catch(
            _err => {
              resolve(None)
            },
          )
        | _ =>
          resolve(
            Some({
              metricsUrl: item.url,
              rawData: dataRawTimeSeries,
              legendData: [],
            }),
          )
        }
      })
      ->catch(_err => {
        resolve(None)
      })
    })
    ->Promise.all
    ->thenResolve(dataArr => {
      let data = dataArr->Belt.Array.keepMap(item => item)

      setState(data)
    })
    ->catch(_err => resolve())
    ->ignore
  }
  fetchChartData
}

let cardinalityArr = ["TOP_5", "TOP_10"]
let chartTypeArr = [
  "Line chart",
  "Bar Chart",
  "SemiDonut Chart",
  "Horizontal Bar Chart",
  "Funnel Chart",
]

@react.component
let make = (
  ~entity,
  ~selectedTab: option<array<string>>,
  ~modeKey=?,
  ~chartId="",
  ~updateUrl=?,
  ~tabTitleMapper=?,
  ~enableBottomChart=true,
  ~showTableLegend=true,
  ~showMarkers=false,
  ~legendType: HighchartTimeSeriesChart.legendType=Table,
) => {
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let updateChartCompFilters = switch updateUrl {
  | Some(fn) => fn
  | None => _ => ()
  }

  let currentTheme = ThemeProvider.useTheme()
  let {filterValue} = React.useContext(FilterContext.filterContext)
  let (_switchToMobileView, setSwitchToMobileView) = React.useState(_ => false)
  let (selectedTabState, setSelectedTabState) = React.useState(_ => selectedTab)

  let customFilterKey = switch entity {
  | {customFilterKey} => customFilterKey
  | _ => ""
  }

  let getGranularity = switch entity {
  | {getGranularity} => getGranularity
  | _ => LineChartUtils.getGranularity
  }

  let getAllFilter =
    filterValue
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      (key, value->UrlFetchUtils.getFilterValue)
    })
    ->Dict.fromArray

  // with prefix only for charts
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

  // without prefix only for charts
  let getTopLevelFilter = React.useMemo1(() => {
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

  let mode = switch modeKey {
  | Some(modeKey) => Some(getTopLevelFilter->LogicUtils.getString(modeKey, ""))
  | None => Some("ORDER")
  }

  let {allFilterDimension, dateFilterKeys, currentMetrics, uriConfig, source} = entity

  let enableLoaders = entity.enableLoaders->Belt.Option.getWithDefault(true)

  let entityAllMetrics = uriConfig->Array.reduce([], (acc, item) =>
    Array.concat(
      acc,
      {
        item.metrics
      },
    )
  )

  let (currentTopMatrix, currentBottomMetrix) = currentMetrics
  // if we won't see anything in the url then we will update the url
  React.useEffect0(() => {
    let cardinality = getChartCompFilters->LogicUtils.getString("cardinality", "TOP_5")
    let chartType =
      getChartCompFilters->LogicUtils.getString(
        "chartType",
        entity.chartTypes->Belt.Array.get(0)->Belt.Option.getWithDefault(Line)->chartMapper,
      )
    let chartTopMetric =
      getChartCompFilters->LogicUtils.getString("chartTopMetric", currentTopMatrix)

    let chartBottomMetric =
      getChartCompFilters->LogicUtils.getString("chartBottomMetric", currentBottomMetrix)

    let dict = Dict.make()
    let chartMatrixArr = entityAllMetrics->Belt.Array.map(item => item.metric_label)

    if cardinalityArr->Array.includes(cardinality) {
      dict->Dict.set("cardinality", cardinality)
    } else if cardinalityArr->Array.includes("TOP_5") {
      dict->Dict.set("cardinality", "TOP_5")
    } else {
      dict->Dict.set(
        "cardinality",
        cardinalityArr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      )
    }
    chartTypeArr->Array.includes(chartType)
      ? dict->Dict.set("chartType", chartType)
      : dict->Dict.set("chartType", "Line chart")

    if chartMatrixArr->Array.includes(chartTopMetric) {
      dict->Dict.set("chartTopMetric", chartTopMetric)
    } else if chartMatrixArr->Array.includes(currentTopMatrix) {
      dict->Dict.set("chartTopMetric", currentTopMatrix)
    } else {
      dict->Dict.set(
        "chartTopMetric",
        chartMatrixArr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      )
    }

    if chartMatrixArr->Array.includes(chartBottomMetric) {
      dict->Dict.set("chartBottomMetric", chartBottomMetric)
    } else if chartMatrixArr->Array.includes(currentBottomMetrix) {
      dict->Dict.set("chartBottomMetric", currentBottomMetrix)
    } else {
      dict->Dict.set(
        "chartBottomMetric",
        chartMatrixArr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      )
    }

    updateChartCompFilters(dict)
    None
  })
  let chartDimensionView = switch selectedTabState {
  | Some(selectedTab) =>
    switch selectedTab->Array.length {
    | 1 => OneDimension
    | 2 => TwoDimension
    | 3 => ThreeDimension
    | _ => No_Dims
    }
  | None => No_Dims
  }
  let cardinalityFromUrl = getChartCompFilters->LogicUtils.getString("cardinality", "TOP_5")
  let chartTypeFromUrl = getChartCompFilters->LogicUtils.getString("chartType", "Line chart")
  let chartTopMetricFromUrl =
    getChartCompFilters->LogicUtils.getString("chartTopMetric", currentTopMatrix)
  let chartBottomMetricFromUrl =
    getChartCompFilters->LogicUtils.getString("chartBottomMetric", currentBottomMetrix)
  let (granularity, setGranularity) = React.useState(_ => None)
  let (rawChartData, setRawChartData) = React.useState(_ => None)
  let (shimmerType, setShimmerType) = React.useState(_ => AnalyticsUtils.Shimmer)
  let (groupKey, setGroupKey) = React.useState(_ => "")

  React.useEffect1(() => {
    if rawChartData !== None {
      setShimmerType(_ => SideLoader)
    }
    None
  }, [rawChartData])

  let (startTimeFilterKey, endTimeFilterKey) = dateFilterKeys

  let defaultFilters = switch modeKey {
  | Some(modeKey) => [startTimeFilterKey, endTimeFilterKey, modeKey]
  | None => [startTimeFilterKey, endTimeFilterKey]
  }

  let allFilterKeys = Array.concat(defaultFilters, allFilterDimension)

  let (topFiltersToSearchParam, customFilter) = React.useMemo1(() => {
    let filterSearchParam =
      getTopLevelFilter
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

    (filterSearchParam, getTopLevelFilter->LogicUtils.getString(customFilterKey, ""))
  }, [getTopLevelFilter])

  let (startTimeFilterKey, endTimeFilterKey) = dateFilterKeys

  let (isExpandedUpper, setIsExpandedUpper) = React.useState(_ => true)
  let (isExpandedLower, setIsExpandedLower) = React.useState(_ => true)
  let (chartLoading, setChartLoading) = React.useState(_ => true)
  let (chartToggleKey, setChartToggleKey) = React.useState(_ => false)
  let toggleKey = React.useMemo1(() => {chartToggleKey ? "0" : "1"}, [chartToggleKey])
  // By default, total_volume metric will always be there

  let isMobileView = MatchMedia.useMobileChecker()

  React.useEffect1(() => {
    setSwitchToMobileView(prev => prev || isMobileView)
    None
  }, [isMobileView])
  let (statusDict, setStatusDict) = React.useState(_ => Dict.make())
  let fetchChartData = useChartFetch(~setStatusDict)

  let startTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->LogicUtils.getString(startTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->LogicUtils.getString(endTimeFilterKey, "")
  }, [topFiltersToSearchParam])

  let topFiltersToSearchParam = React.useMemo1(() => {
    let filterSearchParam =
      getTopLevelFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        switch value->Js.Json.classify {
        | JSONString(str) => `${key}=${str}`->Some
        | JSONNumber(num) => `${key}=${num->String.make}`->Some
        | JSONArray(arr) => `${key}=[${arr->String.make}]`->Some
        | _ => None
        }
      })
      ->Array.joinWith("&")

    filterSearchParam
  }, [topFiltersToSearchParam])

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
  let selectedTabStr = selectedTab->Belt.Option.getWithDefault([])->Array.joinWith("")

  let updatedChartConfigArr = React.useMemo7(() => {
    uriConfig->Array.map(item => {
      let filterKeys =
        item.filterKeys->Array.filter(item => allFilterDimension->Array.includes(item))
      let filterValue =
        getTopLevelFilter
        ->Dict.toArray
        ->Belt.Array.keepMap(
          entries => {
            let (key, value) = entries
            filterKeys->Array.includes(key) ? Some((key, value)) : None
          },
        )
        ->Dict.fromArray
      let activeTab =
        selectedTab
        ->Belt.Option.getWithDefault([])
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault("")
      let granularity = if activeTab === "run_date" {
        "G_ONEHOUR"->Some
      } else if activeTab === "run_week" {
        "G_ONEDAY"->Some
      } else if activeTab === "run_month" {
        Some("G_ONEDAY")
      } else {
        granularity
      }

      {
        uri: item.uri,
        metrics: item.metrics,
        groupByNames: selectedTab,
        start_time: startTimeFromUrl,
        end_time: endTimeFromUrl,
        filters: Some(Js.Json.object_(filterValue)),
        granularityOpts: granularity,
        delta: false,
        startDateTime: startTimeFromUrl,
        cardinality: Some(cardinalityFromUrl),
        customFilter,
        mode,
        prefix: ?item.prefix,
        source,
      }
    })
  }, (
    startTimeFromUrl,
    endTimeFromUrl,
    customFilter,
    topFiltersToSearchParam,
    cardinalityFromUrl,
    selectedTabStr,
    granularity,
  ))

  let updatedChartBody = React.useMemo1(() => {
    uriConfig->Belt.Array.keepMap(item => {
      switch updatedChartConfigArr->Array.find(config => config.uri === item.uri) {
      | Some(chartconfig) => {
          let legendBody = switch item {
          | {legendBody} => Some(legendBody(chartconfig))
          | _ => None
          }
          let value: fetchDataConfig = {
            url: item.uri,
            body: item.timeSeriesBody(chartconfig),
            legendBody: ?(
              chartconfig.groupByNames->Belt.Option.getWithDefault([])->Array.length === 1
                ? legendBody
                : None
            ),
            metrics: item.metrics,
            timeCol: item.timeCol,
          }

          Some(value)
        }

      | None => None
      }
    })
  }, [updatedChartConfigArr])

  let (groupKeyFromTab, titleKey) = React.useMemo1(() => {
    switch (tabTitleMapper, selectedTab) {
    | (Some(dict), Some(arr)) => {
        let groupKey = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        (groupKey, dict->Dict.get(groupKey)->Belt.Option.getWithDefault(groupKey))
      }
    | (None, Some(arr)) => (
        arr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        arr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
      )
    | _ => ("", "")
    }
  }, [selectedTab])

  let setRawChartData = (data: array<urlToDataMap>) => {
    let chartData = data->Array.map(mappedData => {
      let rawdata = mappedData.rawData->Array.map(item => {
        let dict = item->Js.Json.decodeObject->Belt.Option.getWithDefault(Dict.make())

        switch dict->Dict.get("time_range") {
        | Some(jsonObj) => {
            let timeDict = jsonObj->LogicUtils.getDictFromJsonObject

            switch timeDict->Dict.get("startTime") {
            | Some(startValue) => {
                let sTime = startValue->Js.Json.decodeString->Belt.Option.getWithDefault("")

                if sTime->String.length > 0 {
                  let {date, hour, minute, month, second, year} =
                    sTime->Js.Date.fromString->Js.Date.toISOString->isoStringToCustomTimeZone

                  dict->Dict.set(
                    "time_bucket",
                    `${year}-${month}-${date} ${hour}:${minute}:${second}`->Js.Json.string,
                  )
                }
              }
            | None => ()
            }
          }
        | None => ()
        }

        selectedTab
        ->Belt.Option.getWithDefault([])
        ->Array.forEach(
          tabName => {
            let metric =
              Dict.get(dict, tabName)
              ->Belt.Option.getWithDefault(""->Js.Json.string)
              ->Js.Json.decodeString
              ->Belt.Option.getWithDefault("")
            let label = metric == "" ? "other" : metric

            Dict.set(dict, tabName, label->Js.Json.string)

            Dict.keysToArray(dict)->Array.forEach(
              key => {
                if key->String.includes("amount") {
                  let amount =
                    Dict.get(dict, key)
                    ->Belt.Option.getWithDefault(Js.Json.number(0.0))
                    ->Js.Json.decodeNumber
                    ->Belt.Option.getWithDefault(0.0)

                  let amount = (amount /. 100.0)->Js.Float.toFixedWithPrecision(~digits=2)

                  Dict.set(dict, key, amount->Js.Float.fromString->Js.Json.number)
                } else if !(key->String.includes("time")) && key != tabName {
                  switch Dict.get(dict, key) {
                  | Some(val) =>
                    switch val->Js.Json.decodeNumber {
                    | Some(val2) =>
                      Dict.set(
                        dict,
                        key,
                        val2->Js.Float.toFixedWithPrecision(~digits=2)->Js.Json.string,
                      )
                    | None => ()
                    }
                  | None => ()
                  }
                }
              },
            )
          },
        )
        dict->Js.Json.object_
      })
      {
        metricsUrl: mappedData.metricsUrl,
        rawData: rawdata,
        legendData: mappedData.legendData,
      }
    })

    setGroupKey(_ => groupKeyFromTab)
    setSelectedTabState(_ => selectedTab)
    setRawChartData(_ => Some(chartData))
    setChartLoading(_ => false)
  }
  React.useEffect1(() => {
    if !chartLoading {
      setChartToggleKey(prev => !prev)
    }
    None
  }, [chartLoading])

  React.useEffect1(() => {
    let chartType =
      getChartCompFilters->LogicUtils.getString(
        "chartType",
        entity.chartTypes->Belt.Array.get(0)->Belt.Option.getWithDefault(Line)->chartMapper,
      )
    if (
      startTimeFromUrl !== "" &&
      endTimeFilterKey !== "" &&
      (granularity->Belt.Option.isSome || chartType !== "Line Chart") &&
      current_granularity->Array.includes(granularity->Belt.Option.getWithDefault(""))
    ) {
      setChartLoading(_ => enableLoaders)
      fetchChartData(updatedChartBody, setRawChartData)
    }
    None
  }, [updatedChartBody])
  let transformMetric = (arr: array<LineChartUtils.metricsConfig>) => {
    arr->Array.map(item => {
      let a: SelectBox.dropdownOption = {
        label: item.metric_label,
        value: item.metric_label,
      }
      a
    })
  }
  let inputMetricTop: ReactFinalForm.fieldRenderPropsInput = {
    name: "inputMetricTop",
    onChange: ev => {
      updateChartCompFilters(
        Dict.fromArray([("chartTopMetric", ev->Identity.formReactEventToString)]),
      )
    },
    value: chartTopMetricFromUrl->Js.Json.string,
    onBlur: _ev => (),
    onFocus: _ev => (),
    checked: true,
  }
  let inputMetricBottom: ReactFinalForm.fieldRenderPropsInput = {
    name: "inputMetricBottom",
    onChange: ev => {
      updateChartCompFilters(
        Dict.fromArray([("chartBottomMetric", ev->Identity.formReactEventToString)]),
      )
    },
    value: chartBottomMetricFromUrl->Js.Json.string,
    onBlur: _ev => (),
    onFocus: _ev => (),
    checked: true,
  }

  // Note need to add the granularity for the charts
  let dropDownButtonTextStyle = "font-medium text-jp-gray-900 dark:text-white"
  let customButtonStyle = "dark:bg-inherit"

  let metricsDropDown = React.useMemo2(() => {
    transformMetric(entityAllMetrics)
  }, (entityAllMetrics, isMobileView))

  let metricPickerdisplayClass =
    [SemiDonut, HorizontalBar, Funnel]->Array.includes(chartTypeFromUrl->chartReverseMappers)
      ? "hidden"
      : ""

  if statusDict->Dict.valuesToArray->Array.includes(504) {
    <AnalyticsUtils.NoDataFoundPage />
  } else {
    <div>
      <ReactFinalForm.Form
        subscription=ReactFinalForm.subscribeToValues
        onSubmit={(_, _) => Js.Nullable.null->Promise.resolve}
        render={({handleSubmit}) => {
          <form onSubmit={handleSubmit}>
            <AddDataAttributes attributes=[("data-chart-segment", "Chart-1")]>
              <div
                className="border rounded  bg-white  border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 dynamicChart">
                <div
                  className={`flex flex-row border-b w-full border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 text-gray-500 px-4 py-2 ${metricPickerdisplayClass}`}>
                  <div className="w-3/4 flex justify-between">
                    <div>
                      <SelectBox
                        input=inputMetricTop
                        searchable=false
                        options={metricsDropDown}
                        buttonType={currentTheme === Light ? Button.Secondary : Button.Pagination}
                        showBorder=false
                        textStyle={`!text-fs-13 !${dropDownButtonTextStyle}`}
                        customButtonStyle={`metricButton ${customButtonStyle}`}
                        buttonText="Choose Metric"
                        fixedDropDownDirection=SelectBox.BottomRight
                      />
                    </div>
                    <div />
                  </div>
                  <div className="w-1/4 flex items-center justify-end">
                    {if chartLoading && shimmerType === SideLoader {
                      <div className="animate-spin mb-4 flex-end">
                        <Icon name="spinner" size=20 />
                      </div>
                    } else {
                      <div
                        className="cursor-pointer pt-2"
                        onClick={_ => {
                          setChartLoading(_ => false)
                          setIsExpandedUpper(cont => !cont)
                        }}>
                        <div
                          className={isMobileView
                            ? ""
                            : "flex flex-col justify-center -ml-8 -mb-5"}>
                          <Icon name={isExpandedUpper ? "collpase-alt" : "expand-alt"} size=15 />
                        </div>
                        {if isMobileView {
                          React.null
                        } else {
                          let text = isExpandedUpper ? "Collapse" : "Expand"
                          <AddDataAttributes attributes=[("data-text", text)]>
                            <div> {React.string(text)} </div>
                          </AddDataAttributes>
                        }}
                      </div>
                    }}
                  </div>
                </div>
                {if chartLoading && shimmerType === Shimmer {
                  <Shimmer styleClass="w-full h-96 dark:bg-black bg-white" shimmerType={Big} />
                } else if isExpandedUpper {
                  switch entityAllMetrics
                  ->Array.filter(item => item.metric_label === chartTopMetricFromUrl)
                  ->Belt.Array.get(0) {
                  | Some(selectedMetrics) =>
                    let metricsUri = uriConfig->Array.find(uriMetrics => {
                      uriMetrics.metrics
                      ->Array.map(item => {item.metric_label})
                      ->Array.includes(selectedMetrics.metric_label)
                    })
                    let (data, legendData, timeCol) = switch metricsUri {
                    | Some(val) =>
                      switch rawChartData
                      ->Belt.Option.getWithDefault([])
                      ->Array.find(item => item.metricsUrl === val.uri) {
                      | Some(dataVal) => (dataVal.rawData, dataVal.legendData, val.timeCol)
                      | None => ([], [], "")
                      }
                    | None => ([], [], "")
                    }
                    switch chartTypeFromUrl->chartReverseMappers {
                    | Line =>
                      switch chartDimensionView {
                      | OneDimension =>
                        <HighchartTimeSeriesChart.LineChart1D
                          class="flex overflow-scroll"
                          rawChartData=data
                          selectedMetrics
                          chartPlace="top_"
                          xAxis=timeCol
                          groupKey
                          chartTitle=false
                          key={toggleKey}
                          legendData
                          showTableLegend
                          showMarkers
                          legendType
                        />

                      | TwoDimension =>
                        <HighchartTimeSeriesChart.LineChart2D
                          rawChartData=data
                          selectedMetrics
                          xAxis=timeCol
                          groupBy=selectedTabState
                          key={toggleKey}
                          // legendData
                        />
                      | ThreeDimension =>
                        <HighchartTimeSeriesChart.LineChart3D
                          rawChartData=data
                          selectedMetrics
                          xAxis=timeCol
                          groupBy=selectedTabState
                          chartKey={toggleKey}
                          // legendData
                        />
                      | No_Dims => React.null
                      }

                    | Bar =>
                      <div className="">
                        <HighchartBarChart.HighBarChart1D
                          rawData=data groupKey selectedMetrics key={toggleKey}
                        />
                      </div>
                    | SemiDonut =>
                      <div className="m-4">
                        <HighchartPieChart
                          rawData=data groupKey titleKey selectedMetrics key={toggleKey}
                        />
                      </div>
                    | HorizontalBar =>
                      <div className="m-4">
                        <HighchartHorizontalBarChart
                          rawData=data groupKey titleKey selectedMetrics key={toggleKey}
                        />
                      </div>
                    | Funnel =>
                      <FunnelChart
                        data
                        metrics={entityAllMetrics}
                        moduleName={entity.moduleName}
                        description={entity.chartDescription}
                      />
                    }
                  | None => React.null
                  }
                } else {
                  React.null
                }}
              </div>
            </AddDataAttributes>
          </form>
        }}
      />
      {if enableBottomChart {
        switch entityAllMetrics
        ->Array.filter(item => item.metric_label === chartBottomMetricFromUrl)
        ->Belt.Array.get(0) {
        | Some(selectedMetrics) =>
          let metricsUri = uriConfig->Array.find(uriMetrics => {
            uriMetrics.metrics
            ->Array.map(item => {item.metric_label})
            ->Array.includes(selectedMetrics.metric_label)
          })
          let (data, legendData, timeCol) = switch metricsUri {
          | Some(val) =>
            switch rawChartData
            ->Belt.Option.getWithDefault([])
            ->Array.find(item => item.metricsUrl === val.uri) {
            | Some(dataVal) => (dataVal.rawData, dataVal.legendData, val.timeCol)
            | None => ([], [], "")
            }
          | None => ([], [], "")
          }
          if !isMobileView {
            <AddDataAttributes attributes=[("data-chart-segment", "Chart-2")]>
              <div
                className="mt-5 rounded bg-white border dark:border-jp-gray-960 dark:bg-jp-gray-950">
                <div
                  className="flex flex-row justify-between dark:border-jp-gray-960 dark:bg-jp-gray-950 text-gray-500 p-4 py-2 border-b rounded  bg-white  border-jp-gray-500">
                  <div className="flex flex-row w-3/4 justify-center">
                    <div style={ReactDOM.Style.make(~flexBasis="16%", ())} className="gap-1">
                      <div />
                      <div />
                    </div>
                    <div>
                      <SelectBox
                        input=inputMetricBottom
                        searchable=false
                        options={metricsDropDown}
                        buttonType={currentTheme === Light ? Button.Secondary : Button.Pagination}
                        showBorder=false
                        textStyle={`text-fs-13 ${dropDownButtonTextStyle}`}
                        customButtonStyle={`metricButton ${customButtonStyle}`}
                        buttonText="Choose Metric"
                        fixedDropDownDirection=SelectBox.BottomRight
                      />
                    </div>
                  </div>
                  <div className="w-1/4 flex items-center justify-end">
                    {if chartLoading && shimmerType === SideLoader {
                      <div className="animate-spin mb-5 flex-end">
                        <Icon name="spinner" size=20 />
                      </div>
                    } else {
                      let text = isExpandedLower ? "Collapse" : "Expand"
                      <div
                        className="cursor-pointer"
                        onClick={_ => {setIsExpandedLower(cont => !cont)}}>
                        <div className="flex flex-col justify-center -ml-8 -mb-5">
                          <Icon name={isExpandedLower ? "collpase-alt" : "expand-alt"} size=15 />
                        </div>
                        <AddDataAttributes attributes=[("data-text", text)]>
                          <div> {React.string(text)} </div>
                        </AddDataAttributes>
                      </div>
                    }}
                  </div>
                </div>
                {if chartLoading && shimmerType === Shimmer {
                  <Shimmer styleClass="w-full h-96" shimmerType={Big} />
                } else if isExpandedLower {
                  switch chartDimensionView {
                  | OneDimension =>
                    <HighchartTimeSeriesChart.LineChart1D
                      class="flex rounded overflow-scroll bg-white border-t-0  border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950"
                      rawChartData=data
                      selectedMetrics
                      chartPlace="bottom_"
                      xAxis=timeCol
                      groupKey
                      chartTitle=false
                      chartKey={toggleKey}
                      legendData
                      showMarkers
                      chartTitleText={selectedMetrics.metric_label ++ "-2"}
                      legendType
                    />

                  | TwoDimension =>
                    <HighchartTimeSeriesChart.LineChart2D
                      class="flex rounded overflow-scroll bg-white border-t-0 border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950"
                      rawChartData=data
                      selectedMetrics
                      xAxis=timeCol
                      groupBy=selectedTabState
                      chartKey={toggleKey}
                    />
                  | ThreeDimension =>
                    <HighchartTimeSeriesChart.LineChart3D
                      class="flex rounded overflow-scroll bg-white border-t-0 border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950"
                      rawChartData=data
                      selectedMetrics
                      xAxis=timeCol
                      groupBy=selectedTabState
                      chartKey={toggleKey}
                    />
                  | No_Dims => React.null
                  }
                } else {
                  React.null
                }}
              </div>
            </AddDataAttributes>
          } else {
            React.null
          }
        | None => React.null
        }
      } else {
        React.null
      }}
    </div>
  }
}
