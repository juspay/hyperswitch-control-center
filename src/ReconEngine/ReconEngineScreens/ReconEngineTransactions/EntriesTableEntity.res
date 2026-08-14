open ReconEngineTypes
open LogicUtils

type entryColType =
  | EntryId
  | EntryType
  | AccountName
  | TransactionId
  | Amount
  | Currency
  | Status
  | Transformation
  | Metadata
  | CreatedAt
  | EffectiveAt
  | OrderID
  | Actions

let defaultColumns: array<entryColType> = [
  EntryId,
  EntryType,
  TransactionId,
  Amount,
  Currency,
  Status,
  Metadata,
  CreatedAt,
  EffectiveAt,
  OrderID,
]

let allColumns: array<entryColType> = [
  EntryId,
  EntryType,
  TransactionId,
  Amount,
  Currency,
  Status,
  Metadata,
  CreatedAt,
  EffectiveAt,
  OrderID,
]

let detailsFields = [
  OrderID,
  EntryType,
  Amount,
  Currency,
  Status,
  AccountName,
  EntryId,
  TransactionId,
  CreatedAt,
  EffectiveAt,
]

let transactionEntriesDetailFields = [
  EntryType,
  Amount,
  Currency,
  Status,
  Transformation,
  EntryId,
  OrderID,
  EffectiveAt,
  CreatedAt,
  Actions,
]

let getHeading = (colType: entryColType) => {
  switch colType {
  | EntryId => Table.makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | EntryType => Table.makeHeaderInfo(~key="entry_type", ~title="Entry Type")
  | AccountName => Table.makeHeaderInfo(~key="account", ~title="Account")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Transformation => Table.makeHeaderInfo(~key="transformation", ~title="Transformation")
  | Metadata => Table.makeHeaderInfo(~key="metadata", ~title="Metadata")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | EffectiveAt => Table.makeHeaderInfo(~key="effective_at", ~title="Effective At")
  | OrderID => Table.makeHeaderInfo(~key="order_id", ~title="Order ID")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getStatusLabel = (entryStatus: entryStatus): Table.cell => {
  Table.Label({
    title: (entryStatus :> string)->String.toUpperCase,
    color: switch entryStatus {
    | Posted
    | Matched =>
      LabelGreen
    | Mismatched => LabelRed
    | Expected => LabelBlue
    | Archived => LabelGray
    | Pending => LabelOrange
    | Void | UnknownEntryStatus => LabelLightGray
    },
  })
}

let getCell = (entry: entryType, colType: entryColType): Table.cell => {
  switch colType {
  | EntryId => Text(entry.entry_id)
  | EntryType => Text((entry.entry_type :> string)->LogicUtils.capitalizeString)
  | AccountName => EllipsisText(entry.account_name, "")
  | TransactionId => DisplayCopyCell(entry.transaction_id)
  | Amount => Text(Float.toString(entry.amount))
  | Currency => Text(entry.currency)
  | Status =>
    switch entry.discarded_status {
    | Some(discardedStatus) =>
      getStatusLabel(discardedStatus->ReconEngineUtils.getEntryStatusVariantFromString)
    | None => getStatusLabel(entry.status)
    }
  | Transformation =>
    CustomCell(
      switch entry.transformation_name {
      | Some(name) =>
        <p
          className="w-fit max-w-40 truncate whitespace-nowrap px-2 py-0.5 rounded-full bg-nd_gray-100 text-nd_gray-700 border border-nd_gray-200"
          title=name>
          {name->React.string}
        </p>
      | None => <p className="text-nd_gray-600"> {"N/A"->React.string} </p>
      },
      "",
    )
  | Metadata => Text(entry.metadata->JSON.stringify)
  | CreatedAt => Date(entry.created_at)
  | EffectiveAt =>
    entry.effective_at->isNonEmptyString
      ? CustomCell(
          <TableUtils.DateCell
            timestamp=entry.effective_at textAlign=Left hideTimeZone=true convertToLocal=false
          />,
          entry.effective_at,
        )
      : Text("-")
  | OrderID =>
    CustomCell(
      <>
        <RenderIf condition={entry.order_id->isNonEmptyString}>
          <HelperComponents.CopyTextCustomComp
            customTextCss="max-w-36 truncate whitespace-nowrap" displayValue=Some(entry.order_id)
          />
        </RenderIf>
        <RenderIf condition={entry.order_id->isEmptyString}>
          <p className="text-nd_gray-600"> {"N/A"->React.string} </p>
        </RenderIf>
      </>,
      "",
    )
  | Actions => CustomCell(<ReconEngineTransactionEntriesActions entry />, "")
  }
}

let entriesEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="entries",
    ~getShowLink={
      connectorObj => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connectorObj.entry_id}`),
          ~authorization,
        )
      }
    },
  )
}
