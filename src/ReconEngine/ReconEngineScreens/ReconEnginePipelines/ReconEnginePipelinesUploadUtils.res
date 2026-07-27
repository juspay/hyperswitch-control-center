open LogicUtils
open ReconEnginePipelinesTypes

let supportedFileTypes: array<supportedFileExtensions> = [Csv, Ext, Xlsx, Txt]

let bytesPerKilobyte = 1000
let bytesPerMegabyte = bytesPerKilobyte * 1000
let maxFileSizeBytes = 8 * bytesPerMegabyte
let maxFilesCount = 3

let isSupportedFileType = (fileName: string): bool => {
  let lowerFileName = fileName->String.toLowerCase
  supportedFileTypes
  ->Array.map(ft => `.${(ft :> string)->String.toLowerCase}`)
  ->Array.find(ext => lowerFileName->String.endsWith(ext)) != None
}

let fileListToArray = fileList => {
  Array.fromInitializer(~length=fileList->Array.length, i => fileList[i])->Array.filterMap(x => x)
}

let classifyFile = (file, ~existingCount, ~seenKeys) => {
  let fileName = file["name"]
  if !isSupportedFileType(fileName->String.toLowerCase) {
    Error(`${fileName}: unsupported file type`)
  } else if file["size"] > maxFileSizeBytes {
    Error(`${fileName}: exceeds 8 MB`)
  } else if seenKeys->Array.includes(fileName) {
    Error(`${fileName}: already selected`)
  } else if existingCount >= maxFilesCount {
    Error(`${fileName}: only ${maxFilesCount->Int.toString} files allowed`)
  } else {
    Ok(fileName)
  }
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
