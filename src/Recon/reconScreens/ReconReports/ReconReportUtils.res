// open ReportsTypes
let getArrayDictFromRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}
let getSizeofRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getInt("size", 0)
}

let getHeadersForCSV = () => {
  "Gateway,Merchant Id,Payment Entity Txn Id,Recon Id,Recon Status,Recon Sub Status,Reconciled At,Settlement Amount,Settlement Id,Txn Amount,Txn Currency,Txn Type"
}
