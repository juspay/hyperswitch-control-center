open BlocklistTypes
open LogicUtils

let sampleCsv = `type,data,metadata
card_bin,411111,source=fraud_team;reason=chargeback
extended_card_bin,41111100,
fingerprint,fp_abc123,`

let maxBlocklistCsvFileSize = 5 * 1024 * 1024
let bytesPerKilobyte = 1024
let bytesPerMegabyte = bytesPerKilobyte * 1024

let itemToObjMapper = dict => {
  {
    job_id: dict->getString("job_id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    status: dict->getString("status", ""),
    total_rows: dict->getInt("total_rows", 0),
    succeeded_rows: dict->getInt("succeeded_rows", 0),
    failed_rows: dict->getInt("failed_rows", 0),
    created_at: dict->getString("created_at", ""),
    updated_at: dict->getString("updated_at", ""),
  }
}

let getJobsFromResponse = json => {
  let dict = json->getDictFromJsonObject
  dict
  ->getArrayFromDict("data", [])
  ->Array.filterMap(JSON.Decode.object)
  ->Array.map(itemToObjMapper)
}

let getTotalCountFromResponse = (json, fallback) => {
  let dict = json->getDictFromJsonObject
  dict->getInt("total_count", dict->getInt("count", fallback))
}

let getBlocklistBatchStatusFromString = status => {
  switch status->String.toLowerCase {
  | "initiated" => Initiated
  | "processing" => Processing
  | "completed" => Completed
  | "failed" => Failed
  | _ => UnknownStatus
  }
}

let statusLabelColor = status => {
  switch status->getBlocklistBatchStatusFromString {
  | Initiated | Processing => Table.LabelOrange
  | Completed => Table.LabelGreen
  | Failed => Table.LabelRed
  | UnknownStatus => Table.LabelGray
  }
}

let isTerminalStatus = status => {
  switch status->getBlocklistBatchStatusFromString {
  | Completed | Failed => true
  | Initiated | Processing | UnknownStatus => false
  }
}

let normalizeStatus = status => status->isNonEmptyString ? status->snakeToTitle : "Unknown"

let isCsvFileName = fileName => fileName->String.toLowerCase->String.endsWith(".csv")

let isValidBlocklistCsvMimeType = fileType => {
  switch fileType {
  | "text/csv" | "application/vnd.ms-excel" | "" => true
  | _ => false
  }
}

let isValidBlocklistCsvFile = file =>
  file["name"]->isCsvFileName && file["type"]->isValidBlocklistCsvMimeType

let isBlocklistCsvFileSizeAllowed = file => file["size"] <= maxBlocklistCsvFileSize

let getFileName = file =>
  switch file {
  | Some(file) => file["name"]
  | None => "No file selected"
  }

let getFileSize = file =>
  switch file {
  | Some(file) => file["size"]
  | None => 0
  }

let formatFileSize = fileSize => {
  if fileSize >= bytesPerMegabyte {
    let size = fileSize->Int.toFloat /. bytesPerMegabyte->Int.toFloat
    `${size->Float.toFixedWithPrecision(~digits=1)->removeTrailingZero} MB`
  } else if fileSize >= bytesPerKilobyte {
    let size = fileSize->Int.toFloat /. bytesPerKilobyte->Int.toFloat
    `${size->Float.toFixedWithPrecision(~digits=1)->removeTrailingZero} KB`
  } else {
    `${fileSize->Int.toString} B`
  }
}
