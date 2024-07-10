type chartType = Default | Table

type singleStatData = {
  title: string,
  tooltipText: string,
  deltaTooltipComponent: string => React.element,
  value: float,
  delta: float,
  data: array<(float, float)>,
  statType: string,
  showDelta: bool,
  label?: string,
}

type columnsType<'colType> = {
  colType: 'colType,
  chartType?: chartType,
}

let generateDefaultStateColumns: array<'colType> => array<columnsType<'colType>> = arr => {
  arr->Array.map(col => {
    {
      colType: col,
    }
  })
}

type columns<'colType> = {
  sectionName: string,
  columns: array<columnsType<'colType>>,
  sectionInfo?: string,
}

type singleStatBodyEntity = {
  filter?: JSON.t,
  metrics?: array<string>,
  delta?: bool,
  startDateTime: string,
  endDateTime: string,
  granularity?: string,
  mode?: string,
  customFilter?: string,
  groupByNames?: array<string>,
  source?: string,
  prefix?: string,
}

type urlConfig = {
  uri: string,
  metrics: array<string>,
  prefix?: string,
}
type deltaRange = {currentSr: AnalyticsUtils.timeRanges}

type entityType<'colType, 't, 't2> = {
  urlConfig: array<urlConfig>,
  getObjects: JSON.t => array<'t>,
  getTimeSeriesObject: JSON.t => array<'t2>,
  defaultColumns: array<columns<'colType>>, // (sectionName, defaultColumns)
  getData: ('t, array<'t2>, deltaRange, 'colType, string) => singleStatData,
  totalVolumeCol: option<string>,
  matrixUriMapper: 'colType => string, // metrix uriMapper will contain the ${prefix}${url}
  source?: string,
  customFilterKey?: string,
  enableLoaders?: bool,
  statSentiment?: Dict.t<AnalyticsUtils.statSentiment>,
  statThreshold?: Dict.t<float>,
}
type timeType = {startTime: string, endTime: string}
// this will be removed once filter refactor is merged

type singleStatDataObj<'t> = {
  sectionUrl: string,
  singleStatData: array<'t>,
  deltaTime: deltaRange,
}

