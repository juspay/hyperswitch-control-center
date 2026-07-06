open ReconEngineTypes

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

  [
    {
      pipelineStatCardTitle: IngestionRuns,
      pipelineStatCardValue: Number(totalCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-upload-file" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: `${processingCount->Int.toString} processing now`,
      pipelineStatCardType: Info,
    },
    {
      pipelineStatCardTitle: FailedRuns,
      pipelineStatCardValue: Number(failedCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-alert-triangle-outline" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: failedCount > 0 ? "needs attention" : "all runs clean",
      pipelineStatCardType: failedCount > 0 ? Attention : Info,
    },
    {
      pipelineStatCardTitle: ProcessedRuns,
      pipelineStatCardValue: Number(ingestionProcessedCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-check-circle-outline" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: `${processedRate} of runs`,
      pipelineStatCardType: Info,
    },
    {
      pipelineStatCardTitle: NeedsManualReviewEntries,
      pipelineStatCardValue: Number(needsManualReviewCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-information-triangle" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: `${needsManualReviewCount->Int.toString} out of ${stagingTotalCount->Int.toString}`,
      pipelineStatCardType: needsManualReviewCount > 0 ? Attention : Info,
    },
  ]
}
