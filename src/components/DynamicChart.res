open LogicUtils

type cardinality = Top_5 | Top_10
type granularity =
  | G_THIRTYSEC
  | G_ONEMIN
  | G_FIVEMIN
  | G_FIFTEENMIN
  | G_THIRTYMIN
  | G_ONEHOUR
  | G_ONEDAY

let getGranularityString = granularity => {
  switch granularity {
  | G_THIRTYSEC => "G_THIRTYSEC"
  | G_ONEMIN => "G_ONEMIN"
  | G_FIVEMIN => "G_FIVEMIN"
  | G_FIFTEENMIN => "G_FIFTEENMIN"
  | G_THIRTYMIN => "G_THIRTYMIN"
  | G_ONEHOUR => "G_ONEHOUR"
  | G_ONEDAY => "G_ONEDAY"
  }
}

let getGranularityFormattedText = granularity => {
  switch granularity {
  | G_THIRTYSEC => "THIRTY SEC"
  | G_ONEMIN => "ONE MIN"
  | G_FIVEMIN => "FIVE MIN"
  | G_FIFTEENMIN => "FIFTEEN MIN"
  | G_THIRTYMIN => "THIRTY MIN"
  | G_ONEHOUR => "ONE HOUR"
  | G_ONEDAY => "ONE DAY"
  }
}

let getGranularity = (~startTime, ~endTime) => {
  let diff =
    (endTime->DateTimeUtils.parseAsFloat -. startTime->DateTimeUtils.parseAsFloat) /. (1000. *. 60.) // in minutes

  // startTime
  if diff < 60. *. 6. {
    // Smaller than 6 hour
    [G_FIFTEENMIN, G_FIVEMIN]
  } else if diff < 60. *. 24. {
    // Smaller than 1 day
    [G_ONEHOUR, G_THIRTYMIN, G_FIFTEENMIN, G_FIVEMIN]
  } else {
    [G_ONEDAY, G_ONEHOUR, G_THIRTYMIN, G_FIFTEENMIN, G_FIVEMIN]
  }
}

type chartEntity = {
  uri: string,
  metrics: array<LineChartUtils.metricsConfig>,
  groupByNames: option<array<string>>,
  start_time: string,
  end_time: string,
  filters: option<JSON.t>,
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
      ~customFilter=chartEntity.customFilter->Option.getOr(""),
      ~prefix=chartEntity.prefix,
      ~source=chartEntity.source,
    )->JSON.Encode.object,
  ]
  ->JSON.Encode.array
  ->JSON.stringify
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
      ~customFilter=chartEntity.customFilter->Option.getOr(""),
      ~prefix=chartEntity.prefix,
      ~source=chartEntity.source,
    )->JSON.Encode.object,
  ]
  ->JSON.Encode.array
  ->JSON.stringify
}

type chartUrl = String(string) | Func(Dict.t<JSON.t> => string)
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
  rawData: array<JSON.t>,
  legendData: array<JSON.t>,
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
  jsonTransformer?: (string, array<JSON.t>) => array<JSON.t>,
  disableGranularity?: bool,
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
  ~jsonTransformer: option<(string, array<JSON.t>) => array<JSON.t>>=?,
  ~disableGranularity=?,
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
    ?disableGranularity,
  }
}

