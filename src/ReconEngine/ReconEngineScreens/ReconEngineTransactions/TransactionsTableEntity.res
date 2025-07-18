open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils

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
  | CreditAccount => Table.makeHeaderInfo(~key="credit_account", ~title="Credit Account")
  | DebitAccount => Table.makeHeaderInfo(~key="debit_account", ~title="Debit Account")
  | CreditAmount => Table.makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  | DebitAmount => Table.makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | Variance => Table.makeHeaderInfo(~key="variance", ~title="Variance")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  }
}

let getCell = (transaction: transactionPayload, colType: transactionColType): Table.cell => {
  switch colType {
  | TransactionId => EllipsisText(transaction.transaction_id, "")
  | CreditAccount => Text(getAccounts(transaction.entries, "credit"))
  | DebitAccount => Text(getAccounts(transaction.entries, "debit"))
  | CreditAmount =>
    Text(
      transaction.credit_amount.value->formatAmountToString(
        ~currency=transaction.credit_amount.currency,
      ),
    )
  | DebitAmount =>
    Text(
      transaction.debit_amount.value->formatAmountToString(
        ~currency=transaction.debit_amount.currency,
      ),
    )
  | Variance =>
    Text(
      formatAmountToString(
        transaction.credit_amount.value -. transaction.debit_amount.value,
        ~currency=transaction.credit_amount.currency,
      ),
    )
  | Status =>
    Label({
      title: {transaction.transaction_status->String.toUpperCase},
      color: switch transaction.transaction_status->String.toLowerCase {
      | "posted" => LabelGreen
      | "mismatched" => LabelRed
      | "expected" => LabelBlue
      | "archived" => LabelGray
      | _ => LabelGray
      },
    })
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
