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
  if startTime->LogicUtils.isNonEmptyString && endTime->LogicUtils.isNonEmptyString {
    let startDateTime = startTime->DateTimeUtils.parseAsFloat->Js.Date.fromFloat->toUtc

    let startTimeDayJs = startDateTime->DayJs.getDayJsForJsDate
    let endDateTime = endTime->DateTimeUtils.parseAsFloat->Js.Date.fromFloat->toUtc

    let endDateTimeJs = endDateTime->DayJs.getDayJsForJsDate
    let timediff = endDateTimeJs.diff(. Date.toString(startDateTime), "hours")

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

let makeFilters = (~filters: JSON.t, ~cardinalityArr) => {
  let decodeFilter = filters->getDictFromJsonObject

  let expressionArr =
    decodeFilter
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      Dict.fromArray([
        ("field", key->JSON.Encode.string),
        ("condition", "In"->JSON.Encode.string),
        ("val", value),
      ])
    })
  let expressionArr = Array.concat(cardinalityArr, expressionArr)
  if expressionArr->Array.length === 1 {
    expressionArr->Array.get(0)
  } else if expressionArr->Array.length > 1 {
    let leftInitial = Array.pop(expressionArr)->Option.getOr(Dict.make())->JSON.Encode.object
    let rightInitial = Array.pop(expressionArr)->Option.getOr(Dict.make())->JSON.Encode.object

    let complexFilterDict = Dict.fromArray([
      ("and", Dict.fromArray([("left", leftInitial), ("right", rightInitial)])->JSON.Encode.object),
    ])
    expressionArr->Array.forEach(item => {
      let complextFilterDictCopy = complexFilterDict->Dict.toArray->Array.copy->Dict.fromArray
      complexFilterDict->Dict.set(
        "and",
        Dict.fromArray([
          ("left", complextFilterDictCopy->JSON.Encode.object),
          ("right", item->JSON.Encode.object),
        ])->JSON.Encode.object,
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
          if Js.String.match_(%re("/ != /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ != /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "NotEquals"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ > /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ > /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Greater"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ < /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ < /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Less"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ >= /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ >= /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "GreaterThanEquall"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ <= /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ <= /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "LessThanEqual"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ = /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ = /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Equals"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ IN /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ IN /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "In"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->String.replaceRegExp(%re("/\(/g"), "")
                    ->String.replaceRegExp(%re("/\)/g"), "")
                    ->String.split(",")
                    ->Array.map(item => item->String.trim)
                    ->LogicUtils.getJsonFromArrayOfString,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ NOT IN /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ NOT IN /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "NotIn"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->String.replaceRegExp(%re("/\(/g"), "")
                    ->String.replaceRegExp(%re("/\)/g"), "")
                    ->String.split(",")
                    ->Array.map(item => item->String.trim)
                    ->LogicUtils.getJsonFromArrayOfString,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if Js.String.match_(%re("/ LIKE /gi"), item)->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ LIKE /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Like"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
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
        filterValueArr->Array.get(0)
      } else if filterValueArr->Array.length >= 2 {
        let leftInitial = filterValueArr[0]->Option.getOr(Dict.make())
        let rightInitial = filterValueArr[1]->Option.getOr(Dict.make())
        let conditionInitital = andAndOr->Array.get(0)->Option.getOr("and")
        let complexFilterDict = Dict.fromArray([
          (
            conditionInitital,
            Dict.fromArray([
              ("left", leftInitial->JSON.Encode.object),
              ("right", rightInitial->JSON.Encode.object),
            ])->JSON.Encode.object,
          ),
        ])
        let filterValueArr = filterValueArr->Array.copy->Array.sliceToEnd(~start=2)
        let andAndOr = andAndOr->Array.copy->Array.sliceToEnd(~start=1)

        filterValueArr->Array.forEachWithIndex((item, index) => {
          let complextFilterDictCopy = complexFilterDict->Dict.toArray->Array.copy->Dict.fromArray
          complexFilterDict->Dict.set(
            andAndOr->Array.get(index)->Option.getOr("and"),
            Dict.fromArray([
              ("left", complextFilterDictCopy->JSON.Encode.object),
              ("right", item->JSON.Encode.object),
            ])->JSON.Encode.object,
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
              ("left", formattedFilters->JSON.Encode.object),
              ("right", customFilter->JSON.Encode.object),
            ])->JSON.Encode.object,
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
            ("left", filterValue->JSON.Encode.object),
            ("right", jsonFormattedFilter),
          ])->JSON.Encode.object,
        ),
      ])
    | false => jsonFormattedFilter->JSON.Decode.object->Option.getOr(Dict.make())
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
  ~jsonFormattedFilter: option<JSON.t>=?,
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
        ("field", item->JSON.Encode.string),
        ("condition", "In"->JSON.Encode.string),
        (
          "val",
          Dict.fromArray([
            (
              "sortedOn",
              Dict.fromArray([
                ("sortDimension", cardinalitySortDims->JSON.Encode.string),
                ("ordering", "Desc"->JSON.Encode.string),
              ])->JSON.Encode.object,
            ),
            ("limit", cardinality->JSON.Encode.float),
          ])->JSON.Encode.object,
        ),
      ])
    })
  | _ => []
  }

  let activeTabArr = groupBy->Option.getOr([])->Array.map(JSON.Encode.string)
  finalBody->Dict.set("metric", metric->JSON.Encode.string)
  let filterVal = getFilterBody(
    filterValueFromUrl,
    customFilterValue,
    jsonFormattedFilter,
    cardinalityArrFilter,
  )

  if filterVal->Dict.toArray->Array.length !== 0 {
    finalBody->Dict.set("filters", filterVal->JSON.Encode.object)
  }

  switch granularityConfig {
  | Some(config) => {
      let (granularityDuration, granularityUnit) = config
      let granularityDimension = Dict.make()
      let granularity = Dict.make()
      Dict.set(granularityDimension, "timeZone", timeZone->timeZoneMapper->JSON.Encode.string)
      Dict.set(granularityDimension, "intervalCol", timeCol->JSON.Encode.string)
      Dict.set(granularity, "unit", granularityUnit->JSON.Encode.string)
      Dict.set(granularity, "duration", granularityDuration->Int.toFloat->JSON.Encode.float)
      Dict.set(granularityDimension, "granularity", granularity->JSON.Encode.object)

      finalBody->Dict.set(
        "dimensions",
        Array.concat(activeTabArr, [granularityDimension->JSON.Encode.object])->JSON.Encode.array,
      )
    }

  | None => finalBody->Dict.set("dimensions", activeTabArr->JSON.Encode.array)
  }

  switch sortingParams {
  | Some(val) =>
    finalBody->Dict.set(
      "sortedOn",
      Dict.fromArray([
        ("sortDimension", val.sortDimension->JSON.Encode.string),
        (
          "ordering",
          val.ordering === #Desc ? "Desc"->JSON.Encode.string : "Asc"->JSON.Encode.string,
        ),
      ])->JSON.Encode.object,
    )
  | None => ()
  }
  switch dataLimit {
  | Some(dataLimit) => finalBody->Dict.set("limit", dataLimit->JSON.Encode.float)
  | None => ()
  }

  finalBody->Dict.set("domain", domain->JSON.Encode.string)
  finalBody->Dict.set("interval", timeObj->JSON.Encode.object)
  finalBody->JSON.Encode.object
}
