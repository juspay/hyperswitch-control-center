open DateTimeUtils
open LogicUtils
type timeZone = UTC | IST
let calculateHistoricTime = (
  ~startTime: string,
  ~endTime: string,
  ~format: string="YYYY-MM-DDTHH:mm:ss[Z]",
  ~timeZone: timeZone=UTC,
  (),
) => {
  let toUtc = switch timeZone {
  | UTC => toUtc
  | IST => val => val
  }
  if startTime !== "" && endTime !== "" {
    let startDateTime = startTime->DateTimeUtils.parseAsFloat->Js.Date.fromFloat->toUtc

    let startTimeDayJs = startDateTime->DayJs.getDayJsForJsDate
    let endDateTime = endTime->DateTimeUtils.parseAsFloat->Js.Date.fromFloat->toUtc

    let endDateTimeJs = endDateTime->DayJs.getDayJsForJsDate
    let timediff = endDateTimeJs.diff(. Js.Date.toString(startDateTime), "hours")

    if timediff < 24 {
      (
        startTimeDayJs.subtract(. 24, "hours").format(. format),
        endDateTimeJs.subtract(. 24, "hours").format(. format),
      )
    } else {
      let fromTime = startDateTime->Js.Date.valueOf
      let toTime = endDateTime->Js.Date.valueOf
      let (startTime, endTime) = (
        (fromTime -. (toTime -. fromTime) -. 1.)->Js.Date.fromFloat->DayJs.getDayJsForJsDate,
        (fromTime -. 1.)->Js.Date.fromFloat->DayJs.getDayJsForJsDate,
      )

      (startTime.format(. format), endTime.format(. format))
    }
  } else {
    ("", "")
  }
}

let makeFilters = (~filters: Js.Json.t, ~cardinalityArr) => {
  let decodeFilter = filters->getDictFromJsonObject

  let expressionArr =
    decodeFilter
    ->Js.Dict.entries
    ->Js.Array2.map(item => {
      let (key, value) = item
      Js.Dict.fromArray([
        ("field", key->Js.Json.string),
        ("condition", "In"->Js.Json.string),
        ("val", value),
      ])
    })
  let expressionArr = Js.Array2.concat(cardinalityArr, expressionArr)
  if expressionArr->Js.Array2.length === 1 {
    expressionArr->Belt.Array.get(0)
  } else if expressionArr->Js.Array2.length > 1 {
    let leftInitial =
      Js.Array2.pop(expressionArr)->Belt.Option.getWithDefault(Js.Dict.empty())->Js.Json.object_
    let rightInitial =
      Js.Array2.pop(expressionArr)->Belt.Option.getWithDefault(Js.Dict.empty())->Js.Json.object_

    let complexFilterDict = Js.Dict.fromArray([
      ("and", Js.Dict.fromArray([("left", leftInitial), ("right", rightInitial)])->Js.Json.object_),
    ])
    expressionArr->Js.Array2.forEach(item => {
      let complextFilterDictCopy =
        complexFilterDict->Js.Dict.entries->Js.Array2.copy->Js.Dict.fromArray
      complexFilterDict->Js.Dict.set(
        "and",
        Js.Dict.fromArray([
          ("left", complextFilterDictCopy->Js.Json.object_),
          ("right", item->Js.Json.object_),
        ])->Js.Json.object_,
      )
    })
    Some(complexFilterDict)
  } else {
    None
  }
}

