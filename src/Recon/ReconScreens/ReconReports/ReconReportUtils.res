open ReportsTypes
open LogicUtils

let getArrayDictFromRes = res => {
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}

let getSizeofRes = res => {
  res->getDictFromJsonObject->getInt("size", 0)
}

let getTabFromUrl = search => {
  switch search {
  | "tab=exceptions" => Exceptions
  | _ => All
  }
}

let getReconStatusTypeFromString = (reconStatus: string) => {
  switch reconStatus {
  | "Reconciled" => Reconciled
  | "Unreconciled" => Unreconciled
  | "Missing" => Missing
  | _ => Missing
  }
}

let getHeadersForCSV = () => {
  "Order ID,Transaction ID,Payment Gateway,Payment Method,Txn Amount,Settlement Amount,Recon Status,Transaction Date"
}

let generateDropdownOptionsCustomComponent: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    let option: SelectBox.dropdownOption = {
      label: item.name,
      value: item.id,
    }
    option
  })
  options
}

let getAllReportPayloadType = dict => {
  {
    transaction_id: dict->getString("transaction_id", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_method: dict->getString("payment_method", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    settlement_amount: dict->getFloat("settlement_amount", 0.0),
    recon_status: dict->getString("recon_status", ""),
    transaction_date: dict->getString("transaction_date", ""),
  }
}

let getArrayOfReportsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getAllReportPayloadType
  })
}

let getReportsList: JSON.t => array<allReportPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllReportPayloadType)
}