let useChartFetch = (~setStatusDict) => {
  let fetchApi = AuthHooks.useApiFetcher()
  let addLogsAroundFetch = AnalyticsLogUtilsHook.useAddLogsAroundFetch()
  let fetchChartData = (updatedChartBody: array<fetchDataConfig>, setState) => {
    open Promise

    updatedChartBody
    ->Array.map(item => {
      fetchApi(
        item.url,
        ~method_=Post,
        ~bodyStr=item.body,
        ~headers=[("QueryType", "Chart")]->Dict.fromArray,
      )
      ->addLogsAroundFetch(~logTitle="Chart Data Api", ~setStatusDict)
      ->then(json => {
        // get total volume and time series and pass that on
        let dataRawTimeSeries =
          json->getDictFromJsonObject->getJsonObjectFromDict("queryData")->getArrayFromJson([])

        switch item {
        | {legendBody} =>
          fetchApi(
            item.url,
            ~method_=Post,
            ~bodyStr=legendBody,
            ~headers=[("QueryType", "Chart")]->Dict.fromArray,
          )
          ->addLogsAroundFetch(~logTitle="Chart Data Api", ~setStatusDict)
          ->then(
            legendJson => {
              let dataRawLegend =
                legendJson
                ->getDictFromJsonObject
                ->getJsonObjectFromDict("queryData")
                ->getArrayFromJson([])

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

module GranularitySelectBox = {
  @react.component
  let make = (~selectedGranularity, ~setSelectedGranularity, ~startTime, ~endTime) => {
    let options = getGranularity(~startTime, ~endTime)

    open HeadlessUI
    <>
      <Menu \"as"="div" className="relative inline-block text-left">
        {_menuProps =>
          <div>
            <Menu.Button
              className="inline-flex whitespace-pre leading-5 justify-center text-sm  px-3 py-1 font-medium rounded-md hover:bg-opacity-80 bg-white border">
              {props => {
                let arrow = props["open"]
                <>
                  {selectedGranularity->getGranularityFormattedText->React.string}
                  <Icon
                    className={arrow
                      ? `rotate-0 transition duration-[250ms] ml-1 mt-1 opacity-60`
                      : `rotate-180 transition duration-[250ms] ml-1 mt-1 opacity-60`}
                    name="arrow-without-tail"
                    size=15
                  />
                </>
              }}
            </Menu.Button>
            <Transition
              \"as"="span"
              enter="transition ease-out duration-100"
              enterFrom="transform opacity-0 scale-95"
              enterTo="transform opacity-100 scale-100"
              leave="transition ease-in duration-75"
              leaveFrom="transform opacity-100 scale-100"
              leaveTo="transform opacity-0 scale-95">
              {<Menu.Items
                className="absolute right-0 z-50 w-36 mt-2 origin-top-right bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                {_props => {
                  <>
                    <div className="px-1 py-1 ">
                      {options
                      ->Array.mapWithIndex((option, i) =>
                        <Menu.Item key={i->Int.toString}>
                          {props =>
                            <div className="relative">
                              <button
                                onClick={_ => setSelectedGranularity(_ => option)}
                                className={
                                  let activeClasses = if props["active"] {
                                    "group flex rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-black"
                                  } else {
                                    "group flex rounded-md items-center w-full px-2 py-2 text-sm"
                                  }
                                  `${activeClasses} font-medium text-start`
                                }>
                                <div className="mr-5">
                                  {option->getGranularityFormattedText->React.string}
                                </div>
                              </button>
                            </div>}
                        </Menu.Item>
                      )
                      ->React.array}
                    </div>
                  </>
                }}
              </Menu.Items>}
            </Transition>
          </div>}
      </Menu>
    </>
  }
}

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
  ~comparitionWidget=false,
) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let updateChartCompFilters = switch updateUrl {
  | Some(fn) => fn
  | None => _ => ()
  }

  let {filterValue} = React.useContext(FilterContext.filterContext)

  let customFilterKey = switch entity {
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

  // with prefix only for charts
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

  // without prefix only for charts
  let getTopLevelFilter = React.useMemo(() => {
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

  let mode = switch modeKey {
  | Some(modeKey) => Some(getTopLevelFilter->getString(modeKey, ""))
  | None => Some("ORDER")
  }

  let {allFilterDimension, dateFilterKeys, currentMetrics, uriConfig, source} = entity
  let enableLoaders = entity.enableLoaders->Option.getOr(true)

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
  React.useEffect(() => {
    let cardinality = getChartCompFilters->getString("cardinality", "TOP_5")
    let chartType =
      getChartCompFilters->getString(
        "chartType",
        entity.chartTypes->Array.get(0)->Option.getOr(Line)->chartMapper,
      )
    let chartTopMetric = getChartCompFilters->getString("chartTopMetric", currentTopMatrix)

    let chartBottomMetric = getChartCompFilters->getString("chartBottomMetric", currentBottomMetrix)

    let dict = Dict.make()
    let chartMatrixArr = entityAllMetrics->Array.map(item => item.metric_label)

    if cardinalityArr->Array.includes(cardinality) {
      dict->Dict.set("cardinality", cardinality)
    } else if cardinalityArr->Array.includes("TOP_5") {
      dict->Dict.set("cardinality", "TOP_5")
    } else {
      dict->Dict.set("cardinality", cardinalityArr->Array.get(0)->Option.getOr(""))
    }
    chartTypeArr->Array.includes(chartType)
      ? dict->Dict.set("chartType", chartType)
      : dict->Dict.set("chartType", "Line chart")

    if chartMatrixArr->Array.includes(chartTopMetric) {
      dict->Dict.set("chartTopMetric", chartTopMetric)
    } else if chartMatrixArr->Array.includes(currentTopMatrix) {
      dict->Dict.set("chartTopMetric", currentTopMatrix)
    } else {
      dict->Dict.set("chartTopMetric", chartMatrixArr->Array.get(0)->Option.getOr(""))
    }

    if chartMatrixArr->Array.includes(chartBottomMetric) {
      dict->Dict.set("chartBottomMetric", chartBottomMetric)
    } else if chartMatrixArr->Array.includes(currentBottomMetrix) {
      dict->Dict.set("chartBottomMetric", currentBottomMetrix)
    } else {
      dict->Dict.set("chartBottomMetric", chartMatrixArr->Array.get(0)->Option.getOr(""))
    }

    updateChartCompFilters(dict)
    None
  }, [])

  let cardinalityFromUrl = getChartCompFilters->getString("cardinality", "TOP_5")
  let (rawChartData, setRawChartData) = React.useState(_ => None)
  let (groupKey, setGroupKey) = React.useState(_ => "")

  let (startTimeFilterKey, endTimeFilterKey) = dateFilterKeys

  let defaultFilters = switch modeKey {
  | Some(modeKey) => [startTimeFilterKey, endTimeFilterKey, modeKey]
  | None => [startTimeFilterKey, endTimeFilterKey]
  }

  let allFilterKeys = Array.concat(defaultFilters, allFilterDimension)

  let (topFiltersToSearchParam, customFilter) = React.useMemo(() => {
    let filterSearchParam =
      getTopLevelFilter
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
      ->Array.joinWithUnsafe("&")

    (filterSearchParam, getTopLevelFilter->getString(customFilterKey, ""))
  }, [getTopLevelFilter])

  let (startTimeFilterKey, endTimeFilterKey) = dateFilterKeys

  let (chartLoading, setChartLoading) = React.useState(_ => true)
  // By default, total_volume metric will always be there

  let (statusDict, setStatusDict) = React.useState(_ => Dict.make())
  let fetchChartData = useChartFetch(~setStatusDict)

  let startTimeFromUrl = React.useMemo(() => {
    getTopLevelFilter->getString(startTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo(() => {
    getTopLevelFilter->getString(endTimeFilterKey, "")
  }, [topFiltersToSearchParam])

  let defaultGranularity = switch getGranularity(
    ~startTime={startTimeFromUrl},
    ~endTime={endTimeFromUrl},
  )->Array.get(0) {
  | Some(val) => val
  | _ => G_FIVEMIN
  }

  let (selectedGranularity, setSelectedGranularity) = React.useState(_ => defaultGranularity)

  let topFiltersToSearchParam = React.useMemo(() => {
    let filterSearchParam =
      getTopLevelFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        switch value->JSON.Classify.classify {
        | String(str) => `${key}=${str}`->Some
        | Number(num) => `${key}=${num->String.make}`->Some
        | Array(arr) => `${key}=[${arr->String.make}]`->Some
        | _ => None
        }
      })
      ->Array.joinWithUnsafe("&")

    filterSearchParam
  }, [topFiltersToSearchParam])

  React.useEffect(() => {
    setSelectedGranularity(_ => defaultGranularity)
    None
  }, (startTimeFromUrl, endTimeFromUrl))
  let selectedTabStr = selectedTab->Option.getOr([])->Array.joinWithUnsafe("")

  let updatedChartConfigArr = React.useMemo(() => {
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

      let granularityOpts =
        entity.disableGranularity->Option.getOr(false)
          ? None
          : selectedGranularity->getGranularityString->Some

      {
        uri: item.uri,
        metrics: item.metrics,
        groupByNames: selectedTab,
        start_time: startTimeFromUrl,
        end_time: endTimeFromUrl,
        filters: Some(JSON.Encode.object(filterValue)),
        granularityOpts,
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
    selectedGranularity,
  ))

  let updatedChartBody = React.useMemo(() => {
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
              chartconfig.groupByNames->Option.getOr([])->Array.length === 1 ? legendBody : None
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

  let (groupKeyFromTab, titleKey) = React.useMemo(() => {
    switch (tabTitleMapper, selectedTab) {
    | (Some(dict), Some(arr)) => {
        let groupKey = arr->Array.get(0)->Option.getOr("")
        (groupKey, dict->Dict.get(groupKey)->Option.getOr(groupKey))
      }
    | (None, Some(arr)) => (
        arr->Array.get(0)->Option.getOr(""),
        arr->Array.get(0)->Option.getOr(""),
      )
    | _ => ("", "")
    }
  }, [selectedTab])

  let setRawChartData = (data: array<urlToDataMap>) => {
    let chartData = data->Array.map(mappedData => {
      let rawdata = mappedData.rawData->Array.map(item => {
        let dict = item->JSON.Decode.object->Option.getOr(Dict.make())

        switch dict->Dict.get("time_range") {
        | Some(jsonObj) => {
            let timeDict = jsonObj->getDictFromJsonObject

            switch timeDict->Dict.get("startTime") {
            | Some(startValue) => {
                let sTime = startValue->JSON.Decode.string->Option.getOr("")

                if sTime->isNonEmptyString {
                  let {date, hour, minute, month, second, year} =
                    sTime->Date.fromString->Date.toISOString->isoStringToCustomTimeZone

                  dict->Dict.set(
                    "time_bucket",
                    `${year}-${month}-${date} ${hour}:${minute}:${second}`->JSON.Encode.string,
                  )
                }
              }
            | None => ()
            }
          }
        | None => ()
        }

        selectedTab
        ->Option.getOr([])
        ->Array.forEach(
          tabName => {
            let metric =
              Dict.get(dict, tabName)
              ->Option.getOr(""->JSON.Encode.string)
              ->JSON.Decode.string
              ->Option.getOr("")
            let label = metric->isEmptyString ? "NA" : metric

            Dict.set(dict, tabName, label->JSON.Encode.string)

            Dict.keysToArray(dict)->Array.forEach(
              key => {
                if key->String.includes("amount") {
                  let amount =
                    Dict.get(dict, key)
                    ->Option.getOr(JSON.Encode.float(0.0))
                    ->JSON.Decode.float
                    ->Option.getOr(0.0)

                  let amount = (amount /. 100.0)->Float.toFixedWithPrecision(~digits=2)

                  Dict.set(dict, key, amount->Js.Float.fromString->JSON.Encode.float)
                } else if !(key->String.includes("time")) && key != tabName {
                  switch Dict.get(dict, key) {
                  | Some(val) =>
                    switch val->JSON.Decode.float {
                    | Some(val2) =>
                      Dict.set(
                        dict,
                        key,
                        val2->Float.toFixedWithPrecision(~digits=2)->JSON.Encode.string,
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
        dict->JSON.Encode.object
      })
      {
        metricsUrl: mappedData.metricsUrl,
        rawData: rawdata,
        legendData: mappedData.legendData,
      }
    })

    setGroupKey(_ => groupKeyFromTab)

    setRawChartData(_ => Some(chartData))
    setChartLoading(_ => false)
  }

  let chartTypeFromUrl = getChartCompFilters->getString("chartType", "Line chart")
  let chartTopMetricFromUrl = getChartCompFilters->getString("chartTopMetric", currentTopMatrix)

  React.useEffect(() => {
    if startTimeFromUrl->isNonEmptyString && endTimeFilterKey->isNonEmptyString {
      setChartLoading(_ => enableLoaders)
      fetchChartData(updatedChartBody, setRawChartData)
    }
    None
  }, [updatedChartBody])

  if statusDict->Dict.valuesToArray->Array.includes(504) {
    <AnalyticsUtils.NoDataFoundPage />
  } else {
    <div>
      <ReactFinalForm.Form
        subscription=ReactFinalForm.subscribeToValues
        onSubmit={(_, _) => Nullable.null->Promise.resolve}
        render={({handleSubmit}) => {
          <form onSubmit={handleSubmit}>
            <AddDataAttributes attributes=[("data-chart-segment", "Chart-1")]>
              <div
                className="border rounded bg-white border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 dynamicChart">
                {if chartLoading {
                  <Shimmer styleClass="w-full h-96 dark:bg-black bg-white" shimmerType={Big} />
                } else if comparitionWidget {
                  <div>
                    <RenderIf condition={featureFlagDetails.granularity}>
                      <div className="w-full flex justify-end p-2">
                        <GranularitySelectBox
                          selectedGranularity
                          setSelectedGranularity
                          startTime={startTimeFromUrl}
                          endTime={endTimeFromUrl}
                        />
                      </div>
                    </RenderIf>
                    {entityAllMetrics
                    ->Array.mapWithIndex((selectedMetrics, index) => {
                      switch uriConfig->Array.get(0) {
                      | Some(metricsUri) => {
                          let (data, legendData, timeCol) = switch rawChartData
                          ->Option.getOr([])
                          ->Array.find(item => item.metricsUrl === metricsUri.uri) {
                          | Some(dataVal) => (
                              dataVal.rawData,
                              dataVal.legendData,
                              metricsUri.timeCol,
                            )
                          | None => ([], [], "")
                          }

                          <HighchartTimeSeriesChart.LineChart1D
                            key={index->Int.toString}
                            class="flex overflow-scroll"
                            rawChartData=data
                            selectedMetrics
                            chartTitleText={selectedMetrics.metric_label}
                            xAxis=timeCol
                            groupKey
                            chartTitle=true
                            key={""}
                            legendData
                            showTableLegend
                            showMarkers
                            legendType
                            comparitionWidget
                            selectedTab={selectedTab->Option.getOr([])}
                          />
                        }
                      | _ => React.null
                      }
                    })
                    ->React.array}
                  </div>
                } else {
                  switch entityAllMetrics
                  ->Array.filter(item => item.metric_label === chartTopMetricFromUrl)
                  ->Array.get(0) {
                  | Some(selectedMetrics) =>
                    let metricsUri = uriConfig->Array.find(uriMetrics => {
                      uriMetrics.metrics
                      ->Array.map(item => {item.metric_label})
                      ->Array.includes(selectedMetrics.metric_label)
                    })
                    let (data, legendData, timeCol) = switch metricsUri {
                    | Some(val) =>
                      switch rawChartData
                      ->Option.getOr([])
                      ->Array.find(item => item.metricsUrl === val.uri) {
                      | Some(dataVal) => (dataVal.rawData, dataVal.legendData, val.timeCol)
                      | None => ([], [], "")
                      }
                    | None => ([], [], "")
                    }
                    switch chartTypeFromUrl->chartReverseMappers {
                    | Line =>
                      <HighchartTimeSeriesChart.LineChart1D
                        class="flex overflow-scroll"
                        rawChartData=data
                        selectedMetrics
                        chartPlace="top_"
                        xAxis=timeCol
                        groupKey
                        chartTitle=false
                        key={"0"}
                        legendData
                        showTableLegend
                        showMarkers
                        legendType
                      />

                    | Bar =>
                      <div className="">
                        <HighchartBarChart.HighBarChart1D
                          rawData=data groupKey selectedMetrics key={"0"}
                        />
                      </div>
                    | SemiDonut =>
                      <div className="m-4">
                        <HighchartPieChart
                          rawData=data groupKey titleKey selectedMetrics key={"0"}
                        />
                      </div>
                    | HorizontalBar =>
                      <div className="m-4">
                        <HighchartHorizontalBarChart
                          rawData=data groupKey titleKey selectedMetrics key={"0"}
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
                }}
              </div>
            </AddDataAttributes>
          </form>
        }}
      />
    </div>
  }
}
