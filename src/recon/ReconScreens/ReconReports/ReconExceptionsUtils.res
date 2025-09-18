open ReportsTypes
open LogicUtils

let getExceptionMatrixPayloadType = dict => {
  {
    source: dict->getString("source", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    settlement_date: dict->getString("settlement_date", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    fee_amount: dict->getFloat("fee_amount", 0.0),
  }
}

let getExceptionMatrixList: JSON.t => array<exceptionMatrixPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getExceptionMatrixPayloadType)
}

let getExceptionReportPayloadType = dict => {
  {
    transaction_id: dict->getString("transaction_id", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_method: dict->getString("payment_method", ""),
    recon_status: dict->getString("recon_status", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    exception_type: dict->getString("exception_type", ""),
    transaction_date: dict->getString("transaction_date", ""),
    settlement_amount: dict->getFloat("settlement_amount", 0.0),
    exception_matrix: dict
    ->getArrayFromDict("exception_matrix", [])
    ->JSON.Encode.array
    ->getExceptionMatrixList,
  }
}

let getExceptionReportsList: JSON.t => array<reportExceptionsPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getExceptionReportPayloadType)
}

let getArrayOfReportsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getExceptionReportPayloadType
  })
}
let getArrayOfReportsAttemptsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getExceptionMatrixPayloadType
  })
}

let getExceptionsStatusTypeFromString = string => {
  switch string {
  | "Amount Mismatch" => AmountMismatch
  | "Status Mismatch" => StatusMismatch
  | "Both" => Both
  | "Resolved" => Resolved
  | _ => Resolved
  }
}

let getExceptionStringFromStatus = status => {
  switch status {
  | AmountMismatch => "Amount Mismatch"
  | StatusMismatch => "Status Mismatch"
  | Both => "Amount & Status Mismatch"
  | Resolved => "Resolved"
  }
}

let validateNoteField = (values: JSON.t) => {
  let data = values->getDictFromJsonObject
  let errors = Dict.make()

  let errorMessage = if data->getString("note", "")->isEmptyString {
    "Note cannot be empty!"
  } else {
    ""
  }
  if errorMessage->isNonEmptyString {
    Dict.set(errors, "Error", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}
