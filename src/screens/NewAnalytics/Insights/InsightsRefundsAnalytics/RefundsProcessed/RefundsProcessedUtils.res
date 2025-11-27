open RefundsProcessedTypes
open InsightsUtils
open NewAnalyticsUtils
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Refund_Processed_Amount => "refund_processed_amount"
  | Refund_Processed_Count => "refund_processed_count"
  | Total_Refund_Processed_Amount => "total_refund_processed_amount"
  | Total_Refund_Processed_Count => "total_refund_processed_count"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "refund_processed_amount" | "refund_processed_amount_in_usd" => Refund_Processed_Amount
  | "refund_processed_count" => Refund_Processed_Count
  | "total_refund_processed_amount" | "total_refund_processed_amount_in_usd" =>
    Total_Refund_Processed_Amount
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
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes

  let {data, xKey, yKey} = params
  let currency = params.currency->Option.getOr("")
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData =
    data->getLineGraphData(~xKey, ~yKey, ~isAmount=xKey->isAmountMetric, ~currency)

  open LogicUtilsTypes
  let metricType = switch xKey->getVariantValueFromString {
  | Refund_Processed_Amount => Amount
  | _ => Volume
  }

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Refunds Processed",
    ~metricType,
    ~comparison,
    ~currency,
  )

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: primaryCategories,
    data: lineGraphData,
    title: {
      text: "",
    },
    yAxisMaxValue: None,
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Default,
      ~currency="",
      ~suffix="",
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  }
}

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => refundsProcessedObject = dict => {
  let currency = dict->getString("currency", "")
  {
    refund_processed_amount: dict->getAmountValue(
      ~id=Refund_Processed_Amount->getStringFromVariant,
      ~currency,
    ),
    refund_processed_count: dict->getInt(Refund_Processed_Count->getStringFromVariant, 0),
    total_refund_processed_amount: dict->getAmountValue(
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
  ->getArrayFromJson([])
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
  | Refund_Processed_Amount => Text(obj.refund_processed_amount->valueFormatter(Amount))
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

let tabs = [{label: "Daily", value: (#G_ONEDAY: NewAnalyticsTypes.granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: Refund_Processed_Amount->getStringFromVariant,
}

let defaultGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: NewAnalyticsTypes.granularity :> string),
}

let getKeyForModule = key => {
  key->getVariantValueFromString->getStringFromVariant
}

let getKey = (id, ~currency="") => {
  let key = switch id {
  | Refund_Processed_Count => #refund_processed_count

  | Total_Refund_Processed_Count => #total_refund_processed_count
  | Time_Bucket => #time_bucket
  | Refund_Processed_Amount =>
    switch currency->getTypeValue {
    | #all_currencies => #refund_processed_amount_in_usd
    | _ => #refund_processed_amount
    }
  | Total_Refund_Processed_Amount =>
    switch currency->getTypeValue {
    | #all_currencies => #total_refund_processed_amount_in_usd
    | _ => #total_refund_processed_amount
    }
  }
  (key: responseKeys :> string)
}

let getMetaDataMapper = (key, ~currency) => {
  let field = key->getVariantValueFromString
  switch field {
  | Refund_Processed_Amount => Total_Refund_Processed_Amount->getKey(~currency)
  | Refund_Processed_Count | _ => Total_Refund_Processed_Count->getStringFromVariant
  }
}

let modifyQueryData = (data, ~currency) => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    let key = Refund_Processed_Count->getStringFromVariant
    let refundProcessedCount = valueDict->getInt(key, 0)

    let key = Refund_Processed_Amount->getKey(~currency)
    let refundProcessedAmount = valueDict->getFloat(key, 0.0)

    switch dataDict->Dict.get(time) {
    | Some(prevVal) => {
        let key = Refund_Processed_Count->getStringFromVariant
        let prevProcessedCount = prevVal->getInt(key, 0)

        let key = Refund_Processed_Amount->getStringFromVariant
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
    | None => {
        valueDict->Dict.set(
          Refund_Processed_Count->getStringFromVariant,
          refundProcessedCount->JSON.Encode.int,
        )
        valueDict->Dict.set(
          Refund_Processed_Amount->getStringFromVariant,
          refundProcessedAmount->JSON.Encode.float,
        )

        dataDict->Dict.set(time, valueDict)
      }
    }
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}
