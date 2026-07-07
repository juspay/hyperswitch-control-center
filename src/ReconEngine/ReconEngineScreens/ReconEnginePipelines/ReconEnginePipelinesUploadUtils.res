open LogicUtils

type supportedFileExtensions =
  | Csv
  | Ext
  | Xlsx
  | Txt

let supportedFileTypes: array<supportedFileExtensions> = [Csv, Ext, Xlsx, Txt]

let bytesPerKilobyte = 1000
let bytesPerMegabyte = bytesPerKilobyte * 1000
let maxFileSizeBytes = 8 * bytesPerMegabyte

let isSupportedFileType = (fileName: string): bool => {
  let lowerFileName = fileName->String.toLowerCase
  supportedFileTypes
  ->Array.map(ft => `.${(ft :> string)->String.toLowerCase}`)
  ->Array.find(ext => lowerFileName->String.endsWith(ext)) != None
}

let formatFileSize = (sizeInBytes: int) => {
  let size = sizeInBytes->Int.toFloat
  let (displaySize, unit) = if sizeInBytes >= bytesPerMegabyte {
    (size /. bytesPerMegabyte->Int.toFloat, "MB")
  } else {
    (size /. bytesPerKilobyte->Int.toFloat, "KB")
  }
  let formattedSize = displaySize->Float.toFixedWithPrecision(~digits=2)->removeTrailingZero

  `${formattedSize} ${unit}`
}

let isManualIngestionConfig = (config: ReconEngineTypes.ingestionConfigType): bool => {
  config.data->getDictFromJsonObject->getString("ingestion_type", "") == "manual"
}

let getAccountDropdownOptions = (accounts: array<ReconEngineTypes.accountType>): array<
  SelectBox.dropdownOption,
> => {
  accounts->Array.map(account => {
    SelectBox.label: account.account_name,
    value: account.account_id,
  })
}

let getIngestionConfigDropdownOptions = (
  configs: array<ReconEngineTypes.ingestionConfigType>,
): array<SelectBox.dropdownOption> => {
  configs
  ->Array.filter(isManualIngestionConfig)
  ->Array.map(config => {
    SelectBox.label: config.name,
    value: config.ingestion_id,
  })
}
