open LogicUtils
open AlertsTypes

let blacklistKeys = [MerchantIdKey, ProfileIdKey]
let allDimensionKeys = [MerchantIdKey, ProfileIdKey, ConnectorKey, PaymentMethodKey]

let parseJsonString = (dict, key) => dict->getString(key, "{}")->safeParse

let priorityFromString = priority =>
  switch priority {
  | "P0" => P0
  | "P1" => P1
  | "P2" => P2
  | "P3" => P3
  | other => UnknownPriority(other)
  }

let getSnoozeEntry = (alert: alert) =>
  alert.snooze
  ->getDictFromJsonObject
  ->Dict.valuesToArray
  ->getValueFromArray(0, JSON.Encode.null)
  ->getDictFromJsonObject

let getBlacklistFields = (alert: alert) =>
  alert.metadata
  ->getDictFromJsonObject
  ->getDictfromDict((BlacklistKey :> string))
  ->Dict.valuesToArray
  ->Array.flatMap(entry => entry->getDictFromJsonObject->Dict.toArray)

let itemToObjMapper = (dict: Dict.t<JSON.t>): alert => {
  let dimensions = dict->parseJsonString("dimensions")
  let metadata = dict->parseJsonString("metadata")
  let snooze = dict->parseJsonString("snooze")
  let dimensionsDict = dimensions->getDictFromJsonObject
  let statsDict = dict->parseJsonString("metadata_alert_details")->getDictFromJsonObject

  {
    id: dict->getString("id", ""),
    name: dict->getString("name", ""),
    product: dict->getString("product", ""),
    merchantId: dict->getString("merchant_id", ""),
    profileId: dimensionsDict->getString("profile_id", ""),
    connector: dimensionsDict->getString("connector", ""),
    paymentMethod: dimensionsDict->getString("payment_method", ""),
    tsAlert: dict->getString("ts_alert", ""),
    startTime: dict->getString("start_time", ""),
    endTime: dict->getString("end_time", ""),
    priority: dict->getString("priority", "")->priorityFromString,
    attribution: dict->getString("attribution", ""),
    successRate: statsDict->getFloat("success_rate", 0.0),
    thresholdSr: statsDict->getFloat("threshold_sr", 0.0),
    failed: statsDict->getFloat("failed", 0.0),
    total: statsDict->getFloat("total", 0.0),
    isBlacklisted: metadata
    ->getDictFromJsonObject
    ->getString((IsBlacklistedKey :> string), "") === (Blacklisted :> string),
    isSnoozed: snooze->getDictFromJsonObject->Dict.keysToArray->isNonEmptyArray,
    dimensions,
    metadata,
    snooze,
  }
}

let alertsResponseMapper = (json: JSON.t): array<alert> =>
  json->getArrayFromJson([])->Array.map(row => row->getDictFromJsonObject->itemToObjMapper)

let responseToAlertDetail = (json: JSON.t): alert =>
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, JSON.Encode.null)
  ->getDictFromJsonObject
  ->itemToObjMapper

let dictionaryResponseToOptions = (json: JSON.t, key: string): array<string> =>
  json
  ->getArrayFromJson([])
  ->Array.map(getDictFromJsonObject)
  ->Array.find(row => row->getString("key_", "") === key)
  ->Option.map(row => row->getString("values_", "[]"))
  ->Option.getOr("[]")
  ->safeParse
  ->getStrArrayFromJson

let alertsDictionaryResponseMapper = (json: JSON.t): alertsDictionary => {
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

let formatSuccessRateSummary = (alert: alert): string =>
  `${alert.successRate
    ->Float.toInt
    ->Int.toString}% (threshold ${alert.thresholdSr->Float.toFixedWithPrecision(
      ~digits=1,
    )}%), ${alert.failed->Float.toString} of ${alert.total->Float.toString} payments failed`

let buildListBody = (
  ~limit,
  ~offset,
  ~startTime,
  ~endTime,
  ~filterValueJson: Dict.t<JSON.t>,
  ~isResolved,
) => {
  let excludedKeys = [HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]

  let extraFilters =
    filterValueJson
    ->Dict.toArray
    ->Array.filter(((key, _)) => !(excludedKeys->Array.includes(key)))

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
    ("is_resolved", isResolved->JSON.Encode.bool),
  ]
  ->Array.concat(extraFilters)
  ->getJsonFromArrayOfJson
}

