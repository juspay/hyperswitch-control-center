open ReconEngineRevampedTypes
open LogicUtils

let reconStatusTypeFromString = str =>
  switch str {
  | "running" => Running
  | "stopped" => Stopped
  | _ => Stopped
  }

let reconStatusResponseMapper: Dict.t<JSON.t> => reconStatusResponse = dict => {
  {
    status: dict->getString("status", "stopped")->reconStatusTypeFromString,
  }
}

let rec addCommas = str => {
  let len = String.length(str)
  if len <= 3 {
    str
  } else {
    let prefix = String.slice(~start=0, ~end=len - 3, str)
    let suffix = String.slice(~start=len - 3, ~end=len, str)
    addCommas(prefix) ++ "," ++ suffix
  }
}

let formatFloatNumber = (amount: float) => {
  let amountParts = amount->Float.toFixedWithPrecision(~digits=2)->String.split(".")
  let integerPart = amountParts->getValueFromArray(0, "0")

  amountParts
  ->Array.get(1)
  ->mapOptionOrDefault(addCommas(integerPart), decimal => `${addCommas(integerPart)}.${decimal}`)
}

let formatNumber = (amount: int) => {
  `${addCommas(amount->Int.toString)}`
}

let getQueryParamFromFilters = (~filterValueJson: Dict.t<JSON.t>) => {
  let queryParts = []

  filterValueJson
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    let apiKey = switch key {
    | "startTime" => "start_time"
    | "endTime" => "end_time"
    | _ => key
    }

    switch value->JSON.Classify.classify {
    | String(str) =>
      if str->isNonEmptyString {
        queryParts->Array.push(`${apiKey}=${str}`)
      }
    | Number(num) => queryParts->Array.push(`${apiKey}=${num->Float.toString}`)
    | Array(arr) => {
        let arrayValues = arr->Array.map(item => item->getStringFromJson(""))->Array.joinWith(",")
        if arrayValues->isNonEmptyString {
          queryParts->Array.push(`${apiKey}=${arrayValues}`)
        }
      }
    | Bool(bool) => queryParts->Array.push(`${apiKey}=${bool->getStringFromBool}`)
    | _ => ()
    }
  })

  queryParts->Array.joinWith("&")
}
