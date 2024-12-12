open RefundsOverviewSectionTypes

let getStringFromVariant = value => {
  switch value {
  | Total_Refund_Processed_Amount => "total_refund_processed_amount_in_usd"
  | Total_Refund_Success_Rate => "total_refund_success_rate"
  | Successful_Refund_Count => "successful_refund_count"
  | Failed_Refund_Count => "failed_refund_count"
  | Pending_Refund_Count => "pending_refund_count"
  }
}

let defaultValue =
  {
    total_refund_processed_amount_in_usd: 0.0,
    total_refund_success_rate: 0.0,
    successful_refund_count: 0,
    failed_refund_count: 0,
    pending_refund_count: 0,
  }
  ->Identity.genericTypeToJson
  ->LogicUtils.getDictFromJsonObject

let parseResponse = (response, key) => {
  open LogicUtils
  response
  ->getDictFromJsonObject
  ->getArrayFromDict(key, [])
  ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
}

let getValueFromObj = (data, index, responseKey) => {
  open LogicUtils
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat(responseKey, 0.0)
}

open NewAnalyticsTypes
let setValue = (dict, ~data, ~ids: array<overviewColumns>) => {
  open NewAnalyticsUtils
  open LogicUtils

  ids->Array.forEach(id => {
    let key = id->getStringFromVariant
    let value = switch id {
    | Total_Refund_Processed_Amount =>
      data->getAmountValue(~id=id->getStringFromVariant)->JSON.Encode.float
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
