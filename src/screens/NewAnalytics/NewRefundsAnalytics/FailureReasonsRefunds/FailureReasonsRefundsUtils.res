open FailureReasonsRefundsTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Refund_Error_Message => "refund_error_message"
  | Refund_Error_Message_Count => "refund_error_message_count"
  | Total_Refund_Error_Message_Count => "total_refund_error_message_count"
  | Refund_Error_Message_Count_Ratio => "refund_error_message_count_ratio"
  | Connector => "connector"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => failreResonsObjectType = dict => {
  {
    refund_error_message: dict->getString(Refund_Error_Message->getStringFromVariant, ""),
    refund_error_message_count: dict->getInt(Refund_Error_Message_Count->getStringFromVariant, 0),
    total_refund_error_message_count: dict->getInt(
      Total_Refund_Error_Message_Count->getStringFromVariant,
      0,
    ),
    refund_error_message_count_ratio: dict->getFloat(
      Refund_Error_Message_Count_Ratio->getStringFromVariant,
      0.0,
    ),
    connector: dict->getString(Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<failreResonsObjectType> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Refund_Error_Message =>
    Table.makeHeaderInfo(
      ~key=Refund_Error_Message->getStringFromVariant,
      ~title="Error Reason",
      ~dataType=TextType,
    )
  | Refund_Error_Message_Count =>
    Table.makeHeaderInfo(
      ~key=Refund_Error_Message_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Total_Refund_Error_Message_Count =>
    Table.makeHeaderInfo(
      ~key=Total_Refund_Error_Message_Count->getStringFromVariant,
      ~title="",
      ~dataType=TextType,
    )
  | Refund_Error_Message_Count_Ratio =>
    Table.makeHeaderInfo(
      ~key=Refund_Error_Message_Count_Ratio->getStringFromVariant,
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
  | Refund_Error_Message => Text(obj.refund_error_message)
  | Refund_Error_Message_Count => Text(obj.refund_error_message_count->Int.toString)
  | Total_Refund_Error_Message_Count => Text(obj.total_refund_error_message_count->Int.toString)
  | Refund_Error_Message_Count_Ratio =>
    Text(obj.refund_error_message_count_ratio->valueFormatter(Rate))
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
        valueDict->getInt(Total_Refund_Error_Message_Count->getStringFromVariant, 0)
      failure_reason_count
    }
  | _ => 0
  }

  let modifiedQuery = if totalCount > 0 {
    queryData->Array.map(query => {
      let valueDict = query->getDictFromJsonObject
      let failure_reason_count =
        valueDict->getInt(Refund_Error_Message_Count->getStringFromVariant, 0)
      let ratio = failure_reason_count->Int.toFloat /. totalCount->Int.toFloat *. 100.0

      valueDict->Dict.set(
        Refund_Error_Message_Count_Ratio->getStringFromVariant,
        ratio->JSON.Encode.float,
      )
      valueDict->JSON.Encode.object
    })
  } else {
    queryData
  }

  modifiedQuery->Array.sort((queryA, queryB) => {
    let valueDictA = queryA->getDictFromJsonObject
    let valueDictB = queryB->getDictFromJsonObject

    let failure_reason_countA =
      valueDictA->getInt(Refund_Error_Message_Count->getStringFromVariant, 0)
    let failure_reason_countB =
      valueDictB->getInt(Refund_Error_Message_Count->getStringFromVariant, 0)

    compareLogic(failure_reason_countA, failure_reason_countB)
  })

  modifiedQuery
}
