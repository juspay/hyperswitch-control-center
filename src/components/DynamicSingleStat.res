type singleStatData = {
  title: string,
  tooltipText: string,
  deltaTooltipComponent: string => React.element,
  value: float,
  delta: float,
  data: array<(float, float)>,
  statType: string,
  showDelta: bool,
}

type columns<'colType> = {
  sectionName: string,
  columns: array<'colType>,
  sectionInfo?: string,
}

type singleStatBodyEntity = {
  filter?: Js.Json.t,
  metrics?: array<string>,
  delta?: bool,
  startDateTime: string,
  endDateTime: string,
  granularity?: string,
  mode?: string,
  customFilter?: string,
  source?: string,
  prefix?: string,
}

type urlConfig = {
  uri: string,
  metrics: array<string>,
  singleStatBody?: singleStatBodyEntity => string,
  singleStatTimeSeriesBody?: singleStatBodyEntity => string,
  prefix?: string,
}
type deltaRange = {currentSr: AnalyticsUtils.timeRanges}

type entityType<'colType, 't, 't2> = {
  urlConfig: array<urlConfig>,
  getObjects: Js.Json.t => 't,
  getTimeSeriesObject: Js.Json.t => array<'t2>,
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
  singleStatData: 't,
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
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}
type singleStateData<'t, 't2> = {
  singleStatData: option<Js.Array2.t<singleStatDataObj<'t>>>,
  singleStatTimeData: option<Js.Array2.t<(string, Js.Array2.t<'t2>)>>,
}

let deltaTimeRangeMapper: array<Js.Json.t> => deltaRange = (arrJson: array<Js.Json.t>) => {
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
    ->Belt.Option.getWithDefault({
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
  ~setTotalVolume,
  ~showPercentage=true,
  ~chartAlignment=#column,
  ~isHomePage=false,
  ~defaultStartDate="",
  ~defaultEndDate="",
  ~filterNullVals=false,
  ~statSentiment=?,
  ~statThreshold=?,
  ~wrapperClass=?,
) => {
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
      let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      if prefix === moduleName && prefix !== "" {
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

  let source = switch entity {
  | {source} => source
  | _ => "BATCH"
  }

  let enableLoaders = entity.enableLoaders->Belt.Option.getWithDefault(true)

  let customFilterKey = switch entity {
  | {customFilterKey} => customFilterKey
  | _ => ""
  }
  let allFilterKeys = Array.concat(
    [startTimeFilterKey, endTimeFilterKey, mode->Belt.Option.getWithDefault("")],
    filterKeys,
  )

  let deltaItemToObjMapper = json => {
    let metaData =
      json
      ->LogicUtils.getDictFromJsonObject
      ->LogicUtils.getArrayFromDict("metaData", [])
      ->deltaTimeRangeMapper
    metaData
  }

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

  let filterValueFromUrl = React.useMemo1(() => {
    getTopLevelFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(entries => {
      let (key, value) = entries
      filterKeys->Array.includes(key) ? Some((key, value)) : None
    })
    ->Dict.fromArray
    ->Js.Json.object_
    ->Some
  }, [topFiltersToSearchParam])

  let startTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->LogicUtils.getString(startTimeFilterKey, defaultStartDate)
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->LogicUtils.getString(endTimeFilterKey, defaultEndDate)
  }, [topFiltersToSearchParam])

  let homePageCss = isHomePage || chartAlignment === #row ? "flex-col" : "flex-row"
  let wrapperClass =
    wrapperClass->Belt.Option.getWithDefault(
      `flex mt-5 flex-col md:${homePageCss} flex-wrap justify-start items-stretch relative`,
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
  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetch()

  React.useEffect2(() => {
    if singleStatData !== None && singleStatTimeData !== None {
      setShimmerType(_ => SideLoader)
    }
    None
  }, (singleStatData, singleStatTimeData))

  React.useEffect5(() => {
    if startTimeFromUrl !== "" && endTimeFromUrl !== "" {
      open Promise
      setSingleStatLoading(_ => enableLoaders)

      entity.urlConfig
      ->Array.map(urlConfig => {
        let {uri, metrics} = urlConfig
        let domain = String.split("/", uri)->Belt.Array.get(4)->Belt.Option.getWithDefault("")
        let startTime = if domain === "mandate" {
          (endTimeFromUrl->DayJs.getDayJsForString).subtract(.
            1,
            "hour",
          ).toDate(.)->Js.Date.toISOString
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
        let singleStatBodyMakerFn =
          urlConfig.singleStatBody->Belt.Option.getWithDefault(singleStatBodyMake)

        let singleStatBody = singleStatBodyMakerFn(singleStatBodyEntity)
        fetchApi(
          uri,
          ~method_=Post,
          ~bodyStr=singleStatBody,
          ~headers=[("QueryType", "SingleStat")]->Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="SingleStat Data Api")
        ->then(json => resolve((`${urlConfig.prefix->Belt.Option.getWithDefault("")}${uri}`, json)))
        ->catch(_err => resolve(("", Js.Json.object_(Dict.make()))))
      })
      ->Promise.all
      ->Promise.thenResolve(dataArr => {
        let data = dataArr->Array.map(
          item => {
            let (sectionName, json) = item
            switch entity.totalVolumeCol {
            | Some(val) => {
                let totalVolumeKeyVal =
                  json
                  ->LogicUtils.getDictFromJsonObject
                  ->LogicUtils.getJsonObjectFromDict("queryData")
                  ->LogicUtils.getArrayFromJson([])
                  ->Belt.Array.get(0)
                  ->Belt.Option.getWithDefault(Js.Json.object_(Dict.make()))
                  ->LogicUtils.getDictFromJsonObject
                  ->Dict.toArray
                  ->Array.find(
                    item => {
                      let (key, _) = item
                      key === val
                    },
                  )
                switch totalVolumeKeyVal {
                | Some(data) => {
                    let (_key, value) = data
                    setTotalVolume(
                      _ =>
                        value
                        ->Js.Json.decodeNumber
                        ->Belt.Option.getWithDefault(0.)
                        ->Belt.Float.toInt,
                    )
                  }

                | None => ()
                }
              }

            | None => ()
            }
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
    if startTimeFromUrl !== "" && endTimeFromUrl !== "" {
      setSingleStatLoadingTimeSeries(_ => enableLoaders)

      open Promise
      entity.urlConfig
      ->Array.map(urlConfig => {
        let {uri, metrics} = urlConfig
        let domain = String.split("/", uri)->Belt.Array.get(4)->Belt.Option.getWithDefault("")
        let startTime = if domain === "mandate" {
          (endTimeFromUrl->DayJs.getDayJsForString).subtract(.
            1,
            "hour",
          ).toDate(.)->Js.Date.toISOString
        } else {
          startTimeFromUrl
        }
        let granularity = LineChartUtils.getGranularity(~startTime, ~endTime=endTimeFromUrl)

        let singleStatBodyEntity = {
          filter: ?filterValueFromUrl,
          metrics,
          delta: false,
          startDateTime: startTime,
          endDateTime: endTimeFromUrl,
          granularity: ?granularity->Belt.Array.get(0),
          ?mode,
          customFilter,
          source,
          prefix: ?urlConfig.prefix,
        }
        let singleStatBodyMakerFn =
          urlConfig.singleStatTimeSeriesBody->Belt.Option.getWithDefault(singleStatBodyMake)
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
            resolve((`${urlConfig.prefix->Belt.Option.getWithDefault("")}${uri}`, json))
          },
        )
        ->catch(
          _err => {
            resolve(("", Js.Json.object_(Dict.make())))
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
    let {sectionName, columns} = urlConfig

    let singleStateArr = columns->Array.mapWithIndex((col, singleStatArrIndex) => {
      let uri = col->entity.matrixUriMapper
      let timeSeriesData =
        singlestatDataCombined.singleStatTimeData
        ->Belt.Option.getWithDefault([("--", [])])
        ->Belt.Array.keepMap(
          item => {
            let (timeSectionName, timeSeriesObj) = item
            timeSectionName === uri ? Some(timeSeriesObj) : None
          },
        )
      let timeSeriesData = []->Array.concatMany(timeSeriesData)
      switch singlestatDataCombined.singleStatData {
      | Some(sdata) => {
          let sectiondata =
            sdata
            ->Array.filter(
              item => {
                item.sectionUrl === uri
              },
            )
            ->Belt.Array.get(0)

          switch sectiondata {
          | Some(data) => {
              let info = entity.getData(
                data.singleStatData,
                timeSeriesData,
                data.deltaTime,
                col,
                mode->Belt.Option.getWithDefault("ORDER"),
              )

              <HSwitchSingleStatWidget
                key={singleStatArrIndex->string_of_int}
                title=info.title
                tooltipText=info.tooltipText
                deltaTooltipComponent={info.deltaTooltipComponent(info.statType)}
                value=info.value
                data=info.data
                statType=info.statType
                singleStatLoading={singleStatLoading || singleStatLoadingTimeSeries}
                showPercentage=info.showDelta
                loaderType=shimmerType
                statChartColor={mod(singleStatArrIndex, 2) === 0 ? #blue : #grey}
                filterNullVals
                ?statSentiment
                ?statThreshold
                isHomePage
              />
            }

          | None =>
            <HSwitchSingleStatWidget
              key={singleStatArrIndex->string_of_int}
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
              isHomePage
            />
          }
        }

      | None =>
        <HSwitchSingleStatWidget
          key={singleStatArrIndex->string_of_int}
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
          isHomePage
        />
      }
    })

    <AddDataAttributes
      attributes=[("data-dynamic-single-stats", "dynamic stats")] key={index->string_of_int}>
      <div>
        <UIUtils.RenderIf condition={sectionName !== ""}>
          <div
            className="mb-5 block pl-5 pt-5 not-italic font-bold text-fs-18 text-black dark:text-white">
            {sectionName->React.string}
          </div>
        </UIUtils.RenderIf>
        {switch urlConfig.sectionInfo {
        | Some(info) =>
          <div
            className="mb-5 block p-2 not-italic font-normal text-fs-12 text-black dark:text-white bg-blue-info dark:bg-blue-info dark:bg-opacity-20 ml-6"
            style={ReactDOMStyle.make(
              ~borderLeft="6px solid #2196F3",
              ~maxWidth="max-content",
              (),
            )}>
            {info->React.string}
          </div>
        | None => React.null
        }}
        <div className=wrapperClass>
          {if isMobileView && !isHomePage {
            <div className="flex flex-col gap-2 items-center">
              <div className="flex flex-wrap w-full">
                {singleStateArr
                ->Array.mapWithIndex((element, index) => {
                  <UIUtils.RenderIf condition={index < 4 || showStats} key={index->string_of_int}>
                    <div className="w-full md:w-1/2"> element </div>
                  </UIUtils.RenderIf>
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
      </div>
    </AddDataAttributes>
  })
  ->React.array
}
