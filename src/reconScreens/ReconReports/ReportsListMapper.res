open LogicUtils
open ReportsTypes

let getReportPayloadType = dict => {
  {
    gateway: dict->getString("gateway", ""),
    merchant_id: dict->getString("merchant_id", ""),
    payment_entity_txn_id: dict->getString("payment_entity_txn_id", ""),
    recon_id: dict->getString("recon_id", ""),
    recon_status: dict->getString("recon_status", ""),
    recon_sub_status: dict->getString("recon_sub_status", ""),
    reconciled_at: dict->getString("reconciled_at", ""),
    settlement_amount: dict->getFloat("settlement_amount", 0.0),
    settlement_id: dict->getString("settlement_id", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    txn_currency: dict->getString("txn_currency", ""),
    txn_type: dict->getString("txn_type", ""),
  }
}

let getArrayOfReportsListPayloadType = json => {
  json->Array.map(connectorJson => {
    connectorJson->getDictFromJsonObject->getReportPayloadType
  })
}

let getHeadersForCSV = () => {
  "Gateway,Merchant Id,Payment Entity Txn Id,Recon Id,Recon Status,Recon Sub Status,Reconciled At,Settlement Amount,Settlement Id,Txn Amount,Txn Currency,Txn Type"
}
