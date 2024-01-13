open AnalyticsTypesUtils
open SingleStatEntity
open DictionaryUtils
open Promise
open LogicUtils
open AnalyticsNewUtils

type singleStatComponent = {
  singleStatData: option<Dict.t<dataState<Js.Json.t>>>,
  singleStatTimeSeries: option<Dict.t<dataState<Js.Json.t>>>,
  singleStatDelta: option<Dict.t<dataState<Js.Json.t>>>,
  singleStatLoader: Dict.t<AnalyticsUtils.loaderType>,
  singleStatIsVisible: (bool => bool) => unit,
}

let singleStatComponentDefVal = {
  singleStatData: None,
  singleStatTimeSeries: None,
  singleStatDelta: None,
  singleStatLoader: Dict.make(),
  singleStatIsVisible: _ => (),
}

let singleStatContext = React.createContext(singleStatComponentDefVal)

module Provider = {
  let make = React.Context.provider(singleStatContext)
}

@react.component
let make = (
  ~children,
  ~singleStatEntity: singleStatEntity<'a>,
  ~setSingleStatTime=_ => (),
  ~setIndividualSingleStatTime=_ => (),
) => {
  let {
    moduleName,
    modeKey,
    source,
    customFilterKey,
    startTimeFilterKey,
    endTimeFilterKey,
    filterKeys,
    dataFetcherObj,
    metrixMapper,
  } = singleStatEntity

  let jsonTransFormer = switch singleStatEntity {
  | {jsonTransformer} => jsonTransformer
  | _ => (_val, arr) => arr
  }
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let getAllFilter = filterValueJson
  let (isSingleStatVisible, setSingleStatIsVisible) = React.useState(_ => false)
  let parentToken = AuthWrapperUtils.useTokenParent(Original)
  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetchNew()
  let betaEndPointConfig = React.useContext(BetaEndPointConfigProvider.betaEndPointConfig)
  let fetchApi = AuthHooks.useApiFetcher(~betaEndpointConfig=?betaEndPointConfig, ())

  let getTopLevelSingleStatFilter = React.useMemo1(() => {
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

  let (topFiltersToSearchParam, customFilter, modeValue) = React.useMemo1(() => {
    let modeValue = Some(getTopLevelSingleStatFilter->LogicUtils.getString(modeKey, ""))
    let allFilterKeys = Array.concat(
      [startTimeFilterKey, endTimeFilterKey, modeValue->Belt.Option.getWithDefault("")],
      filterKeys,
    )
    let filterSearchParam =
      getTopLevelSingleStatFilter
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

    (
      filterSearchParam,
      getTopLevelSingleStatFilter->LogicUtils.getString(customFilterKey, ""),
      modeValue,
    )
  }, [getTopLevelSingleStatFilter])

  let filterValueFromUrl = React.useMemo1(() => {
    getTopLevelSingleStatFilter
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
    getTopLevelSingleStatFilter->LogicUtils.getString(startTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo1(() => {
    getTopLevelSingleStatFilter->LogicUtils.getString(endTimeFilterKey, "")
  }, [topFiltersToSearchParam])

  let initialValue =
    dataFetcherObj
    ->Array.map(item => {
      let {metrics} = item
      let updatedMetrics = metrics->metrixMapper
      (updatedMetrics, Loading)
    })
    ->Dict.fromArray

  let initialValueLoader =
    dataFetcherObj
    ->Array.map(item => {
      let {metrics} = item
      let updatedMetrics = metrics->metrixMapper
      (updatedMetrics, AnalyticsUtils.Shimmer)
    })
    ->Dict.fromArray
  let (singleStatStateData, setSingleStatStateData) = React.useState(_ => initialValue)
  let (singleStatTimeSeries, setSingleStatTimeSeries) = React.useState(_ => initialValue)
  let (singleStatStateDataHistoric, setSingleStatStateDataHistoric) = React.useState(_ =>
    initialValue
  )

  let (singleStatLoader, setSingleStatLoader) = React.useState(_ => initialValueLoader)
  let (
    singleStatFetchedWithCurrentDependency,
    setIsSingleStatFetchedWithCurrentDependency,
  ) = React.useState(_ => false)

  React.useEffect6(() => {
    if startTimeFromUrl !== "" && endTimeFromUrl !== "" && parentToken->Belt.Option.isSome {
      setIsSingleStatFetchedWithCurrentDependency(_ => false)
    }
    None
  }, (endTimeFromUrl, startTimeFromUrl, filterValueFromUrl, parentToken, customFilter, modeValue))

  React.useEffect2(() => {
    if !singleStatFetchedWithCurrentDependency && isSingleStatVisible {
      setIsSingleStatFetchedWithCurrentDependency(_ => true)
      let granularity = LineChartUtils.getGranularityNew(
        ~startTime=startTimeFromUrl,
        ~endTime=endTimeFromUrl,
      )
      let filterConfigCurrent = {
        source,
        modeValue: modeValue->Belt.Option.getWithDefault(""),
        filterValues: ?filterValueFromUrl,
        startTime: startTimeFromUrl,
        endTime: endTimeFromUrl,
        customFilterValue: customFilter, // will add later
        granularity: ?granularity->Belt.Array.get(0),
      }

      let (hStartTime, hEndTime) = AnalyticsNewUtils.calculateHistoricTime(
        ~startTime=startTimeFromUrl,
        ~endTime=endTimeFromUrl,
        (),
      )

      let filterConfigHistoric = {
        ...filterConfigCurrent,
        startTime: hStartTime,
        endTime: hEndTime,
      }
      setSingleStatTime(_ => {
        let a: timeObj = {
          apiStartTime: Js.Date.now(),
          apiEndTime: 0.,
        }
        a
      })

      dataFetcherObj
      ->Array.mapWithIndex((urlConfig, index) => {
        let {url, metrics} = urlConfig
        let updatedMetrics = metrics->metrixMapper
        setIndividualSingleStatTime(
          prev => {
            let individualTime = prev->Dict.toArray->Dict.fromArray
            individualTime->Dict.set(index->Belt.Int.toString, Js.Date.now())
            individualTime
          },
        )

        setSingleStatStateData(
          prev => {
            let prevDict = prev->copyOfDict
            Dict.set(prevDict, updatedMetrics, Loading)
            prevDict
          },
        )

        setSingleStatTimeSeries(
          prev => {
            let prevDict = prev->copyOfDict
            Dict.set(prevDict, updatedMetrics, Loading)
            prevDict
          },
        )
        setSingleStatStateDataHistoric(
          prev => {
            let prevDict = prev->copyOfDict
            Dict.set(prevDict, updatedMetrics, Loading)
            prevDict
          },
        )
        let timeObj = Dict.fromArray([
          ("start", filterConfigCurrent.startTime->Js.Json.string),
          ("end", filterConfigCurrent.endTime->Js.Json.string),
        ])
        let historicTimeObj = Dict.fromArray([
          ("start", filterConfigHistoric.startTime->Js.Json.string),
          ("end", filterConfigHistoric.endTime->Js.Json.string),
        ])

        let granularityConfig = switch filterConfigCurrent {
        | {granularity} => granularity
        | _ => (1, "hour")
        }

        let singleStatHistoricDataFetch =
          fetchApi(
            `${url}?api-type=singlestat&time=historic&metrics=${updatedMetrics}`,
            ~method_=Post,
            ~bodyStr=apiBodyMaker(
              ~timeObj=historicTimeObj,
              ~metric=updatedMetrics,
              ~filterValueFromUrl=?filterConfigHistoric.filterValues,
              ~customFilterValue=filterConfigHistoric.customFilterValue,
              ~domain=urlConfig.domain,
              (),
            )->Js.Json.stringify,
            ~authToken=parentToken,
            ~headers=[("QueryType", "SingleStatHistoric")]->Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(
            ~logTitle=`SingleStat histotic data for metrics ${metrics->metrixMapper}`,
          )
          ->then(
            text => {
              let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)
              let jsonObj = jsonTransFormer(updatedMetrics, jsonObj)
              resolve({
                setSingleStatStateDataHistoric(
                  prev => {
                    let prevDict = prev->copyOfDict
                    Dict.set(
                      prevDict,
                      updatedMetrics,
                      Loaded(
                        jsonObj
                        ->Belt.Array.get(0)
                        ->Belt.Option.getWithDefault(Js.Json.object_(Dict.make())),
                      ),
                    )
                    prevDict
                  },
                )
                Loaded(Js.Json.object_(Dict.make()))
              })
            },
          )
          ->catch(
            _err => {
              setSingleStatStateDataHistoric(
                prev => {
                  let prevDict = prev->copyOfDict
                  Dict.set(prevDict, updatedMetrics, LoadedError)
                  prevDict
                },
              )
              resolve(LoadedError)
            },
          )

        let singleStatDataFetch =
          fetchApi(
            `${url}?api-type=singlestat&metrics=${updatedMetrics}`,
            ~method_=Post,
            ~bodyStr=apiBodyMaker(
              ~timeObj,
              ~metric=updatedMetrics,
              ~filterValueFromUrl=?filterConfigCurrent.filterValues,
              ~customFilterValue=filterConfigCurrent.customFilterValue,
              ~domain=urlConfig.domain,
              (),
            )->Js.Json.stringify,
            ~authToken=parentToken,
            ~headers=[("QueryType", "SingleStat")]->Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(~logTitle=`SingleStat data for metrics ${metrics->metrixMapper}`)
          ->then(
            text => {
              let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)
              let jsonObj = jsonTransFormer(updatedMetrics, jsonObj)
              setSingleStatStateData(
                prev => {
                  let prevDict = prev->copyOfDict
                  Dict.set(
                    prevDict,
                    updatedMetrics,
                    Loaded(
                      jsonObj
                      ->Belt.Array.get(0)
                      ->Belt.Option.getWithDefault(Js.Json.object_(Dict.make())),
                    ),
                  )
                  prevDict
                },
              )

              resolve(Loaded(Js.Json.object_(Dict.make())))
            },
          )
          ->catch(
            _err => {
              setSingleStatStateData(
                prev => {
                  let prevDict = prev->copyOfDict
                  Dict.set(prevDict, updatedMetrics, LoadedError)
                  prevDict
                },
              )
              resolve(LoadedError)
            },
          )

        let singleStatDataFetchTimeSeries =
          fetchApi(
            `${url}?api-type=singlestat-timeseries&metrics=${updatedMetrics}`,
            ~method_=Post,
            ~bodyStr=apiBodyMaker(
              ~timeObj,
              ~metric=updatedMetrics,
              ~filterValueFromUrl=?filterConfigCurrent.filterValues,
              ~granularityConfig,
              ~customFilterValue=filterConfigCurrent.customFilterValue,
              ~domain=urlConfig.domain,
              ~timeCol=urlConfig.timeColumn,
              (),
            )->Js.Json.stringify,
            ~authToken=parentToken,
            ~headers=[("QueryType", "SingleStat Time Series")]->Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(
            ~logTitle=`SingleStat Time Series data for metrics ${metrics->metrixMapper}`,
          )
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
                      (key === `${urlConfig.timeColumn}_time` ? "time" : key, value)
                    },
                  )
                  ->Dict.fromArray
                  ->Js.Json.object_
                },
              )
              let jsonObj = jsonTransFormer(updatedMetrics, jsonObj)
              setSingleStatTimeSeries(
                prev => {
                  let prevDict = prev->copyOfDict
                  Dict.set(prevDict, updatedMetrics, Loaded(jsonObj->Js.Json.array))
                  prevDict
                },
              )
              resolve(Loaded(Js.Json.object_(Dict.make())))
            },
          )
          ->catch(
            _err => {
              setSingleStatTimeSeries(
                prev => {
                  let prevDict = prev->copyOfDict
                  Dict.set(prevDict, updatedMetrics, LoadedError)
                  prevDict
                },
              )

              resolve(LoadedError)
            },
          )

        [singleStatDataFetchTimeSeries, singleStatHistoricDataFetch, singleStatDataFetch]
        ->Promise.all
        ->Promise.thenResolve(
          value => {
            let ssH = value->Belt.Array.get(0)->Belt.Option.getWithDefault(LoadedError)
            let ssT = value->Belt.Array.get(1)->Belt.Option.getWithDefault(LoadedError)
            let ssD = value->Belt.Array.get(2)->Belt.Option.getWithDefault(LoadedError)
            let isLoaded = val => {
              switch val {
              | Loaded(_) => true
              | _ => false
              }
            }
            setSingleStatLoader(
              prev => {
                let prevDict = prev->copyOfDict
                if isLoaded(ssH) && isLoaded(ssT) && isLoaded(ssD) {
                  Dict.set(prevDict, updatedMetrics, AnalyticsUtils.SideLoader)
                }
                prevDict
              },
            )
            setIndividualSingleStatTime(
              prev => {
                let individualTime = prev->Dict.toArray->Dict.fromArray
                individualTime->Dict.set(
                  index->Belt.Int.toString,
                  Js.Date.now() -.
                  individualTime
                  ->Dict.get(index->Belt.Int.toString)
                  ->Belt.Option.getWithDefault(Js.Date.now()),
                )
                individualTime
              },
            )
            if index === dataFetcherObj->Array.length - 1 {
              setSingleStatTime(
                prev => {
                  ...prev,
                  apiEndTime: Js.Date.now(),
                },
              )
            }
          },
        )
        ->ignore
      })
      ->ignore
    }

    None
  }, (singleStatFetchedWithCurrentDependency, isSingleStatVisible))
  let value = React.useMemo4(() => {
    {
      singleStatData: Some(singleStatStateData),
      singleStatTimeSeries: Some(singleStatTimeSeries),
      singleStatDelta: Some(singleStatStateDataHistoric),
      singleStatLoader,
      singleStatIsVisible: setSingleStatIsVisible,
    }
  }, (singleStatStateData, singleStatTimeSeries, singleStatLoader, setSingleStatIsVisible))

  <Provider value> children </Provider>
}
