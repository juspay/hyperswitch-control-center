let tableBorderClass = "border-collapse border border-jp-gray-940 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

type errorObject = {
  error_reason: string,
  count: int,
  connector: string,
}

let getTableData = (array: array<JSON.t>) => {
  open LogicUtils
  let data = []

  array->Array.forEach(item => {
    let valueDict = item->LogicUtils.getDictFromJsonObject

    let connector = valueDict->LogicUtils.getString("connector", "")

    let paymentErrorMessage = valueDict->LogicUtils.getArrayFromDict("payment_error_message", [])

    if connector->LogicUtils.isNonEmptyString && paymentErrorMessage->Array.length > 0 {
      paymentErrorMessage->Array.forEach(value => {
        let errorDict = value->LogicUtils.getDictFromJsonObject

        let obj = {
          error_reason: errorDict->getString("reason", ""),
          count: errorDict->getInt("count", 0),
          connector,
        }

        data->Array.push(obj)
      })
    }
  })

  data->Array.sort((a, b) => {
    let rowValue_a = a.count
    let rowValue_b = b.count

    rowValue_a <= rowValue_b ? 1. : -1.
  })

  data
}

type cols =
  | ErrorReason
  | Count

  | Connector

let visibleColumns = [Connector, ErrorReason, Count]

let colMapper = (col: cols) => {
  switch col {
  | ErrorReason => "error_reason"
  | Count => "count"
  | Connector => "connector"
  }
}

let tableItemToObjMapper: 'a => errorObject = dict => {
  open LogicUtils
  {
    error_reason: dict->getString(ErrorReason->colMapper, "NA"),
    count: dict->getInt(Count->colMapper, 0),
    connector: dict->getString(Connector->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<errorObject> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | ErrorReason =>
    Table.makeHeaderInfo(~key, ~title="Error Reason", ~dataType=TextType, ~showSort=false)
  | Count =>
    Table.makeHeaderInfo(~key, ~title="Total Occurences", ~dataType=TextType, ~showSort=false)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType, ~showSort=false)
  }
}

let getCell = (errorObj, colType): Table.cell => {
  switch colType {
  | ErrorReason => Text(errorObj.error_reason)
  | Count => Text(errorObj.count->Int.toString)
  | Connector => Text(errorObj.connector)
  }
}

let tableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
)
