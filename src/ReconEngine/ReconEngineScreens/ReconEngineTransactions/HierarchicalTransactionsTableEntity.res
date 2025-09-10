open ReconEngineTransactionsTypes
open ReconEngineTransactionsUtils
open ReconEngineTransactionsHelper

open Table

type hierarchicalColType =
  | Date
  | TransactionId
  | Status
  | EntryId
  | Account
  | EntryStatus
  | Currency
  | DebitAmount
  | CreditAmount

let defaultColumns: array<hierarchicalColType> = [
  Date,
  TransactionId,
  Status,
  EntryId,
  Account,
  EntryStatus,
  Currency,
  DebitAmount,
  CreditAmount,
]

let allColumns: array<hierarchicalColType> = [
  Date,
  TransactionId,
  Status,
  EntryId,
  Account,
  EntryStatus,
  Currency,
  DebitAmount,
  CreditAmount,
]

let getHeading = (colType: hierarchicalColType) => {
  switch colType {
  | Date => Table.makeHeaderInfo(~key="date", ~title="Date", ~customWidth="!w-24")
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | EntryId => Table.makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | Account => Table.makeHeaderInfo(~key="account", ~title="Account")
  | EntryStatus => Table.makeHeaderInfo(~key="entry_status", ~title="Entry Status")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | DebitAmount => Table.makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | CreditAmount => Table.makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  }
}

let getStatusLabel = (statusString: string): Table.cell => {
  Table.Label({
    title: statusString->String.toUpperCase,
    color: switch statusString->ReconEngineTransactionsUtils.getTransactionTypeFromString {
    | Posted => Table.LabelGreen
    | Mismatched => Table.LabelRed
    | Expected => Table.LabelBlue
    | Archived => Table.LabelGray
    | _ => Table.LabelLightGray
    },
  })
}

let getCell = (transaction: transactionPayload, colType: hierarchicalColType): Table.cell => {
  let hierarchicalContainerClassName = "-mx-8 border-r-gray-400 divide-y divide-gray-200"
  switch colType {
  | Date => DateWithoutTime(transaction.created_at)
  | TransactionId => Table.Text(transaction.transaction_id)
  | Status =>
    switch transaction.discarded_status {
    | Some(status) => getStatusLabel(status)
    | None => getStatusLabel(transaction.transaction_status)
    }
  | EntryId =>
    let entryIdContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.mapWithIndex((entry, index) => {
          <HierarchicalEntryRenderer
            fieldValue=entry.entry_id index entryClassName="w-36 truncate whitespace-nowrap"
          />
        })
        ->React.array}
      </div>
    Table.CustomCell(entryIdContent, "")
  | Account =>
    let accountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.mapWithIndex((entry, index) => {
          <HierarchicalEntryRenderer fieldValue=entry.account.account_name index />
        })
        ->React.array}
      </div>
    Table.CustomCell(accountContent, "")
  | EntryStatus =>
    let entryStatusContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.mapWithIndex((entry, index) => {
          <HierarchicalEntryRenderer fieldValue={entry.status->LogicUtils.capitalizeString} index />
        })
        ->React.array}
      </div>
    Table.CustomCell(entryStatusContent, "")
  | Currency =>
    let currencyContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.mapWithIndex((entry, index) => {
          <HierarchicalEntryRenderer fieldValue=entry.amount.currency index />
        })
        ->React.array}
      </div>
    Table.CustomCell(currencyContent, "")
  | DebitAmount =>
    let debitAmountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.mapWithIndex((entry, index) => {
          let amount = switch entry.entry_type {
          | "debit" => entry.amount.value->Float.toString
          | _ => "-"
          }
          <HierarchicalEntryRenderer fieldValue=amount index />
        })
        ->React.array}
      </div>
    Table.CustomCell(debitAmountContent, "")
  | CreditAmount =>
    let creditAmountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.mapWithIndex((entry, index) => {
          let amount = switch entry.entry_type {
          | "credit" => entry.amount.value->Float.toString
          | _ => "-"
          }
          <HierarchicalEntryRenderer fieldValue=amount index />
        })
        ->React.array}
      </div>
    Table.CustomCell(creditAmountContent, "")
  }
}

let hierarchicalTransactionsLoadedTableEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getTransactionsList,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="hierarchical_transactions",
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
