open ReconEngineTypes
open ReconEngineTransactionsHelper
open Table

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

let getStatusLabel = (transactionStatus: transactionStatus): cell => {
  Label({
    title: (transactionStatus :> string)->String.toUpperCase,
    color: switch transactionStatus {
    | Posted => LabelGreen
    | Mismatched => LabelRed
    | Expected => LabelBlue
    | Archived => LabelGray
    | PartiallyReconciled => LabelOrange
    | _ => LabelLightGray
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
    | Some(discardedStatus) =>
      getStatusLabel(discardedStatus->ReconEngineUtils.getTransactionStatusVariantFromString)
    | None => getStatusLabel(transaction.transaction_status)
    }
  | EntryId =>
    let entryIdContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <>
            <RenderIf condition={entry.entry_id->LogicUtils.isNonEmptyString}>
              <div key={LogicUtils.randomString(~length=10)} className="px-8 py-3.5">
                <HelperComponents.CopyTextCustomComp
                  customParentClass="flex flex-row items-center gap-2"
                  customTextCss="truncate whitespace-nowrap max-w-32"
                  displayValue=Some(entry.entry_id)
                />
              </div>
            </RenderIf>
            <RenderIf condition={entry.entry_id->LogicUtils.isEmptyString}>
              <p key={LogicUtils.randomString(~length=10)} className="px-8 py-3.5 text-nd_gray-600">
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
            <RenderIf condition={entry.order_id->LogicUtils.isNonEmptyString}>
              <div key={LogicUtils.randomString(~length=10)} className="px-8 py-3.5">
                <HelperComponents.CopyTextCustomComp
                  customParentClass="flex flex-row items-center gap-2"
                  customTextCss="truncate whitespace-nowrap max-w-48"
                  displayValue=Some(entry.order_id)
                />
              </div>
            </RenderIf>
            <RenderIf condition={entry.order_id->LogicUtils.isEmptyString}>
              <p key={LogicUtils.randomString(~length=10)} className="px-8 py-3.5 text-nd_gray-600">
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
            fieldValue=entry.account.account_name key={LogicUtils.randomString(~length=10)}
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
            fieldValue={(entry.status :> string)->LogicUtils.capitalizeString}
            key={LogicUtils.randomString(~length=10)}
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
            fieldValue=entry.amount.currency key={LogicUtils.randomString(~length=10)}
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
          <HierarchicalEntryRenderer fieldValue=amount key={LogicUtils.randomString(~length=10)} />
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
          <HierarchicalEntryRenderer fieldValue=amount key={LogicUtils.randomString(~length=10)} />
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
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.id}`),
          ~authorization,
        )
      }
    },
  )
}
