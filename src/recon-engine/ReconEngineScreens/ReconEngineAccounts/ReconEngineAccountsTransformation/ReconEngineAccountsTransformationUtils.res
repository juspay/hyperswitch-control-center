open ReconEngineAccountsTransformationTypes
open LogicUtils
open ReconEngineTypes
open ReconEngineUtils

let getTransformationConfigPayloadFromDict = dict => {
  dict->transformationConfigItemToObjMapper
}

let getTransformationHistoryPayloadFromDict = dict => {
  dict->transformationHistoryItemToObjMapper
}

let getTotalCount = (~transformationHistoryList: array<transformationHistoryType>): int => {
  transformationHistoryList->Array.length
}

let getProcessedCount = (~transformationHistoryList: array<transformationHistoryType>): int => {
  transformationHistoryList
  ->Array.filter(item => item.status == Processed)
  ->Array.length
}

let getTransformationIdFromUrl = urlSearch => {
  urlSearch
  ->getDictFromUrlSearchParams
  ->getvalFromDict("transformationId")
}

let createFormInput = (~name, ~value): ReactFinalForm.fieldRenderPropsInput => {
  name,
  onBlur: _ => (),
  onChange: _ => (),
  onFocus: _ => (),
  value: value->JSON.Encode.string,
  checked: true,
}

let createDropdownOption = (~label, ~value) => {
  SelectBox.label,
  value,
}

let getHealthyStatus = (~transformationHistoryList: array<transformationHistoryType>): (
  string,
  string,
  TableUtils.labelColor,
) => {
  let total = getTotalCount(~transformationHistoryList)->Int.toFloat
  let processed = getProcessedCount(~transformationHistoryList)->Int.toFloat
  let percentage = total > 0.0 ? valueFormatter(processed *. 100.0 /. total, Rate) : "0%"

  if percentage->Float.fromString >= Some(90.0) || total == 0.0 {
    (percentage, "Healthy", TableUtils.LabelGreen)
  } else {
    (percentage, "Unhealthy", TableUtils.LabelRed)
  }
}

let getTransformationConfigData = (~config: transformationConfigType): array<
  transformationConfigDataType,
> => {
  let sourceConfigData: array<transformationConfigDataType> = [
    {
      label: TransformationId,
      value: config.id,
      valueType: #text,
    },
    {
      label: IngestionId,
      value: config.ingestion_id,
      valueType: #text,
    },
    {
      label: LastTransformedAt,
      value: config.last_transformed_at,
      valueType: #date,
    },
    {
      label: Status,
      value: config.is_active ? "Active" : "Inactive",
      valueType: #status,
    },
  ]

  sourceConfigData
}

let getStatusOptions = (statusList: array<ingestionTransformationStatusType>): array<
  FilterSelectBox.dropdownOption,
> => {
  statusList->Array.map(status => {
    let value: string = (status :> string)->String.toLowerCase
    let label = (status :> string)->capitalizeString
    {
      FilterSelectBox.label,
      value,
    }
  })
}

let initialIngestionDisplayFilters = () => {
  let statusOptions = getStatusOptions([Pending, Processing, Processed, Failed])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
