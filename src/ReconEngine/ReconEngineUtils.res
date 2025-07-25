open LogicUtils

let buildQueryStringFromFilters = (~filterValueJson: Dict.t<JSON.t>) => {
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

let getDisplayStatusName = (status: string) => {
  switch status->String.toLowerCase {
  | "posted" => "Matched"->String.toUpperCase
  | _ => status->String.toUpperCase
  }
}
