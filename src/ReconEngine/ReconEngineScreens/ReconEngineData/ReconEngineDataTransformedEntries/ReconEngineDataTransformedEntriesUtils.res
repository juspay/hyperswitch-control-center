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
  | "transformation_history_id" => SearchTransformationHistoryId
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

let searchTypeOptionsWithTransformationHistory: array<SearchInput.searchTypeOption> = [
  SearchStagingEntryId,
  SearchOrderId,
  SearchTransformationHistoryId,
]->Array.map((entrySearchType): SearchInput.searchTypeOption => {
  {
    label: (entrySearchType :> string)->snakeToTitle,
    value: (entrySearchType :> string),
  }
})

let getSortOrder = (sortOb: LoadedTable.sortOb): processingEntrySortOrder => {
  sortOb.sortKey === "effective_at" && sortOb.sortType === LoadedTable.ASC ? Asc : Desc
}

let buildProcessingEntriesV2Body = (
  ~filterValueJson: Dict.t<JSON.t>,
  ~searchType: processingEntrySearchType,
  ~searchText: string,
  ~sortBy: cursor,
  ~direction: cursorDirection,
  ~order: processingEntrySortOrder=Desc,
  ~limit=10,
  ~transformationHistoryIds: array<string>=[],
) => {
  let statusFilter = filterValueJson->getStrArrayFromDict("status", [])
  let detailedStatuses =
    statusFilter->isEmptyArray
      ? allStagingEntryStatuses
      : statusFilter->Array.map(value =>
          getStagingEntryStatusFromValue(value, allStagingEntryStatuses)
        )

  let entryTypeFilter = filterValueJson->getStrArrayFromDict("entry_type", [])
  let accountIdFilter = filterValueJson->getStrArrayFromDict("account_ids", [])
  let transformationConfigIdFilter =
    filterValueJson->getStrArrayFromDict("transformation_config_ids", [])

  let startTime = filterValueJson->getString("startTime", "")->toReconTimeString
  let endTime = filterValueJson->getString("endTime", "")->toReconTimeString

  let filtersDict = Dict.make()
  let detailedStatusPayload = detailedStatuses->getStagingEntryStatusPayload

  filtersDict->setOptionArray("detailed_status", detailedStatusPayload->getNonEmptyArray)
  filtersDict->setOptionArray(
    "entry_type",
    entryTypeFilter->Array.map(JSON.Encode.string)->getNonEmptyArray,
  )
  filtersDict->setOptionArray(
    "account_ids",
    accountIdFilter->Array.map(JSON.Encode.string)->getNonEmptyArray,
  )
  filtersDict->setOptionArray(
    "transformation_config_ids",
    transformationConfigIdFilter->Array.map(JSON.Encode.string)->getNonEmptyArray,
  )
  filtersDict->setOptionArray(
    "transformation_history_ids",
    transformationHistoryIds->Array.map(JSON.Encode.string)->getNonEmptyArray,
  )
  filtersDict->setOptionString((searchType :> string), searchText->String.trim->getNonEmptyString)
  filtersDict->setOptionDict(
    "time_range",
    switch (startTime->getNonEmptyString, endTime->getNonEmptyString) {
    | (Some(startValue), Some(endValue)) =>
      Some(
        Dict.fromArray([
          ("start_time", startValue->JSON.Encode.string),
          ("end_time", endValue->JSON.Encode.string),
        ]),
      )
    | _ => None
    },
  )

  [
    ("filters", filtersDict->JSON.Encode.object),
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

let sumStagingOverviewStatusCount = (
  accountsOverview: array<accountStagingEntriesOverview>,
  ~matchesStatus: domainStagingEntryStatus => bool,
): float => {
  accountsOverview
  ->Array.reduce(0, (acc, account) => {
    account.status_breakdown->Array.reduce(acc, (innerAcc, statusAmount) =>
      matchesStatus(statusAmount.status) ? innerAcc + statusAmount.count : innerAcc
    )
  })
  ->Int.toFloat
}

let getTotalNeedsManualReviewEntries = (
  accountsOverview: array<accountStagingEntriesOverview>,
): float => {
  accountsOverview->sumStagingOverviewStatusCount(~matchesStatus=status =>
    switch status {
    | NeedsManualReview(_) => true
    | Pending
    | Processed
    | Void
    | Archived
    | UnknownDomainStagingEntryStatus => false
    }
  )
}

let getTotalProcessedEntries = (accountsOverview: array<accountStagingEntriesOverview>): float => {
  accountsOverview->sumStagingOverviewStatusCount(~matchesStatus=status => status == Processed)
}

let getTotalEntries = (accountsOverview: array<accountStagingEntriesOverview>): float => {
  accountsOverview->sumStagingOverviewStatusCount(~matchesStatus=status =>
    status != Archived && status != Void
  )
}

let getViewStatusFilter = (view: transformedEntriesViewType): string => {
  switch view {
  | AllViewType => allStagingEntryStatuses
  | ProcessedViewType => [Processed]
  | NeedsManualReviewViewType => allStagingEntryManualReviewStatuses
  | UnknownTransformedEntriesViewType => []
  }
  ->getStagingEntryStatusValueFromStatusList
  ->Array.joinWith(",")
}

let getViewTypeFromStatusFilter = (appliedStatuses: array<string>): transformedEntriesViewType => {
  let sorted = appliedStatuses->Array.toSorted(compareLogic)
  [AllViewType, ProcessedViewType, NeedsManualReviewViewType]
  ->Array.find(view =>
    view->getViewStatusFilter->String.split(",")->Array.toSorted(compareLogic) == sorted
  )
  ->Option.getOr(UnknownTransformedEntriesViewType)
}

let cardDetails = (~stagingOverviewData: array<accountStagingEntriesOverview>) => {
  [
    {
      title: "Total Records",
      value: valueFormatter(getTotalEntries(stagingOverviewData), Volume),
      viewType: AllViewType,
    },
    {
      title: "Processed",
      value: valueFormatter(getTotalProcessedEntries(stagingOverviewData), Volume),
      viewType: ProcessedViewType,
    },
    {
      title: "Needs Manual Review",
      value: valueFormatter(getTotalNeedsManualReviewEntries(stagingOverviewData), Volume),
      viewType: NeedsManualReviewViewType,
    },
    {
      title: "% Valid",
      value: valueFormatter(
        getTotalProcessedEntries(stagingOverviewData) /.
        getTotalEntries(stagingOverviewData) *. 100.0,
        Rate,
      ),
      viewType: UnknownTransformedEntriesViewType,
    },
  ]
}

let getLineageSections = (
  ~ingestionHistoryData: ingestionHistoryType,
  ~transformationHistoryData: transformationHistoryType,
  ~entry: processingEntryType,
) => [
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

let initialDisplayFilters = (~transformationConfigOptions, ~accountOptions) => {
  let entryTypeOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Credit", value: "credit"},
    {label: "Debit", value: "debit"},
  ]

  let statusOptions = getGroupedStagingEntryStatusOptions(allStagingEntryStatuses)

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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="Transformation",
          ~name="transformation_config_ids",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=transformationConfigOptions,
            ~buttonText="Select Transformation",
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
