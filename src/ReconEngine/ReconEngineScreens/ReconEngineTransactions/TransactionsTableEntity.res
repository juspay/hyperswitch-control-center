open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils

let defaultColumns: array<transactionColType> = [
  TransactionId,
  CreditAccount,
  DebitAccount,
  Amount,
  Currency,
  Variance,
  Status,
  CreatedAt,
]
let allColumns: array<transactionColType> = [
  TransactionId,
  CreditAccount,
  DebitAccount,
  Amount,
  Currency,
  Variance,
  Status,
  CreatedAt,
]

type reconStatus =
  | Reconciled
  | Unreconciled
  | Missing
  | None

let getHeading = (colType: transactionColType) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | CreditAccount => Table.makeHeaderInfo(~key="credit_account", ~title="Credit Account")
  | DebitAccount => Table.makeHeaderInfo(~key="debit_account", ~title="Debit Account")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Variance => Table.makeHeaderInfo(~key="variance", ~title="Variance")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  }
}

let getCell = (transaction: transactionPayload, colType: transactionColType): Table.cell => {
  switch colType {
  | TransactionId => Text(transaction.transaction_id)
  | CreditAccount => Text(transaction.credit_account)
  | DebitAccount => Text(transaction.debit_account)
  | Amount => Text(Int.toString(transaction.amount))
  | Currency => Text(transaction.currency)
  | Variance => Text(Int.toString(transaction.variance))
  | Status =>
    Label({
      title: {transaction.status->String.toUpperCase},
      color: switch transaction.status->String.toLowerCase {
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
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.transaction_id}`),
          ~authorization,
        )
      }
    },
  )
}
