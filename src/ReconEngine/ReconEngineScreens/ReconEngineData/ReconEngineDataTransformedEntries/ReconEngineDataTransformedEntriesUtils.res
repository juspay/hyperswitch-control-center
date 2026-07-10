open LogicUtils
open ReconEngineFilterUtils
open ReconEngineDataTransformedEntriesTypes
open ReconEngineUtils
open ReconEngineTypes
open CurrencyFormatUtils

let searchTypeFromString = str => {
  switch str {
  | "order_id" => SearchOrderId
  | "staging_entry_id" => SearchStagingEntryId
  | _ => UnknownProcessingEntrySearchType
  }
}

let searchTypeOptions: array<SearchInput.searchTypeOption> = [
  SearchStagingEntryId,
  SearchOrderId,
]->Array.map((entrySearchType): SearchInput.searchTypeOption => {
  {
    label: (entrySearchType :> string)->snakeToTitle,
    value: (entrySearchType :> string),
  }
})

let getSortOrder = (sortOb: LoadedTable.sortOb): processingEntrySortOrder => {
  sortOb.sortKey === "date" && sortOb.sortType === LoadedTable.ASC ? Asc : Desc
}

let processingEntryCursorFromDict = dict => {
  let cursorValueDict = dict->getDictfromDict("cursor_value")

  (
    {
      sortField: dict->getString("sort_field", "effective_at"),
      cursorValue: Some(
        (
          {
            effectiveAt: cursorValueDict->getString("effective_at", ""),
            cursorId: cursorValueDict->getString("id", ""),
          }: processingEntryCursorValue
        ),
      ),
    }: processingEntryCursor
  )
}

let defaultProcessingEntrySortBy: processingEntryCursor = {
  sortField: "effective_at",
  cursorValue: None,
}

let buildProcessingEntriesV2Body = (
  ~filterValueJson: Dict.t<JSON.t>,
  ~searchType: processingEntrySearchType,
  ~searchText: string,
  ~sortBy: processingEntryCursor,
  ~direction: processingEntryCursorDirection,
  ~order: processingEntrySortOrder=Desc,
  ~limit=10,
) => {
  let statusFilter = filterValueJson->getArrayFromDict("status", [])
  let statusValues =
    statusFilter->isEmptyArray
      ? getProcessingEntryStatusValueFromStatusList([Pending, Processed, NeedsManualReview, Void])
      : statusFilter->Array.map(v => v->getStringFromJson(""))

  let entryTypeFilter =
    filterValueJson->getArrayFromDict("entry_type", [])->Array.map(v => v->getStringFromJson(""))
  let accountIdFilter =
    filterValueJson
    ->getArrayFromDict("account_ids", [])
    ->Array.map(v => v->getStringFromJson(""))

  let startTime = filterValueJson->getString("startTime", "")
  let endTime = filterValueJson->getString("endTime", "")
  let hasTimeRange = startTime->isNonEmptyString && endTime->isNonEmptyString

  let filters =
    [
      Some(("status", statusValues->getJsonFromArrayOfString)),
      entryTypeFilter->isNonEmptyArray
        ? Some(("entry_type", entryTypeFilter->getJsonFromArrayOfString))
        : None,
      accountIdFilter->isNonEmptyArray
        ? Some(("account_ids", accountIdFilter->getJsonFromArrayOfString))
        : None,
      hasTimeRange
        ? Some((
            "time_range",
            [
              ("start_time", startTime->JSON.Encode.string),
              ("end_time", endTime->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          ))
        : None,
      searchText->isNonEmptyString
        ? Some(((searchType :> string), searchText->String.trim->JSON.Encode.string))
        : None,
    ]
    ->Array.filterMap(entry => entry)
    ->getJsonFromArrayOfJson

  [
    ("filters", filters),
    (
      "cursor_payload",
      {
        limit,
        direction,
        order,
        sortBy,
      }->Identity.genericTypeToJson,
    ),
  ]->getJsonFromArrayOfJson
}

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
          ~name="account_ids",
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