let priorityToLabelColor = (priority: priority): TableUtils.labelColor =>
  switch priority {
  | P0 => LabelRed
  | P1 => LabelOrange
  | P2 => LabelYellow
  | P3 | UnknownPriority(_) => LabelGray
  }

let rawDataTabs = (alert: alert): array<Tabs.tab> => [
  {
    title: "Metadata",
    renderContent: () =>
      <div className="pt-4">
        <PrettyPrintJson jsonToDisplay={alert.metadata->JSON.stringify} headerText=None />
      </div>,
  },
  {
    title: "Dimensions",
    renderContent: () =>
      <div className="pt-4">
        <PrettyPrintJson jsonToDisplay={alert.dimensions->JSON.stringify} headerText=None />
      </div>,
  },
  {
    title: "Snoozes",
    renderContent: () =>
      <div className="pt-4">
        <PrettyPrintJson jsonToDisplay={alert.snooze->JSON.stringify} headerText=None />
      </div>,
  },
  {
    title: "Blacklist",
    renderContent: () =>
      <div className="pt-4">
        <PrettyPrintJson
          jsonToDisplay={alert.metadata
          ->getDictFromJsonObject
          ->getJsonObjectFromDict((BlacklistKey :> string))
          ->JSON.stringify}
          headerText=None
        />
      </div>,
  },
]

let omitUnselectedDimensions = (entry: Dict.t<JSON.t>, ~selectedKeys) => {
  let entry = entry->Dict.copy
  allDimensionKeys->Array.forEach(key => {
    let key = (key :> string)
    if !(selectedKeys->Array.includes(key)) {
      entry->Dict.delete(key)
    }
  })
  entry->JSON.Encode.object
}

let getResolveInitialValues = (alert: alert) =>
  [("id", alert.id->JSON.Encode.string), ("metadata", alert.metadata)]->getJsonFromArrayOfJson

let getCommentInitialValues = (alert: alert, ~email) =>
  [
    ("id", alert.id->JSON.Encode.string),
    (
      "metadata",
      alert.metadata
      ->getDictFromJsonObject
      ->Dict.toArray
      ->Array.concat([
        ("lastModifiedBy", (email->isNonEmptyString ? email : "dashboard")->JSON.Encode.string),
      ])
      ->getJsonFromArrayOfJson,
    ),
  ]->getJsonFromArrayOfJson

let getBlacklistInitialValues = (alert: alert) =>
  [
    ("name", alert.name->JSON.Encode.string),
    (
      "blacklistKeys",
      blacklistKeys->Array.map(key => (key :> string)->JSON.Encode.string)->JSON.Encode.array,
    ),
    (
      "blacklist",
      [
        [
          ((MerchantIdKey :> string), alert.merchantId->JSON.Encode.string),
          ((ProfileIdKey :> string), alert.profileId->JSON.Encode.string),
        ]->getJsonFromArrayOfJson,
      ]->JSON.Encode.array,
    ),
  ]->getJsonFromArrayOfJson

let getSnoozeInitialValues = (alert: alert) => {
  let dimensionValues = [
    ((MerchantIdKey :> string), alert.merchantId),
    ((ProfileIdKey :> string), alert.profileId),
    ((ConnectorKey :> string), alert.connector),
    ((PaymentMethodKey :> string), alert.paymentMethod),
  ]

  [
    (
      "snoozeKeys",
      dimensionValues
      ->Array.filter(((_, value)) => value->isNonEmptyString)
      ->Array.map(((key, _)) => key->JSON.Encode.string)
      ->JSON.Encode.array,
    ),
    (
      "entry",
      dimensionValues
      ->Array.map(((key, value)) => (key, value->JSON.Encode.string))
      ->getJsonFromArrayOfJson,
    ),
  ]->getJsonFromArrayOfJson
}

let selectField = (~label, ~name, ~options) =>
  <FormRenderer.FieldRenderer
    field={FormRenderer.makeFieldInfo(
      ~label,
      ~name,
      ~customInput=InputFields.selectInput(
        ~options=options->SelectBox.makeOptions,
        ~buttonText="Select",
        ~marginTop="mt-0",
        ~fullLength=true,
      ),
    )}
  />
