open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils
open ReconEngineUtils
open LogicUtils

let defaultColumns: array<transactionColType> = [
  TransactionId,
  CreditAccount,
  DebitAccount,
  Variance,
  Status,
  CreatedAt,
]

let defaultColumnsOverview: array<transactionColType> = [
  TransactionId,
  CreditAmount,
  DebitAmount,
  Variance,
  Status,
  CreatedAt,
]

let allColumns: array<transactionColType> = [
  TransactionId,
  CreditAccount,
  DebitAccount,
  CreditAmount,
  DebitAmount,
  Variance,
  Status,
  CreatedAt,
]

let getHeading = (colType: transactionColType) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | CreditAccount => Table.makeHeaderInfo(~key="credit_account", ~title="Source Account")
  | DebitAccount => Table.makeHeaderInfo(~key="debit_account", ~title="Target Account")
  | CreditAmount => Table.makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  | DebitAmount => Table.makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | Variance => Table.makeHeaderInfo(~key="variance", ~title="Variance")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | DiscardedStatus => Table.makeHeaderInfo(~key="discarded_status", ~title="Discarded Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  }
}

let getStatusLabel = (statusString: option<string>): Table.cell => {
  switch statusString {
  | Some(status) =>
    Table.Label({
      title: status->getDisplayStatusName,
      color: switch status->ReconEngineTransactionsUtils.getTransactionTypeFromString {
      | Posted => Table.LabelGreen
      | Mismatched => Table.LabelRed
      | Expected => Table.LabelBlue
      | Archived => Table.LabelGray
      | _ => Table.LabelLightGray
      },
    })
  | None => Text("N/A")
  }
}

let getCell = (transaction: transactionPayload, colType: transactionColType): Table.cell => {
  switch colType {
  | TransactionId => EllipsisText(transaction.transaction_id, "")
  | CreditAccount => Text(getAccounts(transaction.entries, "credit"))
  | DebitAccount => Text(getAccounts(transaction.entries, "debit"))
  | CreditAmount =>
    Text(
      valueFormatter(
        transaction.credit_amount.value,
        AmountWithSuffix,
        ~suffix=transaction.credit_amount.currency,
      ),
    )
  | DebitAmount =>
    Text(
      valueFormatter(
        transaction.debit_amount.value,
        AmountWithSuffix,
        ~suffix=transaction.debit_amount.currency,
      ),
    )
  | Variance =>
    Text(
      valueFormatter(
        Math.abs(transaction.credit_amount.value -. transaction.debit_amount.value),
        AmountWithSuffix,
        ~suffix=transaction.credit_amount.currency,
      ),
    )
  | Status => getStatusLabel(Some(transaction.transaction_status))
  | DiscardedStatus => getStatusLabel(transaction.discarded_status)
  | CreatedAt => EllipsisText(transaction.created_at, "")
  }
}

let transactionsEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getTransactionsList,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="reports",
    ~getShowLink={
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.id}`),
          ~authorization,
        )
      }
    },
  )
}
