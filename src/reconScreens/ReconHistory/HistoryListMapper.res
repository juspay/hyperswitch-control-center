open LogicUtils
open HistoryTypes

let getHistoryPayloadType = dict => {
  {
    gateway: dict->getString("gateway", ""),
    recon_uuid: dict->getString("recon_uuid", ""),
    merchant_id: dict->getString("merchant_id", ""),
    recon_status: dict->getString("recon_status", ""),
    recon_started_at: dict->getString("recon_started_at", ""),
    file_uuid: dict->getString("file_uuid", ""),
    batch_id: dict->getString("batch_id", ""),
    system_a_file_id: dict->getString("system_a_file_id", ""),
    system_b_file_id: dict->getString("system_b_file_id", ""),
    system_c_file_id: dict->getString("system_c_file_id", "null"),
    recon_ended_at: dict->getString("recon_ended_at", ""),
  }
}

let getArrayOfHistoryListPayloadType = json => {
  json->Array.map(historyJson => {
    historyJson->getDictFromJsonObject->getHistoryPayloadType
  })
}
