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
