open RefundsReasonsTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Refund_Reason => "refund_reason"
  | Refund_Reason_Count => "refund_reason_count"
  | Total_Refund_Reason_Count => "total_refund_reason_count"
  | Refund_Reason_Count_Ratio => "refund_reason_count_ratio"
  | Connector => "connector"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => failreResonsObjectType = dict => {
  {
    refund_reason: dict->getString(Refund_Reason->getStringFromVariant, ""),
    refund_reason_count: dict->getInt(Refund_Reason_Count->getStringFromVariant, 0),
    total_refund_reason_count: dict->getInt(Total_Refund_Reason_Count->getStringFromVariant, 0),
    refund_reason_count_ratio: dict->getFloat(Refund_Reason_Count_Ratio->getStringFromVariant, 0.0),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<failreResonsObjectType> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Refund_Reason =>
    Table.makeHeaderInfo(
      ~key=Refund_Reason->getStringFromVariant,
      ~title="Refund Reason",
      ~dataType=TextType,
    )
  | Refund_Reason_Count =>
    Table.makeHeaderInfo(
      ~key=Refund_Reason_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Total_Refund_Reason_Count =>
    Table.makeHeaderInfo(
      ~key=Total_Refund_Reason_Count->getStringFromVariant,
      ~title="",
      ~dataType=TextType,
    )
  | Refund_Reason_Count_Ratio =>
    Table.makeHeaderInfo(
      ~key=Refund_Reason_Count_Ratio->getStringFromVariant,
      ~title="Ratio",
      ~dataType=TextType,
    )
  | Connector =>
    Table.makeHeaderInfo(
      ~key=Connector->getStringFromVariant,
      ~title="Connector",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Refund_Reason => Text(obj.refund_reason)
  | Refund_Reason_Count => Text(obj.refund_reason_count->Int.toString)
  | Total_Refund_Reason_Count => Text(obj.total_refund_reason_count->Int.toString)
  | Refund_Reason_Count_Ratio =>
    Text(obj.refund_reason_count_ratio->CurrencyFormatUtils.valueFormatter(Rate))
  | Connector => Text(obj.connector)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let modifyQuery = (queryData, metaData) => {
  let totalCount = switch metaData->Array.get(0) {
  | Some(val) => {
      let valueDict = val->getDictFromJsonObject
      let failure_reason_count =
        valueDict->getInt(Total_Refund_Reason_Count->getStringFromVariant, 0)
      failure_reason_count
    }
  | _ => 0
  }

  let modifiedQuery = if totalCount > 0 {
    queryData->Array.map(query => {
      let valueDict = query->getDictFromJsonObject
      let failure_reason_count = valueDict->getInt(Refund_Reason_Count->getStringFromVariant, 0)
      let ratio = failure_reason_count->Int.toFloat /. totalCount->Int.toFloat *. 100.0

      valueDict->Dict.set(Refund_Reason_Count_Ratio->getStringFromVariant, ratio->JSON.Encode.float)
      valueDict->JSON.Encode.object
    })
  } else {
    queryData
  }

  modifiedQuery->Array.sort((queryA, queryB) => {
    let valueDictA = queryA->getDictFromJsonObject
    let valueDictB = queryB->getDictFromJsonObject

    let failure_reason_countA = valueDictA->getInt(Refund_Reason_Count->getStringFromVariant, 0)
    let failure_reason_countB = valueDictB->getInt(Refund_Reason_Count->getStringFromVariant, 0)

    compareLogic(failure_reason_countA, failure_reason_countB)
  })

  modifiedQuery
}
