open ReconEngineTypes
open ReconEngineTransactionsHelper
open Table
open LogicUtils

type hierarchicalColType =
  | Flow
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
  | RuleName
  | CreatedAt

let defaultColumns: array<hierarchicalColType> = [
  Flow,
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

// Columns the customize-columns modal renders as locked (non-hideable)
let mandatoryColumns: array<hierarchicalColType> = [TransactionId, Status]

let allColumns: array<hierarchicalColType> = [
  Flow,
  Date,
  TransactionId,
  Status,
  RuleName,
  CreatedAt,
  EntryId,
  OrderId,
  Account,
  EntryStatus,
  Currency,
  DebitAmount,
  CreditAmount,
]

// Entry-level columns render one nested row per entry; used to compute where the
// transaction-level / entry-level visual separation falls for a given visible set
let entryLevelColumns: array<hierarchicalColType> = [
  EntryId,
  OrderId,
  Account,
  EntryStatus,
  Currency,
  DebitAmount,
  CreditAmount,
]

let getCustomSeparation = (visibleColumns: array<hierarchicalColType>): array<(int, int)> => {
  let firstEntryIndex =
    visibleColumns->Array.findIndex(col => entryLevelColumns->Array.includes(col))
  firstEntryIndex > 0 ? [(firstEntryIndex - 1, firstEntryIndex)] : []
}

let getHeading = (colType: hierarchicalColType) => {
  switch colType {
  | Flow => makeHeaderInfo(~key="flow", ~title="", ~customWidth="!w-28")
  | Date => makeHeaderInfo(~key="date", ~title="Date", ~customWidth="!w-24", ~showSort=true)
  | TransactionId => makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | Status => makeHeaderInfo(~key="status", ~title="Status")
  | EntryId => makeHeaderInfo(~key="entry_id", ~title="Entry ID")
  | OrderId => makeHeaderInfo(~key="order_id", ~title="Order ID")
  | Account => makeHeaderInfo(~key="account", ~title="Account")
  | EntryStatus => makeHeaderInfo(~key="entry_status", ~title="Entry Status")
  | Currency => makeHeaderInfo(~key="currency", ~title="Currency")
  | DebitAmount => makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | CreditAmount => makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  | RuleName => makeHeaderInfo(~key="rule_name", ~title="Rule Name")
  | CreatedAt => makeHeaderInfo(~key="created_at", ~title="Created At", ~customWidth="!w-24")
  }
}

let getStatusLabel = (status: domainTransactionStatus, ~mismatchedFields=[]): Table.cell => {
  let title = status->TransactionsTableEntity.getDomainTransactionStatusString->String.toUpperCase

  CustomCell(
    <ToolTip
      description={mismatchedFields->ReconEngineUtils.getMismatchedFieldsCountText}
      toolTipPosition=ToolTip.Top
      toolTipFor={<TableUtils.LabelCell
        labelColor={ReconEngineTransactionsUtils.getTransactionStatusLabelColor(status)} text=title
      />}
    />,
    title,
  )
}

let getTransactionFlowBadge = (
  flowType: ReconEngineTransactionsTypes.transactionFlowType,
): React.element => {
  let (iconName, badgeClass, rotationClass) = switch flowType {
  | InFlow => ("nd-arrow-down-no-underline", "bg-nd_green-50 text-nd_green-600", "-rotate-45")
  | OutFlow => ("nd-arrow-up-no-underline", "bg-nd_red-50 text-nd_red-600", "rotate-45")
  | UnknownTransactionFlowType => ("nd-alert-triangle-outline", "bg-nd_red-50 text-nd_red-600", "")
  }
  <div className={`inline-flex items-center gap-1 px-2 py-1 rounded-md shrink-0 ${badgeClass}`}>
    <Icon name=iconName size=12 className=rotationClass />
    <span className="text-xs font-medium">
      {(flowType :> string)->String.toUpperCase->React.string}
    </span>
  </div>
}

let getCell = (
  transaction: transactionType,
  colType: hierarchicalColType,
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>=[],
  ~accountData: array<accountType>=[],
): cell => {
  let hierarchicalContainerClassName = "-mx-8 border-r-gray-400 divide-y divide-gray-200"
  switch colType {
  | Flow =>
    let flowBadge =
      ReconEngineTransactionsUtils.getTransactionFlowType(
        ~transaction,
        ~reconRulesList,
        ~accountData,
      )->getTransactionFlowBadge
    CustomCell(<div className="flex items-center justify-center"> {flowBadge} </div>, "")
  | Date =>
    transaction.effective_at->isNonEmptyString
      ? CustomCell(
          <TableUtils.DateCell
            timestamp=transaction.effective_at textAlign=Left hideTimeZone=true convertToLocal=false
          />,
          transaction.effective_at,
        )
      : Text("-")
  | TransactionId => DisplayCopyCell(transaction.transaction_id)
  | Status =>
    let mismatchedFields = transaction.data.mismatched_fields
    switch transaction.discarded_status {
    | Some(status) => getStatusLabel(status, ~mismatchedFields)
    | None => getStatusLabel(transaction.transaction_status, ~mismatchedFields)
    }
  | EntryId =>
    let entryIdContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <React.Fragment key={entry.entry_id}>
            <RenderIf condition={entry.entry_id->isNonEmptyString}>
              <div className="px-8 py-3.5">
                <HelperComponents.CopyTextCustomComp
                  customParentClass="flex flex-row items-center gap-2"
                  customTextCss="truncate whitespace-nowrap max-w-32"
                  displayValue=Some(entry.entry_id)
                />
              </div>
            </RenderIf>
            <RenderIf condition={entry.entry_id->isEmptyString}>
              <p className="px-8 py-3.5 text-nd_gray-600"> {"N/A"->React.string} </p>
            </RenderIf>
          </React.Fragment>
        })
        ->React.array}
      </div>
    CustomCell(entryIdContent, "")
  | OrderId =>
    let orderIdContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <React.Fragment key={entry.entry_id}>
            <RenderIf condition={entry.order_id->isNonEmptyString}>
              <div className="px-8 py-3.5">
                <HelperComponents.CopyTextCustomComp
                  customParentClass="flex flex-row items-center gap-2"
                  customTextCss="truncate whitespace-nowrap max-w-48"
                  displayValue=Some(entry.order_id)
                />
              </div>
            </RenderIf>
            <RenderIf condition={entry.order_id->isEmptyString}>
              <p className="px-8 py-3.5 text-nd_gray-600"> {"N/A"->React.string} </p>
            </RenderIf>
          </React.Fragment>
        })
        ->React.array}
      </div>
    CustomCell(orderIdContent, "")
  | Account =>
    let accountContent =
      <div className=hierarchicalContainerClassName>
        {transaction.entries
        ->Array.map(entry => {
          <HierarchicalEntryRenderer fieldValue=entry.account.account_name key={entry.entry_id} />
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
            fieldValue={(entry.status :> string)->capitalizeString} key={entry.entry_id}
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
          <HierarchicalEntryRenderer fieldValue=entry.amount.currency key={entry.entry_id} />
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
          | Credit | UnknownEntryDirectionType => "-"
          }
          <HierarchicalEntryRenderer fieldValue=amount key={entry.entry_id} />
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
          | Debit | UnknownEntryDirectionType => "-"
          }
          <HierarchicalEntryRenderer fieldValue=amount key={entry.entry_id} />
        })
        ->React.array}
      </div>
    CustomCell(creditAmountContent, "")
  | RuleName => Text(transaction.rule.rule_name)
  | CreatedAt => DateWithoutTime(transaction.created_at)
  }
}

let hierarchicalTransactionsLoadedTableEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>=[],
  ~accountData: array<accountType>=[],
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=(transaction, colType) => getCell(transaction, colType, ~reconRulesList, ~accountData),
    ~dataKey="hierarchical_transactions",
    ~getShowLink={
      connectorObj => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connectorObj.transaction_id}`),
          ~authorization,
        )
      }
    },
  )
}
