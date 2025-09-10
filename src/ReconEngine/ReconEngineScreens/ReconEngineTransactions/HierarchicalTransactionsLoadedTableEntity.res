open ReconEngineTransactionsTypes
open Table

// Define column types for the hierarchical table
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
  | Date => Table.makeHeaderInfo(~key="date", ~title="Date", ~customWidth="w-24")
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

// We'll use transactionPayload directly instead of flattening

let getCell = (transaction: transactionPayload, colType: hierarchicalColType): Table.cell => {
  switch colType {
  | Date =>
    let transactionDate = transaction.created_at->String.substring(~start=0, ~end=10)
    Table.Text(transactionDate)
  | TransactionId => Table.Text(transaction.transaction_id)
  | Status =>
    let transactionStatus = switch transaction.discarded_status {
    | Some(status) => status
    | None => transaction.transaction_status
    }
    let statusColor = switch transactionStatus->String.toLowerCase {
    | "posted" => Table.LabelGreen
    | "mismatched" => Table.LabelRed
    | "expected" => Table.LabelBlue
    | "archived" => Table.LabelGray
    | _ => Table.LabelLightGray
    }
    Table.Label({title: transactionStatus->String.toUpperCase, color: statusColor})
  | EntryId =>
    let entryIdContent =
      <div className="-mx-8 border-r-gray-400 divide-y divide-gray-200">
        {transaction.entries
        ->Array.map(entry => {
          <div key={entry.entry_id} className="px-8 py-1 text-sm text-gray-900">
            {entry.entry_id->React.string}
          </div>
        })
        ->React.array}
      </div>
    Table.CustomCell(entryIdContent, "")
  | Account =>
    let accountContent =
      <div className="-mx-8 divide-y divide-gray-200">
        {transaction.entries
        ->Array.map(entry => {
          <div key={entry.entry_id} className="px-8 py-1 text-sm text-gray-900">
            {entry.account.account_name->React.string}
          </div>
        })
        ->React.array}
      </div>
    Table.CustomCell(accountContent, "")
  | EntryStatus =>
    let entryStatusContent =
      <div className="-mx-8 divide-y divide-gray-200">
        {transaction.entries
        ->Array.map(entry => {
          let entryStatus = switch entry.status {
          | Some(s) => s
          | None => "NA"
          }
          <div key={entry.entry_id} className="px-8 py-1 text-sm text-gray-900">
            {entryStatus->React.string}
          </div>
        })
        ->React.array}
      </div>
    Table.CustomCell(entryStatusContent, "")
  | Currency =>
    let currencyContent =
      <div className="-mx-8 divide-y divide-gray-200">
        {transaction.entries
        ->Array.map(entry => {
          let currency = switch entry.amount {
          | Some(amt) => amt.currency
          | None => "AUD"
          }
          <div key={entry.entry_id} className="px-8 py-1 text-sm text-gray-500">
            {currency->React.string}
          </div>
        })
        ->React.array}
      </div>
    Table.CustomCell(currencyContent, "")
  | DebitAmount =>
    let debitAmountContent =
      <div className="-mx-8 divide-y divide-gray-200">
        {transaction.entries
        ->Array.map(entry => {
          let amount = switch entry.entry_type {
          | "debit" =>
            switch entry.amount {
            | Some(amt) => amt.value->Float.toString
            | None => "-"
            }
          | _ => "-"
          }
          <div key={entry.entry_id} className="px-8 py-1 text-sm text-gray-900">
            {amount->React.string}
          </div>
        })
        ->React.array}
      </div>
    Table.CustomCell(debitAmountContent, "")
  | CreditAmount =>
    let creditAmountContent =
      <div className="-mx-8 divide-y divide-gray-200">
        {transaction.entries
        ->Array.map(entry => {
          let amount = switch entry.entry_type {
          | "credit" =>
            switch entry.amount {
            | Some(amt) => amt.value->Float.toString
            | None => "-"
            }
          | _ => "-"
          }
          <div key={entry.entry_id} className="px-8 py-1 text-sm text-gray-900">
            {amount->React.string}
          </div>
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
    ~getObjects=_json => {
      // This will be handled by the parent component
      []
    },
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="hierarchical_transactions",
    ~getShowLink={
      _ => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}`),
          ~authorization,
        )
      }
    },
  )
}
