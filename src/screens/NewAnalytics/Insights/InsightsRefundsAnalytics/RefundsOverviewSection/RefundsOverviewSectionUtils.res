open RefundsOverviewSectionTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Total_Refund_Processed_Amount => "total_refund_processed_amount"
  | Total_Refund_Success_Rate => "total_refund_success_rate"
  | Successful_Refund_Count => "successful_refund_count"
  | Failed_Refund_Count => "failed_refund_count"
  | Pending_Refund_Count => "pending_refund_count"
  }
}

let defaultValue =
  {
    total_refund_processed_amount: 0.0,
    total_refund_success_rate: 0.0,
    successful_refund_count: 0,
    failed_refund_count: 0,
    pending_refund_count: 0,
  }
  ->Identity.genericTypeToJson
  ->getDictFromJsonObject

let parseResponse = (response, key) => {
  response
  ->getDictFromJsonObject
  ->getArrayFromDict(key, [])
  ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
}

let getValueFromObj = (data, index, responseKey) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat(responseKey, 0.0)
}

let getKey = (id, ~currency="") => {
  open CurrencyFormatUtils
  let key = switch id {
  | Total_Refund_Success_Rate => #total_refund_success_rate
  | Successful_Refund_Count => #successful_refund_count
  | Failed_Refund_Count => #failed_refund_count
  | Pending_Refund_Count => #pending_refund_count
  | Total_Refund_Processed_Amount =>
    switch currency->getTypeValue {
    | #all_currencies => #total_refund_processed_amount_in_usd
    | _ => #total_refund_processed_amount
    }
  }
  (key: responseKeys :> string)
}

open InsightsTypes
let setValue = (dict, ~data, ~ids: array<overviewColumns>, ~currency) => {
  open NewAnalyticsUtils

  ids->Array.forEach(id => {
    let key = id->getStringFromVariant
    let value = switch id {
    | Total_Refund_Processed_Amount =>
      data->getAmountValue(~id=id->getKey(~currency), ~currency)->JSON.Encode.float
    | _ =>
      data
      ->getFloat(id->getStringFromVariant, 0.0)
      ->JSON.Encode.float
    }

    dict->Dict.set(key, value)
  })
}

let getInfo = (~responseKey: overviewColumns) => {
  switch responseKey {
  | Total_Refund_Success_Rate => {
      titleText: "Refund Success Rate",
      description: "Successful refunds divided by total refunds",
      valueType: Rate,
    }
  | Total_Refund_Processed_Amount => {
      titleText: "Total Refunds Processed",
      description: "Total refunds processed amount on all successful refunds",
      valueType: Amount,
    }
  | Successful_Refund_Count => {
      titleText: "Successful Refunds",
      description: "Total number of refunds that were successfully processed",
      valueType: Volume,
    }
  | Failed_Refund_Count => {
      titleText: "Failed Refunds",
      description: "Total number of refunds that were failed during processing",
      valueType: Volume,
    }
  | Pending_Refund_Count => {
      titleText: "Pending Refunds",
      description: "Total number of refunds currently in pending state",
      valueType: Volume,
    }
  }
}

let modifyStatusCountResponse = response => {
  let queryData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let mapDict = Dict.make()

  queryData->Array.forEach(query => {
    let value = query->getDictFromJsonObject
    let status = value->getString("refund_status", "")
    let count = value->getInt("refund_count", 0)

    if status == (#success: status :> string) {
      mapDict->Dict.set(Successful_Refund_Count->getStringFromVariant, count->JSON.Encode.int)
    }
    if status == (#failure: status :> string) {
      mapDict->Dict.set(Failed_Refund_Count->getStringFromVariant, count->JSON.Encode.int)
    }
    if status == (#pending: status :> string) {
      mapDict->Dict.set(Pending_Refund_Count->getStringFromVariant, count->JSON.Encode.int)
    }
  })

  mapDict
}
