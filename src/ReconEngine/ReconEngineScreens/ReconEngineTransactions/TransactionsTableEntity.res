open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils

let defaultColumns: array<transactionColType> = [Id, TransactionId, Status]
let allColumns: array<transactionColType> = [Id, TransactionId, Status]

let getHeading = (colType: transactionColType) => {
  switch colType {
  | Id => Table.makeHeaderInfo(~key="id", ~title="ID")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  }
}

let getCell = (transaction: transactionPayload, colType: transactionColType): Table.cell => {
  switch colType {
  | Id => Text(transaction.id)
  | TransactionId => Text(transaction.transaction_id)
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
