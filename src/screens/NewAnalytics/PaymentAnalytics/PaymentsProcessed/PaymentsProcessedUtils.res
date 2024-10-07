open PaymentsProcessedTypes
open NewPaymentAnalyticsUtils
open LogicUtils
open NewAnalyticsUtils
let getToolTipConparision = (~primaryValue, ~secondaryValue) => {
  let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

  let (textColor, icon) = switch direction {
  | Upward => ("#12B76A", "▲")
  | Downward => ("#F04E42", "▼")
  | No_Change => ("#A0A0A0", "")
  }

  `<span style="color:${textColor};margin-left:7px;" >${icon}${value->valueFormatter(Rate)}</span>`
}

open LineGraphTypes
let tooltipFormatter = (~secondaryCategories) => {
  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">Payments Processed</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)
      let secondaryPoint = this.points->getValueFromArray(1, defaultValue)

      let tableItems = [
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${primartPoint.color}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${primartPoint.x}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueFormatter(
            primartPoint.y,
            Amount,
          )}</div>
        </div>`,
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${secondaryPoint.color}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${secondaryCategories->LogicUtils.getValueFromArray(
            secondaryPoint.point.index,
            "",
          )}${getToolTipConparision(
            ~primaryValue=primartPoint.y,
            ~secondaryValue=secondaryPoint.y,
          )}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left:25px;">${valueFormatter(
            secondaryPoint.y,
            Amount,
          )} </div>
        </div>`,
      ]->Array.joinWith("")

      let content = `
          <div style=" 
          padding:5px 12px;
          border-left: 3px solid #0069FD;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${tableItems}
              </div>
        </div>`

      `<div style="
    padding: 10px;
    width:fit-content;
    border-radius: 7px;
    background-color:#FFFFFF;
    padding:10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    border: 1px solid #E5E5E5;
    position:relative;">
        ${content}
    </div>`
    }
  )->asTooltipPointFormatter
}

let paymentsProcessedMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData =
    data
    ->getArrayFromJson([])
    ->Array.mapWithIndex((item, index) => {
      let name = `Series ${(index + 1)->Int.toString}`
      let color = index->getColor
      getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color)
    })
  let title = {
    text: "Payments Processed",
  }
  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    tooltipFormatter: tooltipFormatter(~secondaryCategories),
  }
}
// Need to modify
let getMetaData = json =>
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject
  ->getArrayFromDict("metaData", [])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject

open NewAnalyticsTypes
let visibleColumns: array<metrics> = [#payment_processed_amount, #payment_count, #time_bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  {
    payment_count: dict->getInt((#payment_count: metrics :> string), 0),
    payment_processed_amount: dict->getFloat((#payment_processed_amount: metrics :> string), 0.0),
    time_bucket: dict->getString((#time_bucket: metrics :> string), "NA"),
  }
}

let getObjects: JSON.t => array<paymentsProcessedObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = (colType: metrics) => {
  switch colType {
  | #payment_count =>
    Table.makeHeaderInfo(
      ~key=(#payment_count: metrics :> string),
      ~title="Count",
      ~dataType=TextType,
    )
  | #payment_processed_amount =>
    Table.makeHeaderInfo(
      ~key=(#payment_processed_amount: metrics :> string),
      ~title="Amount",
      ~dataType=TextType,
    )
  | #time_bucket | _ =>
    Table.makeHeaderInfo(~key=(#time_bucket: metrics :> string), ~title="Date", ~dataType=TextType)
  }
}

let getCell = (obj, colType: metrics): Table.cell => {
  switch colType {
  | #payment_count => Text(obj.payment_count->Int.toString)
  | #payment_processed_amount => Text(obj.payment_processed_amount->Float.toString)
  | #time_bucket | _ => Text(obj.time_bucket)
  }
}

let dropDownOptions = [
  {label: "By Amount", value: (#payment_processed_amount: metrics :> string)},
  {label: "By Count", value: (#payment_count: metrics :> string)},
]

let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: (#payment_processed_amount: metrics :> string),
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getMetaDataKey = key => {
  switch key {
  | "payment_processed_amount" => "total_payment_processed_amount"
  | "payment_count" => "total_payment_processed_count"
  | _ => ""
  }
}
