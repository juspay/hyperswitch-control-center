open LogicUtils
open AlertsTypes

let parseDimensions = dimensionsStr => {
  let dict = dimensionsStr->safeParse->getDictFromJsonObject
  (
    dict->getString("profile_id", ""),
    dict->getString("connector", ""),
    dict->getString("payment_method", ""),
  )
}

let priorityFromString = priority =>
  switch priority {
  | "P0" => P0
  | "P1" => P1
  | "P2" => P2
  | "P3" => P3
  | other => UnknownPriority(other)
  }

let itemToObjMapper = (dict: Dict.t<JSON.t>): alert => {
  let (profileId, connector, paymentMethod) = dict->getString("dimensions", "")->parseDimensions
  {
    id: dict->getString("id", ""),
    name: dict->getString("name", ""),
    product: dict->getString("product", ""),
    merchantId: dict->getString("merchant_id", ""),
    profileId,
    connector,
    paymentMethod,
    tsAlert: dict->getString("ts_alert", ""),
    startTime: dict->getString("start_time", ""),
    endTime: dict->getString("end_time", ""),
    priority: dict->getString("priority", "")->priorityFromString,
    attribution: dict->getString("attribution", ""),
  }
}

let columnarResponseToAlerts = (json: JSON.t): array<alert> =>
  json->getArrayFromJson([])->Array.map(row => row->getDictFromJsonObject->itemToObjMapper)

let dictionaryResponseToOptions = (json: JSON.t, key: string): array<string> =>
  json
  ->getArrayFromJson([])
  ->Array.map(getDictFromJsonObject)
  ->Array.find(row => row->getString("key_", "") === key)
  ->Option.map(row => row->getString("values_", "[]"))
  ->Option.getOr("[]")
  ->safeParse
  ->getStrArrayFromJson

let columnarResponseToDictionary = (json: JSON.t): alertsDictionary => {
  merchantIds: json->dictionaryResponseToOptions("merchant_id"),
  profileIds: json->dictionaryResponseToOptions("profile_id"),
  connectors: json->dictionaryResponseToOptions("connector"),
  paymentMethods: json->dictionaryResponseToOptions("payment_method"),
}

let formatDuration = (startTime: string, endTime: string): string => {
  if startTime->isNonEmptyString {
    let endIso = endTime->isNonEmptyString ? endTime : Date.now()->Date.fromTime->Date.toISOString
    let rawMinutes = (endIso->DayJs.getDayJsForString).diff(startTime, "minute")
    let totalMinutes = rawMinutes < 0 ? 0 : rawMinutes

    if totalMinutes < 60 {
      `${totalMinutes->Int.toString}m`
    } else if totalMinutes < 1440 {
      let hours = totalMinutes / 60
      let mins = totalMinutes - hours * 60
      `${hours->Int.toString}h ${mins->Int.toString}m`
    } else {
      let days = totalMinutes / 1440
      let hours = (totalMinutes - days * 1440) / 60
      `${days->Int.toString}d ${hours->Int.toString}h`
    }
  } else {
    "-"
  }
}

let buildListBody = (
  ~limit,
  ~offset,
  ~startTime,
  ~endTime,
  ~filterValueJson: Dict.t<JSON.t>,
  ~isResolved: option<bool>=None,
) => {
  let excludedKeys = [HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]

  let extraFilters =
    filterValueJson
    ->Dict.toArray
    ->Array.filter(((key, _)) => !(excludedKeys->Array.includes(key)))

  let body =
    [
      ("limit", limit->Int.toFloat->JSON.Encode.float),
      ("offset", offset->Int.toFloat->JSON.Encode.float),
      (
        "ts_alert",
        [
          ("start", startTime->JSON.Encode.string),
          ("end", endTime->JSON.Encode.string),
        ]->getJsonFromArrayOfJson,
      ),
    ]->Array.concat(extraFilters)

  switch isResolved {
  | Some(resolved) => body->Array.concat([("is_resolved", resolved->JSON.Encode.bool)])
  | None => body
  }->getJsonFromArrayOfJson
}

let priorityToLabelColor = (priority: priority): TableUtils.labelColor =>
  switch priority {
  | P0 => LabelRed
  | P1 => LabelOrange
  | P2 => LabelYellow
  | P3 | UnknownPriority(_) => LabelGray
  }
