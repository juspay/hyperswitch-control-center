open ReconEngineTypes

type entryColType =
  | TransactionId
  | Status
  | CreatedAt

let defaultColumns: array<entryColType> = [TransactionId, Status, CreatedAt]

let allColumns: array<entryColType> = [TransactionId, Status, CreatedAt]

let getHeading = (colType: entryColType) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  }
}

let getCell = (entry: entryType, colType: entryColType): Table.cell => {
  let linkedTransactionEntry =
    entry.linked_transaction->Option.getOr(
      Dict.make()->ReconEngineUtils.linkedTransactionItemToObjMapper,
    )

  switch colType {
  | TransactionId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/v1/recon-engine/transactions/${linkedTransactionEntry.transaction_id}`}
        displayValue={linkedTransactionEntry.transaction_id}
        copyValue={Some(linkedTransactionEntry.transaction_id)}
      />,
      "",
    )
  | Status => TransactionsTableEntity.getStatusLabel(linkedTransactionEntry.transaction_status)
  | CreatedAt => Date(linkedTransactionEntry.created_at)
  }
}

let entriesEntityForLinkedTxn = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="linkedTransactionEntries",
  )
}