let singleStatBodyMake = (singleStatBodyEntity: singleStatBodyEntity) => {
  [
    AnalyticsUtils.getFilterRequestBody(
      ~filter=singleStatBodyEntity.filter,
      ~metrics=singleStatBodyEntity.metrics,
      ~delta=?singleStatBodyEntity.delta,
      ~startDateTime=singleStatBodyEntity.startDateTime,
      ~endDateTime=singleStatBodyEntity.endDateTime,
      ~mode=singleStatBodyEntity.mode,
      ~customFilter=?singleStatBodyEntity.customFilter,
      ~source=?singleStatBodyEntity.source,
      ~granularity=singleStatBodyEntity.granularity,
      ~prefix=singleStatBodyEntity.prefix,
      (),
    )->JSON.Encode.object,
  ]
  ->JSON.Encode.array
  ->JSON.stringify
}
type singleStateData<'t, 't2> = {
  singleStatData: option<array<singleStatDataObj<'t>>>,
  singleStatTimeData: option<array<(string, array<'t2>)>>,
}

let deltaTimeRangeMapper: array<JSON.t> => deltaRange = (arrJson: array<JSON.t>) => {
  open LogicUtils
  let emptyDict = Dict.make()
  let _ = arrJson->Array.map(item => {
    let dict = item->getDictFromJsonObject
    let deltaTimeRange = dict->getJsonObjectFromDict("deltaTimeRange")->getDictFromJsonObject
    let fromTime = deltaTimeRange->getString("startTime", "")
    let toTime = deltaTimeRange->getString("endTime", "")
    let timeRanges: AnalyticsUtils.timeRanges = {fromTime, toTime}
    if deltaTimeRange->Dict.toArray->Array.length > 0 {
      emptyDict->Dict.set("currentSr", timeRanges)
    }
  })
  {
    currentSr: emptyDict
    ->Dict.get("currentSr")
    ->Option.getOr({
      fromTime: "",
      toTime: "",
    }),
  }
}
// till here
@react.component
let make = (
  ~entity: entityType<'colType, 't, 't2>,
  ~modeKey=?,
  ~filterKeys,
  ~startTimeFilterKey,
  ~endTimeFilterKey,
  ~moduleName="",
  ~showPercentage=true,
  ~chartAlignment=#column,
  ~isHomePage=false,
  ~defaultStartDate="",
  ~defaultEndDate="",
  ~filterNullVals=false,
  ~statSentiment=?,
  ~statThreshold=?,
  ~wrapperClass=?,
  ~formaPayload: option<singleStatBodyEntity => string>=?,
) => {
  open UIUtils
  open LogicUtils
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let getAllFilter = filterValueJson
  let isMobileView = MatchMedia.useMobileChecker()
  let (showStats, setShowStats) = React.useState(_ => false)

  // without prefix only table related Filters
  let getTopLevelFilter = React.useMemo1(() => {
    getAllFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Array.get(0)->Option.getOr("")
      if prefix === moduleName && prefix->isNonEmptyString {
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

  let source = switch entity {
  | {source} => source
  | _ => "BATCH"
  }

  let enableLoaders = entity.enableLoaders->Option.getOr(true)

  let customFilterKey = switch entity {
  | {customFilterKey} => customFilterKey
  | _ => ""
  }
  let allFilterKeys = Array.concat(
    [startTimeFilterKey, endTimeFilterKey, mode->Option.getOr("")],
    filterKeys,
  )

  let deltaItemToObjMapper = json => {
    let metaData =
      json->getDictFromJsonObject->getArrayFromDict("metaData", [])->deltaTimeRangeMapper
    metaData
  }

  let (topFiltersToSearchParam, customFilter) = React.useMemo1(() => {
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

  let filterValueFromUrl = React.useMemo1(() => {
    getTopLevelFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(entries => {
      let (key, value) = entries
      filterKeys->Array.includes(key) ? Some((key, value)) : None
    })
    ->getJsonFromArrayOfJson
    ->Some
  }, [topFiltersToSearchParam])

  let startTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->getString(startTimeFilterKey, defaultStartDate)
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->getString(endTimeFilterKey, defaultEndDate)
  }, [topFiltersToSearchParam])

  let homePageCss = isHomePage || chartAlignment === #row ? "flex-col" : "flex-row"
  let wrapperClass =
    wrapperClass->Option.getOr(
      `flex flex-col md:${homePageCss} flex-wrap justify-start items-stretch relative h-full`,
    )

  let (singleStatData, setSingleStatData) = React.useState(() => None)
  let (shimmerType, setShimmerType) = React.useState(_ => AnalyticsUtils.Shimmer)
  let (singleStatTimeData, setSingleStatTimeData) = React.useState(() => None)
  let (singleStatLoading, setSingleStatLoading) = React.useState(_ => true)
  let (singleStatLoadingTimeSeries, setSingleStatLoadingTimeSeries) = React.useState(_ => true)

  let (singlestatDataCombined, setSingleStatCombinedData) = React.useState(_ => {
    singleStatTimeData,
    singleStatData,
  })

  React.useEffect4(() => {
    if !(singleStatLoading || singleStatLoadingTimeSeries) {
      setSingleStatCombinedData(_ => {
        singleStatTimeData,
        singleStatData,
      })
    }
    None
  }, (singleStatLoadingTimeSeries, singleStatLoading, singleStatTimeData, singleStatData))
  let addLogsAroundFetch = AnalyticsLogUtilsHook.useAddLogsAroundFetch()

  React.useEffect2(() => {
    if singleStatData !== None && singleStatTimeData !== None {
      setShimmerType(_ => SideLoader)
    }
    None
  }, (singleStatData, singleStatTimeData))

  React.useEffect5(() => {
    if startTimeFromUrl->isNonEmptyString && endTimeFromUrl->isNonEmptyString {
      open Promise
      setSingleStatLoading(_ => enableLoaders)

      entity.urlConfig
      ->Array.map(urlConfig => {
        let {uri, metrics} = urlConfig
        let domain = String.split("/", uri)->Array.get(4)->Option.getOr("")
        let startTime = if domain === "mandate" {
          (endTimeFromUrl->DayJs.getDayJsForString).subtract(1, "hour").toDate()->Date.toISOString
        } else {
          startTimeFromUrl
        }
        let getDelta = domain !== "mandate"
        let singleStatBodyEntity = {
          filter: ?filterValueFromUrl,
          metrics,
          delta: getDelta,
          startDateTime: startTime,
          endDateTime: endTimeFromUrl,
          ?mode,
          customFilter,
          source,
          prefix: ?urlConfig.prefix,
        }

        let singleStatBodyMakerFn = switch formaPayload {
        | Some(fun) => fun
        | _ => singleStatBodyMake
        }

        let singleStatBody = singleStatBodyEntity->singleStatBodyMakerFn
        fetchApi(
          uri,
          ~method_=Post,
          ~bodyStr=singleStatBody,
          ~headers=[("QueryType", "SingleStat")]->Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="SingleStat Data Api")
        ->then(json => resolve((`${urlConfig.prefix->Option.getOr("")}${uri}`, json)))
        ->catch(_err => resolve(("", JSON.Encode.object(Dict.make()))))
      })
      ->Promise.all
      ->Promise.thenResolve(dataArr => {
        let data = dataArr->Array.map(
          item => {
            let (sectionName, json) = item

            let data = entity.getObjects(json)
            let deltaTime = deltaItemToObjMapper(json)

            let value: singleStatDataObj<'t> = {
              sectionUrl: sectionName,
              singleStatData: data,
              deltaTime,
            }
            value
          },
        )
        setSingleStatData(_ => Some(data))

        setSingleStatLoading(_ => false)
      })
      ->ignore
    }
    None
  }, (endTimeFromUrl, startTimeFromUrl, filterValueFromUrl, customFilter, mode))

  React.useEffect5(() => {
    if startTimeFromUrl->isNonEmptyString && endTimeFromUrl->isNonEmptyString {
      setSingleStatLoadingTimeSeries(_ => enableLoaders)

      open Promise
      entity.urlConfig
      ->Array.map(urlConfig => {
        let {uri, metrics} = urlConfig
        let domain = String.split("/", uri)->Array.get(4)->Option.getOr("")
        let startTime = if domain === "mandate" {
          (endTimeFromUrl->DayJs.getDayJsForString).subtract(1, "hour").toDate()->Date.toISOString
        } else {
          startTimeFromUrl
        }
        let granularity =
          DynamicChart.getGranularity(~startTime, ~endTime=endTimeFromUrl)->Array.map(
            item => item->DynamicChart.getGranularityString,
          )

        let singleStatBodyEntity = {
          filter: ?filterValueFromUrl,
          metrics,
          delta: false,
          startDateTime: startTime,
          endDateTime: endTimeFromUrl,
          granularity: ?granularity->Array.get(0),
          ?mode,
          customFilter,
          source,
          prefix: ?urlConfig.prefix,
        }

        let singleStatBodyMakerFn = switch formaPayload {
        | Some(fun) => fun
        | _ => singleStatBodyMake
        }

        fetchApi(
          uri,
          ~method_=Post,
          ~bodyStr=singleStatBodyMakerFn(singleStatBodyEntity),
          ~headers=[("QueryType", "SingleStatTimeseries")]->Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="SingleStatTimeseries Data Api")
        ->then(
          json => {
            resolve((`${urlConfig.prefix->Option.getOr("")}${uri}`, json))
          },
        )
        ->catch(
          _err => {
            resolve(("", JSON.Encode.object(Dict.make())))
          },
        )
      })
      ->Promise.all
      ->thenResolve(timeSeriesArr => {
        let data = timeSeriesArr->Array.map(
          item => {
            let (sectionName, json) = item

            (sectionName, entity.getTimeSeriesObject(json))
          },
        )

        setSingleStatTimeData(_ => Some(data))
        setSingleStatLoadingTimeSeries(_ => false)
      })
      ->ignore
    }
    None
  }, (endTimeFromUrl, startTimeFromUrl, filterValueFromUrl, customFilter, mode))

  entity.defaultColumns
  ->Array.mapWithIndex((urlConfig, index) => {
    let {columns} = urlConfig

    let singleStateArr = columns->Array.mapWithIndex((col, singleStatArrIndex) => {
      let uri = col.colType->entity.matrixUriMapper
      let timeSeriesData =
        singlestatDataCombined.singleStatTimeData
        ->Option.getOr([("--", [])])
        ->Belt.Array.keepMap(
          item => {
            let (timeSectionName, timeSeriesObj) = item
            timeSectionName === uri ? Some(timeSeriesObj) : None
          },
        )
      let timeSeriesData = []->Array.concatMany(timeSeriesData)

      switch col.chartType->Option.getOr(Default) {
      | Table =>
        switch singlestatDataCombined.singleStatData {
        | Some(sdata) => {
            let sectiondata =
              sdata
              ->Array.filter(
                item => {
                  item.sectionUrl === uri
                },
              )
              ->Array.get(0)

            switch sectiondata {
            | Some(data) =>
              let info = data.singleStatData->Array.map(
                infoData => {
                  entity.getData(
                    infoData,
                    timeSeriesData,
                    data.deltaTime,
                    col.colType,
                    mode->Option.getOr("ORDER"),
                  )
                },
              )

              let (title, tooltipText, statType) = switch info->Array.get(0) {
              | Some(val) => (val.title, val.tooltipText, val.statType)
              | _ => ("", "", "")
              }

              let modifiedData = info->Array.map(
                item => {
                  let val: HSwitchSingleStatTableWidget.tableRowType = {
                    rowLabel: item.label->Option.getOr("NA"),
                    rowValue: item.value,
                  }
                  val
                },
              )

              modifiedData->Array.sort(
                (a, b) => {
                  let rowValue_a = a.rowValue
                  let rowValue_b = b.rowValue

                  rowValue_a <= rowValue_b ? 1. : -1.
                },
              )

              <HSwitchSingleStatTableWidget
                key={singleStatArrIndex->Int.toString}
                singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
                title
                tooltipText
                loaderType=shimmerType
                value=modifiedData
                statType
                statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
                filterNullVals
                ?statSentiment
                ?statThreshold
                fullWidth={columns->Array.length == 1}
              />

            | None =>
              <HSwitchSingleStatTableWidget
                key={singleStatArrIndex->Int.toString}
                deltaTooltipComponent=React.null
                value=[]
                statType=""
                singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
                loaderType=shimmerType
                statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
                filterNullVals
                ?statSentiment
                ?statThreshold
              />
            }
          }

        | None =>
          <HSwitchSingleStatTableWidget
            key={singleStatArrIndex->Int.toString}
            deltaTooltipComponent=React.null
            value=[]
            statType=""
            singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
            loaderType=shimmerType
            statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
            filterNullVals
            ?statSentiment
          />
        }
      | _ =>
        switch singlestatDataCombined.singleStatData {
        | Some(sdata) => {
            let sectiondata =
              sdata
              ->Array.filter(
                item => {
                  item.sectionUrl === uri
                },
              )
              ->Array.get(0)

            switch sectiondata {
            | Some(data) => {
                let info = data.singleStatData->Array.map(
                  infoData => {
                    entity.getData(
                      infoData,
                      timeSeriesData,
                      data.deltaTime,
                      col.colType,
                      mode->Option.getOr("ORDER"),
                    )
                  },
                )

                switch info->Array.get(0) {
                | Some(stateData) =>
                  <HSwitchSingleStatWidget
                    key={singleStatArrIndex->Int.toString}
                    title=stateData.title
                    tooltipText=stateData.tooltipText
                    deltaTooltipComponent={stateData.deltaTooltipComponent(stateData.statType)}
                    value=stateData.value
                    data=stateData.data
                    statType=stateData.statType
                    singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
                    showPercentage=stateData.showDelta
                    loaderType=shimmerType
                    statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
                    filterNullVals
                    ?statSentiment
                    ?statThreshold
                  />
                | _ =>
                  <HSwitchSingleStatWidget
                    key={singleStatArrIndex->Int.toString}
                    title=""
                    tooltipText=""
                    deltaTooltipComponent=React.null
                    value=0.
                    data=[]
                    statType=""
                    singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
                    loaderType=shimmerType
                    statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
                    filterNullVals
                    ?statSentiment
                    ?statThreshold
                  />
                }
              }

            | None =>
              <HSwitchSingleStatWidget
                key={singleStatArrIndex->Int.toString}
                title=""
                tooltipText=""
                deltaTooltipComponent=React.null
                value=0.
                data=[]
                statType=""
                singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
                loaderType=shimmerType
                statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
                filterNullVals
                ?statSentiment
                ?statThreshold
              />
            }
          }

        | None =>
          <HSwitchSingleStatWidget
            key={singleStatArrIndex->Int.toString}
            title=""
            tooltipText=""
            deltaTooltipComponent=React.null
            value=0.
            data=[]
            statType=""
            singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
            loaderType=shimmerType
            statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
            filterNullVals
            ?statSentiment
          />
        }
      }
    })

    <AddDataAttributes
      attributes=[("data-dynamic-single-stats", "dynamic stats")] key={index->Int.toString}>
      <div className=wrapperClass>
        {if isMobileView {
          <div className="flex flex-col gap-2 items-center h-full">
            <div className="flex flex-wrap w-full h-full">
              {singleStateArr
              ->Array.mapWithIndex((element, index) => {
                <RenderIf condition={index < 4 || showStats} key={index->Int.toString}>
                  <div className="w-full md:w-1/2"> element </div>
                </RenderIf>
              })
              ->React.array}
            </div>
            <div className="w-full px-2">
              <Button
                text={showStats ? "Hide All Stats" : "View All Stats"}
                onClick={_ => setShowStats(prev => !prev)}
                buttonType={Pagination}
                customButtonStyle="w-full"
              />
            </div>
          </div>
        } else {
          singleStateArr->React.array
        }}
      </div>
    </AddDataAttributes>
  })
  ->React.array
}
