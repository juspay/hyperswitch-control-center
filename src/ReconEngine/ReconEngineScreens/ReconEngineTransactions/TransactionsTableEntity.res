open ReconEngineTypes
open ReconEngineUtils
open ReconEngineTransactionsUtils
open LogicUtils

type transactionColType =
  | TransactionId
  | CreditAccount
  | DebitAccount
  | CreditAmount
  | DebitAmount
  | Variance
  | Status
  | CreatedAt
  | ReconciliationType
  | Reason

let defaultColumns: array<transactionColType> = [
  TransactionId,
  CreditAccount,
  DebitAccount,
  Variance,
  Status,
  CreatedAt,
]

let defaultColumnsOverview: array<transactionColType> = [
  TransactionId,
  CreditAmount,
  DebitAmount,
  Variance,
  Status,
  CreatedAt,
]

let allColumns: array<transactionColType> = [
  TransactionId,
  CreditAccount,
  DebitAccount,
  CreditAmount,
  DebitAmount,
  Variance,
  Status,
  CreatedAt,
]

let getHeading = (colType: transactionColType) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | CreditAccount => Table.makeHeaderInfo(~key="credit_account", ~title="Source Account")
  | DebitAccount => Table.makeHeaderInfo(~key="debit_account", ~title="Target Account")
  | CreditAmount => Table.makeHeaderInfo(~key="credit_amount", ~title="Credit Amount")
  | DebitAmount => Table.makeHeaderInfo(~key="debit_amount", ~title="Debit Amount")
  | Variance => Table.makeHeaderInfo(~key="variance", ~title="Variance")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | ReconciliationType =>
    Table.makeHeaderInfo(~key="reconciliation_type", ~title="Reconciliation Type")
  | Reason => Table.makeHeaderInfo(~key="reason", ~title="Reason")
  }
}

let getStatusLabel = (statusString: transactionStatus): Table.cell => {
  Table.Label({
    title: (statusString :> string)->String.toUpperCase,
    color: switch statusString {
    | Posted => LabelGreen
    | Mismatched => LabelRed
    | Expected => LabelBlue
    | Archived => LabelGray
    | PartiallyReconciled => LabelOrange
    | _ => LabelLightGray
    },
  })
}

let getReconciledTypeLabel = (statusString: transactionPostedType): Table.cell => {
  Table.Label({
    title: (statusString :> string)->String.toUpperCase,
    color: switch statusString {
    | ForceReconciled => LabelOrange
    | ManuallyReconciled => LabelGray
    | Reconciled => LabelBlue
    | _ => LabelLightGray
    },
  })
}

let getCell = (transaction: transactionType, colType: transactionColType): Table.cell => {
  open CurrencyFormatUtils
  switch colType {
  | TransactionId =>
    CustomCell(
      <>
        <RenderIf condition={transaction.transaction_id->isNonEmptyString}>
          <HelperComponents.CopyTextCustomComp
            customTextCss="max-w-36 truncate whitespace-nowrap"
            displayValue=Some(transaction.transaction_id)
          />
        </RenderIf>
        <RenderIf condition={transaction.transaction_id->isEmptyString}>
          <p className="text-nd_gray-600"> {"N/A"->React.string} </p>
        </RenderIf>
      </>,
      "",
    )
  | CreditAccount => Text(getAccounts(transaction.entries, Credit))
  | DebitAccount => Text(getAccounts(transaction.entries, Debit))
  | CreditAmount =>
    Text(
      valueFormatter(
        transaction.credit_amount.value,
        AmountWithSuffix,
        ~suffix=transaction.credit_amount.currency,
      ),
    )
  | DebitAmount =>
    Text(
      valueFormatter(
        transaction.debit_amount.value,
        AmountWithSuffix,
        ~suffix=transaction.debit_amount.currency,
      ),
    )
  | Variance =>
    Text(
      valueFormatter(
        Math.abs(transaction.credit_amount.value -. transaction.debit_amount.value),
        AmountWithSuffix,
        ~suffix=transaction.credit_amount.currency,
      ),
    )
  | Status =>
    switch transaction.discarded_status {
    | Some(status) => getStatusLabel(status->getTransactionStatusVariantFromString)
    | None => getStatusLabel(transaction.transaction_status)
    }
  | CreatedAt => Date(transaction.created_at)
  | ReconciliationType =>
    switch transaction.data.posted_type {
    | Some(postedType) => getReconciledTypeLabel(postedType)
    | None => getReconciledTypeLabel(UnknownTransactionPostedType)
    }
  | Reason => EllipsisText(transaction.data.reason->Option.getOr("N/A"), "max-w-96")
  }
}

let transactionsEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
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
