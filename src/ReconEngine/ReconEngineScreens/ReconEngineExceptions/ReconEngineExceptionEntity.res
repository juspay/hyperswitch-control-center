open ReconEngineTypes
open LogicUtils

type processingColType =
  | StagingEntryId
  | TransformationHistoryId
  | EntryType
  | AccountName
  | Amount
  | Currency
  | Status
  | EffectiveAt
  | OrderId
  | Actions

let processingDefaultColumns = [
  StagingEntryId,
  TransformationHistoryId,
  EntryType,
  OrderId,
  Amount,
  Currency,
  Status,
  AccountName,
  EffectiveAt,
  Actions,
]

let getProcessingHeading = colType => {
  switch colType {
  | StagingEntryId => Table.makeHeaderInfo(~key="staging_entry_id", ~title="Transformed Entry ID")
  | TransformationHistoryId =>
    Table.makeHeaderInfo(~key="transformation_history_id", ~title="Transformation History ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | AccountName => Table.makeHeaderInfo(~key="account", ~title="Account")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~customWidth="min-w-48")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order ID")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getStatusLabel = (status: processingEntryStatus): Table.cell => {
  Label({
    title: (status :> string)->String.toUpperCase,
    color: switch status {
    | Pending => LabelBlue
    | Processed => LabelGreen
    | NeedsManualReview => LabelOrange
    | _ => LabelGray
    },
  })
}

let getProcessingCell = (data: processingEntryType, colType): Table.cell => {
  switch colType {
  | StagingEntryId =>
    CustomCell(
      <>
        <RenderIf condition={data.staging_entry_id->isNonEmptyString}>
          <HelperComponents.CopyTextCustomComp
            customParentClass="flex flex-row items-center gap-2"
            customTextCss="truncate whitespace-nowrap max-w-36"
            displayValue=Some(data.staging_entry_id)
          />
        </RenderIf>
        <RenderIf condition={data.staging_entry_id->isEmptyString}>
          <p className="text-nd_gray-600"> {"N/A"->React.string} </p>
        </RenderIf>
      </>,
      "",
    )
  | TransformationHistoryId =>
    CustomCell(
      <>
        <RenderIf condition={data.transformation_history_id->isNonEmptyString}>
          <HelperComponents.CopyTextCustomComp
            customParentClass="flex flex-row items-center gap-2"
            customTextCss="truncate whitespace-nowrap max-w-36"
            displayValue=Some(data.transformation_history_id)
          />
        </RenderIf>
        <RenderIf condition={data.transformation_history_id->isEmptyString}>
          <p className="text-nd_gray-600"> {"N/A"->React.string} </p>
        </RenderIf>
      </>,
      "",
    )
  | EntryType => Text(data.entry_type->LogicUtils.capitalizeString)
  | AccountName => EllipsisText(data.account.account_name, "")
  | Amount => Numeric(data.amount, amount => {amount->Float.toString})
  | Currency => Text(data.currency)
  | Status => getStatusLabel(data.status)
  | EffectiveAt => Date(data.effective_at)
  | OrderId =>
    CustomCell(
      <>
        <RenderIf condition={data.order_id->isNonEmptyString}>
          <HelperComponents.CopyTextCustomComp
            customParentClass="flex flex-row items-center gap-2"
            customTextCss="truncate whitespace-nowrap max-w-fit"
            displayValue=Some(data.order_id)
          />
        </RenderIf>
        <RenderIf condition={data.order_id->isEmptyString}>
          <p className="text-nd_gray-600"> {"N/A"->React.string} </p>
        </RenderIf>
      </>,
      "",
    )
  | Actions => CustomCell(<ReconEngineAccountsTransformedEntriesActions processingEntry=data />, "")
  }
}

let processingTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns=processingDefaultColumns,
  ~getHeading=getProcessingHeading,
  ~getCell=getProcessingCell,
  ~dataKey="",
)
