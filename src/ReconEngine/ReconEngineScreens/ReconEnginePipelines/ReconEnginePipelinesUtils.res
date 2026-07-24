open ReconEngineTypes
open LogicUtils

let getIngestionCounts = (ingestionHistory: array<ingestionHistoryType>) =>
  ingestionHistory->Array.reduce((0, 0, 0, 0), ((total, processed, failed, processing), item) =>
    switch item.status {
    | Discarded | UnknownIngestionTransformationStatus => (total, processed, failed, processing)
    | Processed => (total + 1, processed + 1, failed, processing)
    | Failed => (total + 1, processed, failed + 1, processing)
    | Processing => (total + 1, processed, failed, processing + 1)
    | Pending => (total + 1, processed, failed, processing)
    }
  )

let getStagingOverviewCounts = (stagingOverviewData: array<accountStagingEntriesOverview>) =>
  stagingOverviewData->Array.reduce((0, 0), ((total, needsManualReview), account) =>
    account.status_breakdown->Array.reduce((total, needsManualReview), (
      (total, needsManualReview),
      statusAmount,
    ) =>
      switch statusAmount.status {
      | Archived | Void | UnknownProcessingEntryStatus => (total, needsManualReview)
      | NeedsManualReview => (total + statusAmount.count, needsManualReview + statusAmount.count)
      | Pending | Processed => (total + statusAmount.count, needsManualReview)
      }
    )
  )

let getPipelineStatCards = (
  ~ingestionHistory: array<ingestionHistoryType>,
  ~stagingOverviewData: array<accountStagingEntriesOverview>,
): array<ReconEnginePipelinesTypes.pipelineStatCardData> => {
  open ReconEnginePipelinesTypes
  open ReconEngineOverviewSummaryTypes

  let (totalCount, ingestionProcessedCount, failedCount, processingCount) = getIngestionCounts(
    ingestionHistory,
  )
  let (stagingTotalCount, needsManualReviewCount) = getStagingOverviewCounts(stagingOverviewData)

  let processedRate =
    ReconEngineOverviewUtils.getPercentage(
      ~count=ingestionProcessedCount,
      ~total=totalCount,
    )->CurrencyFormatUtils.valueFormatter(Rate)
  let needsManualReviewRate =
    ReconEngineOverviewUtils.getPercentage(
      ~count=needsManualReviewCount,
      ~total=stagingTotalCount,
    )->CurrencyFormatUtils.valueFormatter(Rate)

  let processedStatusValue =
    ReconEngineFilterUtils.getIngestionTransformationHistoryStatusValueFromStatusList([
      Processed,
    ])->Array.joinWith(",")
  let failedStatusValue =
    ReconEngineFilterUtils.getIngestionTransformationHistoryStatusValueFromStatusList([
      Failed,
    ])->Array.joinWith(",")

  [
    {
      pipelineStatCardTitle: IngestionRuns,
      pipelineStatCardValue: Number(totalCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-upload-file" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: `${processingCount->Int.toString} processing now`,
      pipelineStatCardType: Info,
      pipelineStatCardClickAction: ClearStatusFilter,
    },
    {
      pipelineStatCardTitle: FailedRuns,
      pipelineStatCardValue: Number(failedCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-alert-triangle-outline" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: failedCount > 0 ? "needs attention" : "all runs clean",
      pipelineStatCardType: failedCount > 0 ? Attention : Info,
      pipelineStatCardClickAction: SetStatusFilter(failedStatusValue),
    },
    {
      pipelineStatCardTitle: ProcessedRuns,
      pipelineStatCardValue: Number(ingestionProcessedCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-check-circle-outline" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: `${processedRate} of runs`,
      pipelineStatCardType: Info,
      pipelineStatCardClickAction: SetStatusFilter(processedStatusValue),
    },
    {
      pipelineStatCardTitle: NeedsManualReviewEntries,
      pipelineStatCardValue: Number(needsManualReviewCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-information-triangle" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: `${needsManualReviewRate} of staging entries`,
      pipelineStatCardType: needsManualReviewCount > 0 ? Attention : Info,
      pipelineStatCardClickAction: NoAction,
    },
  ]
}

let ingestionHistorySortOptions: array<ReconEnginePipelinesTypes.ingestionHistorySortOption> = [
  #MostRecent,
  #NeedsAttention,
  #FileName,
]

let ingestionStatusAttentionRank = status =>
  switch status {
  | Failed => 0
  | Processing => 1
  | Pending => 2
  | Processed => 3
  | Discarded | UnknownIngestionTransformationStatus => 4
  }

let sortIngestionHistory = (
  data: array<Nullable.t<ingestionHistoryType>>,
  sortOption: ReconEnginePipelinesTypes.ingestionHistorySortOption,
) => {
  data->Array.toSorted((a, b) => {
    switch (a->getOptionalFromNullable, b->getOptionalFromNullable) {
    | (Some(a), Some(b)) =>
      switch sortOption {
      | #MostRecent => compareLogic(a.created_at, b.created_at)
      | #NeedsAttention =>
        numericArraySortComparator(
          ingestionStatusAttentionRank(a.status),
          ingestionStatusAttentionRank(b.status),
        )
      | #FileName =>
        numericArraySortComparator(a.file_name->String.toLowerCase, b.file_name->String.toLowerCase)
      }
    | (Some(_), None) => -1.
    | (None, Some(_)) => 1.
    | (None, None) => 0.
    }
  })
}

let getAccountOptions = (accounts: array<accountType>): array<FilterSelectBox.dropdownOption> => {
  accounts->Array.map(account => {
    FilterSelectBox.label: account.account_name,
    value: account.account_id,
  })
}

let getConnectorOptions = (ingestionHistory: array<ingestionHistoryType>): array<
  FilterSelectBox.dropdownOption,
> => {
  ingestionHistory
  ->Array.map(item => item.upload_type)
  ->Array.filter(isNonEmptyString)
  ->getUniqueArray
  ->Array.map(uploadType => {
    FilterSelectBox.label: uploadType->capitalizeString,
    value: uploadType,
  })
}

let initialPipelinesTableFilters = (
  ~accountOptions: array<FilterSelectBox.dropdownOption>,
  ~connectorOptions: array<FilterSelectBox.dropdownOption>,
) => {
  let statusOptions = ReconEngineDataSourcesUtils.getStatusOptions([
    Pending,
    Processing,
    Processed,
    Failed,
  ])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="account",
          ~name="account_id",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=accountOptions,
            ~buttonText="Select Account",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="upload_type",
          ~name="upload_type",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=connectorOptions,
            ~buttonText="Select Connector",
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
