open ReconEngineFilterUtils
open ReconEngineAccountsTransformedEntriesTypes
open ReconEngineUtils
open ReconEngineTypes
open CurrencyFormatUtils

let getTransformedEntriesTransformationHistoryPayloadFromDict = dict => {
  dict->transformationHistoryItemToObjMapper
}

let getTransformedEntriesIngestionHistoryPayloadFromDict = dict => {
  dict->ingestionHistoryItemToObjMapper
}

let getProcessingEntryPayloadFromDict = dict => {
  dict->processingItemToObjMapper
}

let getTotalNeedsManualReviewEntries = (stagingEntries: array<processingEntryType>): float => {
  stagingEntries
  ->Array.filter(entry => entry.status == NeedsManualReview)
  ->Array.length
  ->Int.toFloat
}

let getTotalProcessedEntries = (stagingEntries: array<processingEntryType>): float => {
  stagingEntries
  ->Array.filter(entry => entry.status == Processed)
  ->Array.length
  ->Int.toFloat
}

let getTotalEntries = (stagingEntries: array<processingEntryType>): float => {
  stagingEntries
  ->Array.filter(entry => entry.status != Archived && entry.status != Void)
  ->Array.length
  ->Int.toFloat
}

let getViewStatusFilter = (view: transformedEntriesViewType): string => {
  switch view {
  | AllViewType => "pending,processed,needs_manual_review,void"
  | ProcessedViewType => "processed"
  | NeedsManualReviewViewType => "needs_manual_review"
  | UnknownTransformedEntriesViewType => ""
  }
}

let getViewTypeFromStatus = (status: string): transformedEntriesViewType => {
  switch status {
  | "processed" => ProcessedViewType
  | "needs_manual_review" => NeedsManualReviewViewType
  | "pending,processed,needs_manual_review,void" => AllViewType
  | _ => UnknownTransformedEntriesViewType
  }
}

let cardDetails = (~stagingData: array<processingEntryType>) => {
  [
    {
      title: "Total Records",
      value: valueFormatter(getTotalEntries(stagingData), Volume),
      viewType: AllViewType,
    },
    {
      title: "Processed",
      value: valueFormatter(getTotalProcessedEntries(stagingData), Volume),
      viewType: ProcessedViewType,
    },
    {
      title: "Needs Manual Review",
      value: valueFormatter(getTotalNeedsManualReviewEntries(stagingData), Volume),
      viewType: NeedsManualReviewViewType,
    },
    {
      title: "% Valid",
      value: valueFormatter(
        getTotalProcessedEntries(stagingData) /. getTotalEntries(stagingData) *. 100.0,
        Rate,
      ),
      viewType: UnknownTransformedEntriesViewType,
    },
  ]
}

let getLineageSections = (~ingestionHistoryData, ~transformationHistoryData, ~entry) => [
  {
    lineageSectionTitle: "Source",
    lineageSectionFields: [
      {
        lineageFieldLabel: "File Name",
        lineageFieldValue: ingestionHistoryData.file_name,
        lineageFileCopyable: false,
      },
      {
        lineageFieldLabel: "Ingestion Id",
        lineageFieldValue: ingestionHistoryData.ingestion_id,
        lineageFileCopyable: true,
      },
    ],
  },
  {
    lineageSectionTitle: "Transformation",
    lineageSectionFields: [
      {
        lineageFieldLabel: "Transformation Name",
        lineageFieldValue: transformationHistoryData.transformation_name,
        lineageFileCopyable: false,
      },
      {
        lineageFieldLabel: "Transformation ID",
        lineageFieldValue: transformationHistoryData.transformation_id,
        lineageFileCopyable: true,
      },
    ],
  },
  {
    lineageSectionTitle: "Transformed Entry",
    lineageSectionFields: [
      {
        lineageFieldLabel: "Transformed Entry Id",
        lineageFieldValue: entry.staging_entry_id,
        lineageFileCopyable: true,
      },
    ],
  },
]

let initialDisplayFilters = (~accountOptions) => {
  let entryTypeOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Credit", value: "credit"},
    {label: "Debit", value: "debit"},
  ]

  let statusOptions = getStagingEntryStatusOptions([Processed, Pending, NeedsManualReview, Void])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="entry_type",
          ~name="entry_type",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=entryTypeOptions,
            ~buttonText="Select Entry Type",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
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
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="Account",
          ~name="account_id",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=accountOptions,
            ~buttonText="Select Account",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
