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
  ->getMappedValueFromArrayOfJson(itemToObjMapper)
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

let statusLabelColor = (status): Table.labelColor => {
  switch status->getBlocklistBatchStatusFromString {
  | Initiated | Processing => LabelOrange
  | Completed => LabelGreen
  | Failed => LabelRed
  | UnknownStatus => LabelGray
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

let blocklistDataKindToString = dataKind => {
  switch dataKind {
  | CardBin => "card_bin"
  | ExtendedCardBin => "extended_card_bin"
  | Fingerprint => "fingerprint"
  }
}

let blocklistDataKindOptions: array<MultiSelectBindings.selectMenuGroupType> = [
  {
    items: [
      {label: "Card BIN", value: CardBin->blocklistDataKindToString},
      {label: "Extended Card BIN", value: ExtendedCardBin->blocklistDataKindToString},
      {label: "Fingerprint", value: Fingerprint->blocklistDataKindToString},
    ],
  },
]

let blocklistEntryItemToObjMapper = dict => {
  {
    BlocklistTypes.fingerprint_id: dict->getString("fingerprint_id", ""),
    data_kind: dict->getString("data_kind", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let blocklistEntryBody = (~dataKind, ~data) => {
  [("type", dataKind->JSON.Encode.string), ("data", data->JSON.Encode.string)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let cardBinRegex = %re("/^\d{6}$/")
let extendedCardBinRegex = %re("/^\d{8}$/")

let blocklistEntryDataHint = dataKind => {
  switch dataKind {
  | CardBin => "Must be exactly 6 digits, e.g. 411111"
  | ExtendedCardBin => "Must be exactly 8 digits, e.g. 41111100"
  | Fingerprint => "e.g. fp_abc123"
  }
}

let getBlocklistDataKindFromString = dataKind => {
  switch dataKind {
  | "card_bin" => CardBin
  | "extended_card_bin" => ExtendedCardBin
  | _ => Fingerprint
  }
}

let validateBlocklistEntryData = (~dataKind, ~data) => {
  let trimmedData = data->String.trim
  if trimmedData->isNonEmptyString->not {
    Some("Please enter a value to block.")
  } else {
    switch dataKind->getBlocklistDataKindFromString {
    | CardBin =>
      cardBinRegex->RegExp.test(trimmedData) ? None : Some("Card BIN must be exactly 6 digits.")
    | ExtendedCardBin =>
      extendedCardBinRegex->RegExp.test(trimmedData)
        ? None
        : Some("Extended Card BIN must be exactly 8 digits.")
    | Fingerprint => None
    }
  }
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
