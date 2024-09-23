open PaymentsProcessedTypes
open NewPaymentAnalyticsUtils
open LogicUtils

let getData = (json: JSON.t): LineGraphTypes.data => {
  json
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let data =
      item
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getInt("amount", 0)
      })
    let dataObj: LineGraphTypes.dataObj = {
      showInLegend: false,
      name: `Series ${index->Int.toString}`,
      data,
      color: "#2f7ed8",
    }
    dataObj
  })
}

let paymentsProcessedMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getCategories(json)
  let data = getData(json)
  let title = {
    text: "USD",
  }
  {categories, data, title}
}

let visibleColumns = [Count, Amount, Currency, TimeBucket]

let colMapper = (col: paymentsProcessedCols) => {
  switch col {
  | Count => "count"
  | Amount => "amount"
  | Currency => "currency"
  | TimeBucket => "time_bucket"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  {
    count: dict->getInt(Count->colMapper, 0),
    amount: dict->getFloat(Amount->colMapper, 0.0),
    currency: dict->getString(Currency->colMapper, "NA"),
    time_bucket: dict->getString(TimeBucket->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<paymentsProcessedObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | Count => Table.makeHeaderInfo(~key, ~title="Count", ~dataType=TextType)
  | Amount => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType)
  | Currency => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType)
  | TimeBucket => Table.makeHeaderInfo(~key, ~title="Date", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Count => Text(obj.count->Int.toString)
  | Amount => Text(obj.amount->Float.toString)
  | Currency => Text(obj.currency)
  | TimeBucket => Text(obj.time_bucket)
  }
}

let getData2 = {
  "queryData": [
    {"count": 24, "amount": 952, "time_bucket": "2024-08-13 18:30:00"},
    {"count": 28, "amount": 1020, "time_bucket": "2024-08-14 18:30:00"},
    {"count": 35, "amount": 1450, "time_bucket": "2024-08-15 18:30:00"},
    {"count": 30, "amount": 1150, "time_bucket": "2024-08-16 18:30:00"},
    {"count": 40, "amount": 1600, "time_bucket": "2024-08-17 18:30:00"},
    {"count": 29, "amount": 1200, "time_bucket": "2024-08-18 18:30:00"},
    {"count": 31, "amount": 1300, "time_bucket": "2024-08-19 18:30:00"},
  ],
  "metaData": [{"count": 217, "amount": 8672, "currency": "USD"}],
}->Identity.genericObjectOrRecordToJson
