open ReconEngineTypes
open ReconEngineTransactionsHelper
open Table
open LogicUtils

type hierarchicalColType =
  | Date
  | TransactionId
  | Status
  | EntryId
  | OrderId
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
  OrderId,
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
  OrderId,
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
  | OrderId => makeHeaderInfo(~key="order_id", ~title="Order ID")
  | Account => makeHeaderInfo(~key="account", ~title="Account")
  | EntryStatus => makeHeaderInfo(~key="entry_status", ~title="Entry Status")
  | Currency => makeHeaderInfo(~key="currency", ~title="Currency")
  | DebitAmount => makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | CreditAmount => makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  }
}

let getDomainTransactionStatusString = (status: domainTransactionStatus) => {
  switch status {
  | Posted(_) => "Posted"
  | OverAmount(_) => "Over Payment"
  | UnderAmount(_) => "Under Amount"
  | DataMismatch => "Data Mismatch"
  | Expected => "Expected"
  | Archived => "Archived"
  | PartiallyReconciled => "Partially Reconciled"
  | Void => "Void"
  | UnknownDomainTransactionStatus => "Unknown"
  }
}

let getStatusLabel = (status: domainTransactionStatus): Table.cell => {
  Table.Label({
    title: status->getDomainTransactionStatusString->String.toUpperCase,
    color: switch status {
    | Posted(_) => LabelGreen
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch)
    | DataMismatch =>
      LabelRed
    | Expected | UnderAmount(Expected) | OverAmount(Expected) => LabelBlue
    | Archived => LabelGray
    | PartiallyReconciled => LabelOrange
    | Void | UnknownDomainTransactionStatus => LabelLightGray
    },
  })
}

let getCell = (transaction: transactionType, colType: hierarchicalColType): cell => {
  let hierarchicalContainerClassName = "-mx-8 border-r-gray-400 divide-y divide-gray-200"
  switch colType {
  | Date => DateWithoutTime(transaction.effective_at)
  | TransactionId => DisplayCopyCell(transaction.transaction_id)
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
          <>
            <RenderIf condition={entry.entry_id->isNonEmptyString}>
              <div key={randomString(~length=10)} className="px-8 py-3.5">
                <HelperComponents.CopyTextCustomComp
                  customParentClass="flex flex-row items-center gap-2"
                  customTextCss="truncate whitespace-nowrap max-w-32"
                  displayValue=Some(entry.entry_id)
                />
              </div>
            </RenderIf>
            <RenderIf condition={entry.entry_id->isEmptyString}>
              <p key={randomString(~length=10)} className="px-8 py-3.5 text-nd_gray-600">
                {"N/A"->React.string}
              </p>
            </RenderIf>
          </>
        })
        ->React.array}
      </div>
    CustomCell(entryIdContent, "")
  | OrderId =>
    let orderIdContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <>
            <RenderIf condition={entry.order_id->isNonEmptyString}>
              <div key={randomString(~length=10)} className="px-8 py-3.5">
                <HelperComponents.CopyTextCustomComp
                  customParentClass="flex flex-row items-center gap-2"
                  customTextCss="truncate whitespace-nowrap max-w-48"
                  displayValue=Some(entry.order_id)
                />
              </div>
            </RenderIf>
            <RenderIf condition={entry.order_id->isEmptyString}>
              <p key={randomString(~length=10)} className="px-8 py-3.5 text-nd_gray-600">
                {"N/A"->React.string}
              </p>
            </RenderIf>
          </>
        })
        ->React.array}
      </div>
    CustomCell(orderIdContent, "")
  | Account =>
    let accountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer
            fieldValue=entry.account.account_name key={randomString(~length=10)}
          />
        })
        ->React.array}
      </div>
    CustomCell(accountContent, "")
  | EntryStatus =>
    let entryStatusContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer
            fieldValue={(entry.status :> string)->capitalizeString} key={randomString(~length=10)}
          />
        })
        ->React.array}
      </div>
    CustomCell(entryStatusContent, "")
  | Currency =>
    let currencyContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer
            fieldValue=entry.amount.currency key={randomString(~length=10)}
          />
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
          <HierarchicalEntryRenderer fieldValue=amount key={randomString(~length=10)} />
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
          <HierarchicalEntryRenderer fieldValue=amount key={randomString(~length=10)} />
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
    ~getObjects=_ => [],
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="hierarchical_transactions",
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
