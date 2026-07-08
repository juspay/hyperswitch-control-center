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

let getStagingCounts = (stagingEntries: array<processingEntryType>) =>
  stagingEntries->Array.reduce((0, 0, 0, 0, 0), (
    (total, needsManualReview, processed, void, pending),
    entry,
  ) =>
    switch entry.status {
    | Archived | UnknownProcessingEntryStatus => (
        total,
        needsManualReview,
        processed,
        void,
        pending,
      )
    | NeedsManualReview => (total + 1, needsManualReview + 1, processed, void, pending)
    | Pending => (total + 1, needsManualReview, processed, void, pending + 1)
    | Processed => (total + 1, needsManualReview, processed + 1, void, pending)
    | Void => (total, needsManualReview, processed, void + 1, pending)
    }
  )

let getPipelineStatCards = (
  ~ingestionHistory: array<ingestionHistoryType>,
  ~stagingEntries: array<processingEntryType>,
): array<ReconEnginePipelinesTypes.pipelineStatCardData> => {
  open ReconEnginePipelinesTypes
  open ReconEngineOverviewSummaryTypes

  let (totalCount, ingestionProcessedCount, failedCount, processingCount) = getIngestionCounts(
    ingestionHistory,
  )
  let (
    stagingTotalCount,
    needsManualReviewCount,
    _stagingProcessedCount,
    _voidCount,
    _pendingCount,
  ) = getStagingCounts(stagingEntries)
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

let getTransformationErrors = (transformationHistory: array<transformationHistoryType>): array<(
  string,
  string,
)> => {
  transformationHistory
  ->Array.map(t => t.data.errors->Array.map(error => (t.transformation_name, error)))
  ->Array.flat
}

let getPipelineDetailStatCards = (
  ~transformationHistory: array<transformationHistoryType>,
  ~totalErrors: int,
  ~onErrorsClick: unit => unit,
): array<ReconEnginePipelinesTypes.pipelineDetailStatCardData> => {
  open ReconEnginePipelinesTypes

  let totalTransformed =
    transformationHistory->Array.reduce(0, (acc, t) => acc + t.data.transformed_count)
  let totalIgnored = transformationHistory->Array.reduce(0, (acc, t) => acc + t.data.ignored_count)
  let transformationRuns = transformationHistory->Array.length
  let allTxProcessed =
    transformationRuns > 0 && transformationHistory->Array.every(t => t.status == Processed)
  let txFailedCount = transformationHistory->Array.filter(t => t.status == Failed)->Array.length

  [
    {
      pipelineDetailStatCardLabel: "ROWS TRANSFORMED",
      pipelineDetailStatCardValue: totalTransformed,
      pipelineDetailStatCardDesc: "",
      pipelineDetailStatCardDescColor: "text-nd_gray-400",
      pipelineDetailStatCardOnClick: None,
    },
    {
      pipelineDetailStatCardLabel: "TRANSFORMATION RUNS",
      pipelineDetailStatCardValue: transformationRuns,
      pipelineDetailStatCardDesc: allTxProcessed
        ? "all processed"
        : txFailedCount > 0
        ? `${txFailedCount->Int.toString} failed`
        : "",
      pipelineDetailStatCardDescColor: txFailedCount > 0 ? "text-nd_red-500" : "text-nd_gray-400",
      pipelineDetailStatCardOnClick: None,
    },
    {
      pipelineDetailStatCardLabel: "ROWS IGNORED",
      pipelineDetailStatCardValue: totalIgnored,
      pipelineDetailStatCardDesc: totalIgnored > 0 ? "dropped on parse" : "",
      pipelineDetailStatCardDescColor: "text-nd_red-500",
      pipelineDetailStatCardOnClick: None,
    },
    {
      pipelineDetailStatCardLabel: "ERRORS",
      pipelineDetailStatCardValue: totalErrors,
      pipelineDetailStatCardDesc: totalErrors > 0 ? "view details" : "no errors",
      pipelineDetailStatCardDescColor: totalErrors > 0 ? "text-nd_red-500" : "text-nd_gray-400",
      pipelineDetailStatCardOnClick: totalErrors > 0 ? Some(onErrorsClick) : None,
    },
  ]
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