let getFilterBody = (
  filterValueFromUrl,
  customFilterValue,
  jsonFormattedFilter,
  cardinalityArrFilter,
) => {
  let customFilterBuild = switch customFilterValue {
  | Some(customFilterValue) => {
      let value =
        Js.String2.replaceByRe(customFilterValue, %re("/ AND /gi"), "@@")
        ->Js.String2.replaceByRe(%re("/ OR /gi"), "@@")
        ->Js.String2.split("@@")
      let strAr = ["or", "and"]

      let andAndOr = Js.String2.split(customFilterValue, " ")->Js.Array2.filter(item => {
        strAr->Js.Array2.includes(item->Js.String.toLocaleLowerCase)
      })

      let filterValueArr =
        value
        ->Js.Array2.mapi((item, _index) => {
          if Js.String.match_(%re("/ != /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ != /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "NotEquals"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ > /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ > /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Greater"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ < /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ < /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Less"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ >= /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ >= /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "GreaterThanEquall"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ <= /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ <= /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "LessThanEqual"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ = /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ = /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Equals"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ IN /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ IN /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "In"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.String2.replaceByRe(%re("/\(/g"), "")
                    ->Js.String2.replaceByRe(%re("/\)/g"), "")
                    ->Js.String2.split(",")
                    ->Js.Array2.map(item => item->Js.String.trim)
                    ->Js.Json.stringArray,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ NOT IN /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ NOT IN /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "NotIn"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.String2.replaceByRe(%re("/\(/g"), "")
                    ->Js.String2.replaceByRe(%re("/\)/g"), "")
                    ->Js.String2.split(",")
                    ->Js.Array2.map(item => item->Js.String.trim)
                    ->Js.Json.stringArray,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ LIKE /gi"), item)->Belt.Option.isSome {
            let value =
              Js.String2.replaceByRe(item, %re("/ LIKE /gi"), "@@")
              ->Js.String2.split("@@")
              ->Js.Array2.map(item => item->Js.String.trim)
            if value->Js.Array2.length >= 2 {
              Some(
                Js.Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Like"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.replaceByRe(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else {
            None
          }
        })
        ->Belt.Array.keepMap(item => item)

      if filterValueArr->Js.Array2.length === 1 {
        filterValueArr->Belt.Array.get(0)
      } else if filterValueArr->Js.Array2.length >= 2 {
        let leftInitial = filterValueArr[0]->Belt.Option.getWithDefault(Js.Dict.empty())
        let rightInitial = filterValueArr[1]->Belt.Option.getWithDefault(Js.Dict.empty())
        let conditionInitital = andAndOr->Belt.Array.get(0)->Belt.Option.getWithDefault("and")
        let complexFilterDict = Js.Dict.fromArray([
          (
            conditionInitital,
            Js.Dict.fromArray([
              ("left", leftInitial->Js.Json.object_),
              ("right", rightInitial->Js.Json.object_),
            ])->Js.Json.object_,
          ),
        ])
        let filterValueArr = Js.Array2.sliceFrom(filterValueArr->Js.Array2.copy, 2)
        let andAndOr = Js.Array2.sliceFrom(andAndOr->Js.Array2.copy, 1)

        filterValueArr->Js.Array2.forEachi((item, index) => {
          let complextFilterDictCopy =
            complexFilterDict->Js.Dict.entries->Js.Array2.copy->Js.Dict.fromArray
          complexFilterDict->Js.Dict.set(
            andAndOr->Belt.Array.get(index)->Belt.Option.getWithDefault("and"),
            Js.Dict.fromArray([
              ("left", complextFilterDictCopy->Js.Json.object_),
              ("right", item->Js.Json.object_),
            ])->Js.Json.object_,
          )
        })
        Some(complexFilterDict)
      } else {
        None
      }
    }

  | None => None
  }
  let filterValue = switch (filterValueFromUrl, customFilterBuild) {
  | (Some(value), Some(customFilter)) =>
    switch makeFilters(~filters=value, ~cardinalityArr=cardinalityArrFilter) {
    | Some(formattedFilters) => {
        let overallFilters = Js.Dict.fromArray([
          (
            "and",
            Js.Dict.fromArray([
              ("left", formattedFilters->Js.Json.object_),
              ("right", customFilter->Js.Json.object_),
            ])->Js.Json.object_,
          ),
        ])
        overallFilters
      }

    | None => customFilter
    }

  | (Some(value), None) =>
    switch makeFilters(~filters=value, ~cardinalityArr=cardinalityArrFilter) {
    | Some(formattedFilters) => formattedFilters
    | None => Js.Dict.empty()
    }

  | (None, Some(customFilter)) => customFilter

  | (None, None) => Js.Dict.empty()
  }

  switch jsonFormattedFilter {
  | Some(jsonFormattedFilter) =>
    switch filterValue->Js.Dict.entries->Js.Array2.length > 0 {
    | true =>
      Js.Dict.fromArray([
        (
          "and",
          Js.Dict.fromArray([
            ("left", filterValue->Js.Json.object_),
            ("right", jsonFormattedFilter),
          ])->Js.Json.object_,
        ),
      ])
    | false =>
      jsonFormattedFilter->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
    }
  | None => filterValue
  }
}

type ordering = [#Desc | #Asc]
type sortedBasedOn = {
  sortDimension: string,
  ordering: ordering,
}

let timeZoneMapper = timeZone => {
  switch timeZone {
  | IST => "Asia/Kolkata"
  | UTC => "UTC"
  }
}

let apiBodyMaker = (
  ~timeObj,
  ~metric,
  ~groupBy=?,
  ~granularityConfig=?,
  ~cardinality=?,
  ~filterValueFromUrl=?,
  ~customFilterValue=?,
  ~sortingParams: option<sortedBasedOn>=?,
  ~jsonFormattedFilter: option<Js.Json.t>=?,
  ~cardinalitySortDims="total_volume",
  ~timeZone: timeZone=IST,
  ~timeCol: string="txn_initiated",
  ~domain: string,
  ~dataLimit: option<float>=?,
  (),
) => {
  let finalBody = Js.Dict.empty()

  let cardinalityArrFilter = switch (cardinality, groupBy) {
  | (Some(cardinality), Some(groupBy)) =>
    groupBy->Js.Array2.map(item => {
      Js.Dict.fromArray([
        ("field", item->Js.Json.string),
        ("condition", "In"->Js.Json.string),
        (
          "val",
          Js.Dict.fromArray([
            (
              "sortedOn",
              Js.Dict.fromArray([
                ("sortDimension", cardinalitySortDims->Js.Json.string),
                ("ordering", "Desc"->Js.Json.string),
              ])->Js.Json.object_,
            ),
            ("limit", cardinality->Js.Json.number),
          ])->Js.Json.object_,
        ),
      ])
    })
  | _ => []
  }

  let activeTabArr = groupBy->Belt.Option.getWithDefault([])->Js.Array2.map(Js.Json.string)
  finalBody->Js.Dict.set("metric", metric->Js.Json.string)
  let filterVal = getFilterBody(
    filterValueFromUrl,
    customFilterValue,
    jsonFormattedFilter,
    cardinalityArrFilter,
  )

  if filterVal->Js.Dict.entries->Js.Array2.length !== 0 {
    finalBody->Js.Dict.set("filters", filterVal->Js.Json.object_)
  }

  switch granularityConfig {
  | Some(config) => {
      let (granularityDuration, granularityUnit) = config
      let granularityDimension = Js.Dict.empty()
      let granularity = Js.Dict.empty()
      Js.Dict.set(granularityDimension, "timeZone", timeZone->timeZoneMapper->Js.Json.string)
      Js.Dict.set(granularityDimension, "intervalCol", timeCol->Js.Json.string)
      Js.Dict.set(granularity, "unit", granularityUnit->Js.Json.string)
      Js.Dict.set(granularity, "duration", granularityDuration->Belt.Int.toFloat->Js.Json.number)
      Js.Dict.set(granularityDimension, "granularity", granularity->Js.Json.object_)

      finalBody->Js.Dict.set(
        "dimensions",
        Js.Array2.concat(activeTabArr, [granularityDimension->Js.Json.object_])->Js.Json.array,
      )
    }

  | None => finalBody->Js.Dict.set("dimensions", activeTabArr->Js.Json.array)
  }

  switch sortingParams {
  | Some(val) =>
    finalBody->Js.Dict.set(
      "sortedOn",
      Js.Dict.fromArray([
        ("sortDimension", val.sortDimension->Js.Json.string),
        ("ordering", val.ordering === #Desc ? "Desc"->Js.Json.string : "Asc"->Js.Json.string),
      ])->Js.Json.object_,
    )
  | None => ()
  }
  switch dataLimit {
  | Some(dataLimit) => finalBody->Js.Dict.set("limit", dataLimit->Js.Json.number)
  | None => ()
  }

  finalBody->Js.Dict.set("domain", domain->Js.Json.string)
  finalBody->Js.Dict.set("interval", timeObj->Js.Json.object_)
  finalBody->Js.Json.object_
}
