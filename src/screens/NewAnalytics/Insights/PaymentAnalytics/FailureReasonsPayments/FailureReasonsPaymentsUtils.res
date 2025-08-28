open FailureReasonsPaymentsTypes
open LogicUtils
open NewAnalyticsTypes

let getStringFromVariant = value => {
  switch value {
  | Error_Reason => "error_reason"
  | Failure_Reason_Count => "failure_reason_count"
  | Reasons_Count_Ratio => "reasons_count_ratio"
  | Total_Failure_Reasons_Count => "total_failure_reasons_count"
  | Connector => "connector"
  | Payment_Method => "payment_method"
  | Payment_Method_Type => "payment_method_type"
  | Authentication_Type => "authentication_type"
  }
}

let getColumn = string => {
  switch string {
  | "connector" => Connector
  | "payment_method" => Payment_Method
  | "payment_method_type" => Payment_Method_Type
  | "authentication_type" => Authentication_Type
  | _ => Connector
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => failreResonsObjectType = dict => {
  {
    error_reason: dict->getString(Error_Reason->getStringFromVariant, ""),
    failure_reason_count: dict->getInt(Failure_Reason_Count->getStringFromVariant, 0),
    total_failure_reasons_count: dict->getInt(Total_Failure_Reasons_Count->getStringFromVariant, 0),
    reasons_count_ratio: dict->getFloat(Reasons_Count_Ratio->getStringFromVariant, 0.0),
    connector: dict->getString(Connector->getStringFromVariant, ""),
    payment_method: dict->getString(Payment_Method->getStringFromVariant, ""),
    payment_method_type: dict->getString(Payment_Method_Type->getStringFromVariant, ""),
    authentication_type: dict->getString(Authentication_Type->getStringFromVariant, ""),
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
  | Error_Reason =>
    Table.makeHeaderInfo(
      ~key=Error_Reason->getStringFromVariant,
      ~title="Error Reason",
      ~dataType=TextType,
    )
  | Failure_Reason_Count =>
    Table.makeHeaderInfo(
      ~key=Failure_Reason_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Reasons_Count_Ratio =>
    Table.makeHeaderInfo(
      ~key=Reasons_Count_Ratio->getStringFromVariant,
      ~title="Ratio (%)",
      ~dataType=TextType,
    )
  | Total_Failure_Reasons_Count =>
    Table.makeHeaderInfo(
      ~key=Total_Failure_Reasons_Count->getStringFromVariant,
      ~title="",
      ~dataType=TextType,
    )
  | Connector =>
    Table.makeHeaderInfo(
      ~key=Connector->getStringFromVariant,
      ~title="Connector",
      ~dataType=TextType,
    )
  | Payment_Method =>
    Table.makeHeaderInfo(
      ~key=Payment_Method->getStringFromVariant,
      ~title="Payment Method",
      ~dataType=TextType,
    )
  | Payment_Method_Type =>
    Table.makeHeaderInfo(
      ~key=Payment_Method_Type->getStringFromVariant,
      ~title="Payment Method Type",
      ~dataType=TextType,
    )
  | Authentication_Type =>
    Table.makeHeaderInfo(
      ~key=Authentication_Type->getStringFromVariant,
      ~title="Authentication Type",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Error_Reason => Text(obj.error_reason)
  | Failure_Reason_Count => Text(obj.failure_reason_count->Int.toString)
  | Reasons_Count_Ratio => Text(obj.reasons_count_ratio->valueFormatter(Rate))
  | Total_Failure_Reasons_Count => Text(obj.total_failure_reasons_count->Int.toString)
  | Connector => Text(obj.connector)
  | Payment_Method => Text(obj.payment_method)
  | Payment_Method_Type => Text(obj.payment_method_type)
  | Authentication_Type => Text(obj.authentication_type)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let tabs = [
  {
    label: "Connector",
    value: Connector->getStringFromVariant,
  },
  {
    label: "Payment Method",
    value: Payment_Method->getStringFromVariant,
  },
  {
    label: "Payment Method Type",
    value: Payment_Method_Type->getStringFromVariant,
  },
  {
    label: "Authentication Type",
    value: Authentication_Type->getStringFromVariant,
  },
  {
    label: "Payment Method + Payment Method Type",
    value: `${Payment_Method->getStringFromVariant},${Payment_Method_Type->getStringFromVariant}`,
  },
]

let defaulGroupBy = {
  label: "Connector",
  value: Connector->getStringFromVariant,
}

let modifyQuery = (queryData, metaData) => {
  let totalCount = switch metaData->Array.get(0) {
  | Some(val) => {
      let valueDict = val->getDictFromJsonObject
      let failure_reason_count =
        valueDict->getInt(Total_Failure_Reasons_Count->getStringFromVariant, 0)
      failure_reason_count
    }
  | _ => 0
  }

  let modifiedQuery = if totalCount > 0 {
    queryData->Array.map(query => {
      let valueDict = query->getDictFromJsonObject
      let failure_reason_count = valueDict->getInt(Failure_Reason_Count->getStringFromVariant, 0)
      let ratio = failure_reason_count->Int.toFloat /. totalCount->Int.toFloat *. 100.0

      valueDict->Dict.set(Reasons_Count_Ratio->getStringFromVariant, ratio->JSON.Encode.float)
      valueDict->JSON.Encode.object
    })
  } else {
    queryData
  }

  modifiedQuery->Array.sort((queryA, queryB) => {
    let valueDictA = queryA->getDictFromJsonObject
    let valueDictB = queryB->getDictFromJsonObject

    let failure_reason_countA = valueDictA->getInt(Failure_Reason_Count->getStringFromVariant, 0)
    let failure_reason_countB = valueDictB->getInt(Failure_Reason_Count->getStringFromVariant, 0)

    compareLogic(failure_reason_countA, failure_reason_countB)
  })

  modifiedQuery
}
