open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils

let defaultColumns: array<transactionColType> = [
  Id,
  TransactionId,
  CreditAccount,
  DebitAccount,
  Amount,
  Currency,
  Status,
  DiscardedStatus,
  Variance,
  CreatedAt,
]
let allColumns: array<transactionColType> = [
  Id,
  TransactionId,
  CreditAccount,
  DebitAccount,
  Amount,
  Currency,
  Status,
  DiscardedStatus,
  Variance,
  CreatedAt,
]

let getHeading = (colType: transactionColType) => {
  switch colType {
  | Id => Table.makeHeaderInfo(~key="id", ~title="ID")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | CreditAccount => Table.makeHeaderInfo(~key="credit_account", ~title="Credit Account")
  | DebitAccount => Table.makeHeaderInfo(~key="debit_account", ~title="Debit Account")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | DiscardedStatus => Table.makeHeaderInfo(~key="discarded_status", ~title="Discarded Status")
  | Variance => Table.makeHeaderInfo(~key="variance", ~title="Variance")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  }
}

let getCell = (transaction: transactionPayload, colType: transactionColType): Table.cell => {
  switch colType {
  | Id => Text(transaction.id)
  | TransactionId => Text(transaction.transaction_id)
  | CreditAccount => Text(transaction.credit_account)
  | DebitAccount => Text(transaction.debit_account)
  | Amount => Text(Float.toString(transaction.amount))
  | Currency => Text(transaction.currency)
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
  | DiscardedStatus =>
    Label({
      title: {transaction.discarded_status->String.toUpperCase},
      color: switch transaction.discarded_status->String.toLowerCase {
      | "posted" => LabelGreen
      | "mismatched" => LabelRed
      | "expected" => LabelBlue
      | "archived" => LabelGray
      | _ => LabelGray
      },
    })
  | Variance => Text(Int.toString(transaction.variance))

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
