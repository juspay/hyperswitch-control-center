open LogicUtils

type tableDetails = {
  orderId: string,
  merchantId: string,
  timestamp: string,
}

type colType =
  | OrderID
  | MerchantID
  | Timestamp

let defaultColumns = [OrderID, MerchantID, Timestamp]

let allColumns = defaultColumns

let filterByData = (actualData, value) => {
  let searchText = getStringFromJson(value, "")->Js.String2.toLowerCase

  actualData
  ->Belt.Array.keepMap(Js.Nullable.toOption)
  ->Belt.Array.keepMap((data: tableDetails) => {
    let dict = Js.Dict.empty()
    dict->Js.Dict.set("orderId", data.orderId)
    dict->Js.Dict.set("merchantId", data.merchantId)
    dict->Js.Dict.set("timestamp", data.timestamp)

    let isMatched =
      dict
      ->Js.Dict.values
      ->Js.Array2.map(val => {
        val->Js.String2.toLowerCase->Js.String2.includes(searchText)
      })
      ->Js.Array2.includes(true)

    if isMatched {
      data->Js.Nullable.return->Some
    } else {
      None
    }
  })
}

let itemToObjMapper = dict => {
  {
    orderId: getString(dict, "order_id", ""),
    merchantId: getString(dict, "merchant_id", ""),
    timestamp: getString(dict, "time_bucket", ""),
  }
}

let getTableDetails: Js.Json.t => array<tableDetails> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let getHeading = colType => {
  switch colType {
  | OrderID => Table.makeHeaderInfo(~key="orderId", ~title="Order ID", ~showSort=true, ())
  | MerchantID => Table.makeHeaderInfo(~key="merchantId", ~title="Merchant ID", ~showSort=true, ())
  | Timestamp => Table.makeHeaderInfo(~key="timestamp", ~title="Timestamp", ~showSort=true, ())
  }
}

let getCell = (tableDetails, colType): Table.cell => {
  switch colType {
  | OrderID => Text(tableDetails.orderId)
  | MerchantID => Text(tableDetails.merchantId)
  | Timestamp => Date(tableDetails.timestamp)
  }
}

let summayTableEntity = url =>
  EntityType.makeEntity(
    ~uri=url,
    ~getObjects=getTableDetails,
    ~allColumns,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    (),
  )
