open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils

let defaultColumns: array<transactionColType> = [
  Id,
  TransactionId,
  CreditAccount,
  DebitAccount,
  Variance,
  Status,
  CreatedAt,
]
let allColumns: array<transactionColType> = [
  Id,
  TransactionId,
  CreditAccount,
  DebitAccount,
  Variance,
  Status,
  CreatedAt,
]

let getHeading = (colType: transactionColType) => {
  switch colType {
  | Id => Table.makeHeaderInfo(~key="id", ~title="ID")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | CreditAccount => Table.makeHeaderInfo(~key="credit_account", ~title="Credit Account")
  | DebitAccount => Table.makeHeaderInfo(~key="debit_account", ~title="Debit Account")
  | Variance => Table.makeHeaderInfo(~key="variance", ~title="Variance")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  }
}

let getCell = (transaction: transactionPayload, colType: transactionColType): Table.cell => {
  switch colType {
  | Id => Text(transaction.id)
  | TransactionId => EllipsisText(transaction.transaction_id, "")
  | CreditAccount => Text(getAccounts(transaction.entries, "credit"))
  | DebitAccount => Text(getAccounts(transaction.entries, "debit"))
  | Variance =>
    Text(Float.toString(transaction.credit_amount.value -. transaction.debit_amount.value))
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
