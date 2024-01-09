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
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      Dict.fromArray([
        ("field", key->Js.Json.string),
        ("condition", "In"->Js.Json.string),
        ("val", value),
      ])
    })
  let expressionArr = Array.concat(cardinalityArr, expressionArr)
  if expressionArr->Array.length === 1 {
    expressionArr->Belt.Array.get(0)
  } else if expressionArr->Array.length > 1 {
    let leftInitial =
      Array.pop(expressionArr)->Belt.Option.getWithDefault(Dict.make())->Js.Json.object_
    let rightInitial =
      Array.pop(expressionArr)->Belt.Option.getWithDefault(Dict.make())->Js.Json.object_

    let complexFilterDict = Dict.fromArray([
      ("and", Dict.fromArray([("left", leftInitial), ("right", rightInitial)])->Js.Json.object_),
    ])
    expressionArr->Array.forEach(item => {
      let complextFilterDictCopy = complexFilterDict->Dict.toArray->Array.copy->Dict.fromArray
      complexFilterDict->Dict.set(
        "and",
        Dict.fromArray([
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
        String.replaceRegExp(customFilterValue, %re("/ AND /gi"), "@@")
        ->String.replaceRegExp(%re("/ OR /gi"), "@@")
        ->String.split("@@")
      let strAr = ["or", "and"]

      let andAndOr = String.split(customFilterValue, " ")->Array.filter(item => {
        strAr->Array.includes(item->String.toLocaleLowerCase)
      })

      let filterValueArr =
        value
        ->Array.mapWithIndex((item, _index) => {
          if Js.String.match_(%re("/ != /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ != /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "NotEquals"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ > /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ > /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Greater"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ < /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ < /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Less"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ >= /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ >= /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "GreaterThanEquall"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ <= /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ <= /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "LessThanEqual"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ = /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ = /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Equals"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->Js.Json.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ IN /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ IN /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "In"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->String.replaceRegExp(%re("/\(/g"), "")
                    ->String.replaceRegExp(%re("/\)/g"), "")
                    ->String.split(",")
                    ->Array.map(item => item->String.trim)
                    ->Js.Json.stringArray,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ NOT IN /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ NOT IN /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "NotIn"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->String.replaceRegExp(%re("/\(/g"), "")
                    ->String.replaceRegExp(%re("/\)/g"), "")
                    ->String.split(",")
                    ->Array.map(item => item->String.trim)
                    ->Js.Json.stringArray,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ LIKE /gi"), item)->Belt.Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ LIKE /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Belt.Option.getWithDefault("")->Js.Json.string),
                  ("condition", "Like"->Js.Json.string),
                  (
                    "val",
                    value[1]
                    ->Belt.Option.getWithDefault("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
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

      if filterValueArr->Array.length === 1 {
        filterValueArr->Belt.Array.get(0)
      } else if filterValueArr->Array.length >= 2 {
        let leftInitial = filterValueArr[0]->Belt.Option.getWithDefault(Dict.make())
        let rightInitial = filterValueArr[1]->Belt.Option.getWithDefault(Dict.make())
        let conditionInitital = andAndOr->Belt.Array.get(0)->Belt.Option.getWithDefault("and")
        let complexFilterDict = Dict.fromArray([
          (
            conditionInitital,
            Dict.fromArray([
              ("left", leftInitial->Js.Json.object_),
              ("right", rightInitial->Js.Json.object_),
            ])->Js.Json.object_,
          ),
        ])
        let filterValueArr = Js.Array2.sliceFrom(filterValueArr->Array.copy, 2)
        let andAndOr = Js.Array2.sliceFrom(andAndOr->Array.copy, 1)

        filterValueArr->Array.forEachWithIndex((item, index) => {
          let complextFilterDictCopy = complexFilterDict->Dict.toArray->Array.copy->Dict.fromArray
          complexFilterDict->Dict.set(
            andAndOr->Belt.Array.get(index)->Belt.Option.getWithDefault("and"),
            Dict.fromArray([
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
        let overallFilters = Dict.fromArray([
          (
            "and",
            Dict.fromArray([
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
    | None => Dict.make()
    }

  | (None, Some(customFilter)) => customFilter

  | (None, None) => Dict.make()
  }

  switch jsonFormattedFilter {
  | Some(jsonFormattedFilter) =>
    switch filterValue->Dict.toArray->Array.length > 0 {
    | true =>
      Dict.fromArray([
        (
          "and",
          Dict.fromArray([
            ("left", filterValue->Js.Json.object_),
            ("right", jsonFormattedFilter),
          ])->Js.Json.object_,
        ),
      ])
    | false => jsonFormattedFilter->Js.Json.decodeObject->Belt.Option.getWithDefault(Dict.make())
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
  let finalBody = Dict.make()

  let cardinalityArrFilter = switch (cardinality, groupBy) {
  | (Some(cardinality), Some(groupBy)) =>
    groupBy->Array.map(item => {
      Dict.fromArray([
        ("field", item->Js.Json.string),
        ("condition", "In"->Js.Json.string),
        (
          "val",
          Dict.fromArray([
            (
              "sortedOn",
              Dict.fromArray([
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

  let activeTabArr = groupBy->Belt.Option.getWithDefault([])->Array.map(Js.Json.string)
  finalBody->Dict.set("metric", metric->Js.Json.string)
  let filterVal = getFilterBody(
    filterValueFromUrl,
    customFilterValue,
    jsonFormattedFilter,
    cardinalityArrFilter,
  )

  if filterVal->Dict.toArray->Array.length !== 0 {
    finalBody->Dict.set("filters", filterVal->Js.Json.object_)
  }

  switch granularityConfig {
  | Some(config) => {
      let (granularityDuration, granularityUnit) = config
      let granularityDimension = Dict.make()
      let granularity = Dict.make()
      Dict.set(granularityDimension, "timeZone", timeZone->timeZoneMapper->Js.Json.string)
      Dict.set(granularityDimension, "intervalCol", timeCol->Js.Json.string)
      Dict.set(granularity, "unit", granularityUnit->Js.Json.string)
      Dict.set(granularity, "duration", granularityDuration->Belt.Int.toFloat->Js.Json.number)
      Dict.set(granularityDimension, "granularity", granularity->Js.Json.object_)

      finalBody->Dict.set(
        "dimensions",
        Array.concat(activeTabArr, [granularityDimension->Js.Json.object_])->Js.Json.array,
      )
    }

  | None => finalBody->Dict.set("dimensions", activeTabArr->Js.Json.array)
  }

  switch sortingParams {
  | Some(val) =>
    finalBody->Dict.set(
      "sortedOn",
      Dict.fromArray([
        ("sortDimension", val.sortDimension->Js.Json.string),
        ("ordering", val.ordering === #Desc ? "Desc"->Js.Json.string : "Asc"->Js.Json.string),
      ])->Js.Json.object_,
    )
  | None => ()
  }
  switch dataLimit {
  | Some(dataLimit) => finalBody->Dict.set("limit", dataLimit->Js.Json.number)
  | None => ()
  }

  finalBody->Dict.set("domain", domain->Js.Json.string)
  finalBody->Dict.set("interval", timeObj->Js.Json.object_)
  finalBody->Js.Json.object_
}
