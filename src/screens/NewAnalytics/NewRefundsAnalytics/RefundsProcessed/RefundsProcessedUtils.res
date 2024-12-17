open RefundsProcessedTypes
open NewAnalyticsUtils
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Refund_Processed_Amount => "refund_processed_amount_in_usd"
  | Refund_Processed_Count => "refund_processed_count"
  | Total_Refund_Processed_Amount => "total_refund_processed_amount_in_usd"
  | Total_Refund_Processed_Count => "total_refund_processed_count"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "refund_processed_amount_in_usd" => Refund_Processed_Amount
  | "refund_processed_count" => Refund_Processed_Count
  | "total_refund_processed_amount_in_usd" => Total_Refund_Processed_Amount
  | "total_refund_processed_count" => Total_Refund_Processed_Count
  | "time_bucket" | _ => Time_Bucket
  }
}

let isAmountMetric = key => {
  switch key->getVariantValueFromString {
  | Refund_Processed_Amount
  | Total_Refund_Processed_Amount => true
  | _ => false
  }
}

let refundsProcessedMapper = (
  ~params: NewAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes

  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey, ~isAmount=xKey->isAmountMetric)

  let title = {
    text: "Refunds Processed",
  }

  open NewAnalyticsTypes
  let metricType = switch xKey->getVariantValueFromString {
  | Refund_Processed_Amount => Amount
  | _ => Volume
  }

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Refunds Processed",
    ~metricType,
    ~comparison,
  )

  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    yAxisMaxValue: None,
    tooltipFormatter,
  }
}

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => refundsProcessedObject = dict => {
  {
    refund_processed_amount_in_usd: dict->getAmountValue(
      ~id=Refund_Processed_Amount->getStringFromVariant,
    ),
    refund_processed_count: dict->getInt(Refund_Processed_Count->getStringFromVariant, 0),
    total_refund_processed_amount_in_usd: dict->getAmountValue(
      ~id=Total_Refund_Processed_Amount->getStringFromVariant,
    ),
    total_refund_processed_count: dict->getInt(
      Total_Refund_Processed_Count->getStringFromVariant,
      0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
  }
}

let getObjects: JSON.t => array<refundsProcessedObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Refund_Processed_Amount =>
    Table.makeHeaderInfo(
      ~key=Refund_Processed_Amount->getStringFromVariant,
      ~title="Amount",
      ~dataType=TextType,
    )
  | Refund_Processed_Count =>
    Table.makeHeaderInfo(
      ~key=Refund_Processed_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Total_Refund_Processed_Amount
  | Total_Refund_Processed_Count =>
    Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Refund_Processed_Amount => Text(obj.refund_processed_amount_in_usd->valueFormatter(Amount))
  | Refund_Processed_Count => Text(obj.refund_processed_count->Int.toString)
  | Time_Bucket => Text(obj.time_bucket->formatDateValue(~includeYear=true))
  | Total_Refund_Processed_Amount
  | Total_Refund_Processed_Count =>
    Text("")
  }
}

open NewAnalyticsTypes
let dropDownOptions = [
  {label: "By Amount", value: Refund_Processed_Amount->getStringFromVariant},
  {label: "By Count", value: Refund_Processed_Count->getStringFromVariant},
]

let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: Refund_Processed_Amount->getStringFromVariant,
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getMetaDataMapper = key => {
  let field = key->getVariantValueFromString
  switch field {
  | Refund_Processed_Amount => Total_Refund_Processed_Amount
  | Refund_Processed_Count | _ => Total_Refund_Processed_Count
  }->getStringFromVariant
}

let getKeyForModule = key => {
  key->getVariantValueFromString->getStringFromVariant
}

let modifyQueryData = data => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    switch dataDict->Dict.get(time) {
    | Some(prevVal) => {
        let key = Refund_Processed_Count->getStringFromVariant
        let refundProcessedCount = valueDict->getInt(key, 0)
        let prevProcessedCount = prevVal->getInt(key, 0)
        let key = Refund_Processed_Amount->getStringFromVariant
        let refundProcessedAmount = valueDict->getFloat(key, 0.0)
        let prevProcessedAmount = prevVal->getFloat(key, 0.0)

        let totalRefundProcessedCount = refundProcessedCount + prevProcessedCount
        let totalRefundProcessedAmount = refundProcessedAmount +. prevProcessedAmount

        prevVal->Dict.set(
          Refund_Processed_Count->getStringFromVariant,
          totalRefundProcessedCount->JSON.Encode.int,
        )
        prevVal->Dict.set(
          Refund_Processed_Amount->getStringFromVariant,
          totalRefundProcessedAmount->JSON.Encode.float,
        )

        dataDict->Dict.set(time, prevVal)
      }
    | None => dataDict->Dict.set(time, valueDict)
    }
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}
