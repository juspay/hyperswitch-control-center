open BlocklistTypes
open LogicUtils

let sampleCsv = `type,data,metadata
card_bin,411111,source=fraud_team;reason=chargeback
extended_card_bin,41111100,
fingerprint,fp_abc123,`

let maxBlocklistCsvFileSize = 5 * 1024 * 1024
let maxBlocklistCsvDataRows = 100000
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

let blocklistDataKindToLabel = dataKind => {
  switch dataKind {
  | CardBin => "Card BIN"
  | ExtendedCardBin => "Extended Card BIN"
  | Fingerprint => "Fingerprint"
  }
}

let allBlocklistDataKinds = [CardBin, ExtendedCardBin, Fingerprint]

let blocklistDataKindOptions: array<SelectBox.dropdownOption> = allBlocklistDataKinds->Array.map((
  dataKind
): SelectBox.dropdownOption => {
  label: dataKind->blocklistDataKindToLabel,
  value: dataKind->blocklistDataKindToString,
})

let blocklistEntryItemToObjMapper = dict => {
  {
    BlocklistTypes.fingerprint_id: dict->getString("fingerprint_id", ""),
    data_kind: dict->getString("data_kind", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let blocklistEntryBody = (~dataKind, ~data) => {
  [
    ("type", dataKind->blocklistDataKindToString->JSON.Encode.string),
    ("data", data->JSON.Encode.string),
  ]->getJsonFromArrayOfJson
}

let cardBinRegex = %re("/^\d{6}$/")
let extendedCardBinRegex = %re("/^\d{8}$/")
let digitOnlyRegex = %re("/^\d*$/")

let isDigitOnlyBlocklistDataKind = dataKind => {
  switch dataKind {
  | CardBin | ExtendedCardBin => true
  | Fingerprint => false
  }
}

let isValidBlocklistEntryInput = (~dataKind, ~data) => {
  dataKind->isDigitOnlyBlocklistDataKind ? digitOnlyRegex->RegExp.test(data) : true
}

let blocklistEntryDataHint = dataKind => {
  switch dataKind {
  | CardBin => "Must be exactly 6 digits, e.g. 411111"
  | ExtendedCardBin => "Must be exactly 8 digits, e.g. 41111100"
  | Fingerprint => "e.g. fp_abc123"
  }
}

let blocklistEntryPlaceholder = dataKind => {
  switch dataKind {
  | CardBin => "411111"
  | ExtendedCardBin => "41111100"
  | Fingerprint => "fp_abc123"
  }
}

let blocklistEntryInputMode = dataKind => {
  switch dataKind {
  | CardBin | ExtendedCardBin => "numeric"
  | Fingerprint => "text"
  }
}

let blocklistEntryMaxLength = dataKind => {
  switch dataKind {
  | CardBin => Some(6)
  | ExtendedCardBin => Some(8)
  | Fingerprint => None
  }
}

let getBlocklistDataKindFromString = dataKind => {
  switch dataKind {
  | "card_bin" => Some(CardBin)
  | "extended_card_bin" => Some(ExtendedCardBin)
  | "fingerprint" => Some(Fingerprint)
  | _ => None
  }
}
let validateBlocklistEntryData = (~dataKind, ~data, ~operation) => {
  let trimmedData = data->String.trim
  if trimmedData->isEmptyString {
    switch operation {
    | AddBlocklistEntry => Some("Please enter a value to block.")
    | DeleteBlocklistEntry => Some("Please enter a value to unblock.")
    }
  } else {
    switch dataKind {
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

let getBlocklistEntryMethod = operation => {
  switch operation {
  | AddBlocklistEntry => Fetch.Post
  | DeleteBlocklistEntry => Fetch.Delete
  }
}

let getBlocklistEntryFallbackError = operation => {
  switch operation {
  | AddBlocklistEntry => "Failed to add entry to blocklist"
  | DeleteBlocklistEntry => "Failed to remove entry from blocklist"
  }
}

let parseBlocklistErrorMessage = rawErrorMessage => {
  let errorDict = rawErrorMessage->safeParse->getDictFromJsonObject
  errorDict
  ->getObj("error", errorDict)
  ->getString("message", rawErrorMessage)
}

let getBlocklistEntrySuccessMessage = (~operation, ~submittedData, ~fingerprintId) => {
  let displayValue = fingerprintId->getNonEmptyString->Option.getOr(submittedData)
  switch operation {
  | AddBlocklistEntry => `Added ${displayValue} to blocklist.`
  | DeleteBlocklistEntry => `Removed ${displayValue} from blocklist.`
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

let maxBlocklistCsvDataRowsLabel =
  maxBlocklistCsvDataRows->DateTimeUtils.toLocaleStringWithLocale("en-US")
let maxBlocklistCsvFileSizeLabel = maxBlocklistCsvFileSize->formatFileSize

let getBlocklistCsvFileError = file =>
  if !(file->isValidBlocklistCsvFile) {
    Some("Please upload a valid CSV file.")
  } else if !(file->isBlocklistCsvFileSizeAllowed) {
    Some(`CSV files larger than ${maxBlocklistCsvFileSizeLabel} cannot be processed.`)
  } else {
    None
  }

let getBlocklistCsvDataRowCount = fileContents => {
  let parsedCsv = PapaParse.parse(fileContents, {"skipEmptyLines": true})
  parsedCsv.data->Array.length - 1
}

let getBlocklistCsvDataRowCountError = fileContents => {
  let dataRowCount = fileContents->getBlocklistCsvDataRowCount
  if dataRowCount < 1 {
    Some("CSV file must contain at least one data row.")
  } else if dataRowCount > maxBlocklistCsvDataRows {
    Some(`CSV files with more than ${maxBlocklistCsvDataRowsLabel} rows cannot be processed.`)
  } else {
    None
  }
}
