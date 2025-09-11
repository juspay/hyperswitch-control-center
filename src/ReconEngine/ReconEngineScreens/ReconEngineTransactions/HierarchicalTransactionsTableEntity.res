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
  | Date => makeHeaderInfo(~key="date", ~title="Date", ~customWidth="!w-24")
  | TransactionId => makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Status => makeHeaderInfo(~key="status", ~title="Status")
  | EntryId => makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | Account => makeHeaderInfo(~key="account", ~title="Account")
  | EntryStatus => makeHeaderInfo(~key="entry_status", ~title="Entry Status")
  | Currency => makeHeaderInfo(~key="currency", ~title="Currency")
  | DebitAmount => makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | CreditAmount => makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  }
}

let getStatusLabel = (statusString: string): cell => {
  Label({
    title: statusString->String.toUpperCase,
    color: switch statusString->ReconEngineTransactionsUtils.getTransactionTypeFromString {
    | Posted => LabelGreen
    | Mismatched => LabelRed
    | Expected => LabelBlue
    | Archived => LabelGray
    | _ => LabelLightGray
    },
  })
}

let getCell = (transaction: transactionPayload, colType: hierarchicalColType): cell => {
  let hierarchicalContainerClassName = "-mx-8 border-r-gray-400 divide-y divide-gray-200"
  switch colType {
  | Date => DateWithoutTime(transaction.created_at)
  | TransactionId => Text(transaction.transaction_id)
  | Status =>
    switch transaction.discarded_status {
    | Some(status) => getStatusLabel(status)
    | None => getStatusLabel(transaction.transaction_status)
    }
  | EntryId =>
    let entryIdContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer fieldValue=entry.entry_id />
        })
        ->React.array}
      </div>
    CustomCell(entryIdContent, "")
  | Account =>
    let accountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer fieldValue=entry.account.account_name />
        })
        ->React.array}
      </div>
    CustomCell(accountContent, "")
  | EntryStatus =>
    let entryStatusContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer fieldValue={entry.status->LogicUtils.capitalizeString} />
        })
        ->React.array}
      </div>
    CustomCell(entryStatusContent, "")
  | Currency =>
    let currencyContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer fieldValue=entry.amount.currency />
        })
        ->React.array}
      </div>
    CustomCell(currencyContent, "")
  | DebitAmount =>
    let debitAmountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          let amount = switch entry.entry_type {
          | Debit => entry.amount.value->Float.toString
          | _ => "-"
          }
          <HierarchicalEntryRenderer fieldValue=amount />
        })
        ->React.array}
      </div>
    CustomCell(debitAmountContent, "")
  | CreditAmount =>
    let creditAmountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          let amount = switch entry.entry_type {
          | Credit => entry.amount.value->Float.toString
          | _ => "-"
          }
          <HierarchicalEntryRenderer fieldValue=amount />
        })
        ->React.array}
      </div>
    CustomCell(creditAmountContent, "")
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
