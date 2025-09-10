open Typography
open LogicUtils
module AmountRow = {
  @react.component
  let make = (~label: string, ~amount: string, ~count: string) => {
    <div className="flex flex-row justify-between items-center">
      <div>
        <p className={`${body.md.medium} text-nd_gray-400 mb-1`}> {label->React.string} </p>
      </div>
      <div className="flex flex-col items-end">
        <p className={`${body.lg.semibold} text-nd_gray-600`}> {amount->React.string} </p>
        <p className={`${body.sm.medium} text-nd_gray-400`}> {count->React.string} </p>
      </div>
    </div>
  }
}

module AccountDetailCard = {
  @react.component
  let make = (
    ~accountName: string,
    ~otherAccountName: string,
    ~isSource: bool,
    ~transactionData: ReconEngineOverviewSummaryTypes.accountTransactionData,
  ) => {
    let formatAmount = (balance: ReconEngineOverviewTypes.balanceType): string => {
      `${Math.abs(balance.value)->valueFormatter(Amount)} ${balance.currency}`
    }

    let formatCount = (count: int): string => {
      `${count->Int.toString} Txns`
    }

    let (
      reconciledAmount,
      reconciledCount,
      mismatchAmount,
      mismatchCount,
      pendingAmount,
      pendingCount,
      pendingLabel,
    ) = if isSource {
      (
        formatAmount(transactionData.posted_transaction_amount),
        formatCount(transactionData.posted_transaction_count),
        formatAmount(transactionData.mismatched_transaction_amount),
        formatCount(transactionData.mismatched_transaction_count),
        formatAmount(transactionData.pending_transaction_amount),
        formatCount(transactionData.pending_transaction_count),
        "Pending",
      )
    } else {
      (
        formatAmount(transactionData.posted_confirmation_amount),
        formatCount(transactionData.posted_confirmation_count),
        formatAmount(transactionData.mismatched_confirmation_amount),
        formatCount(transactionData.mismatched_confirmation_count),
        formatAmount(transactionData.pending_confirmation_amount),
        formatCount(transactionData.pending_confirmation_count),
        "Expected",
      )
    }

    <div className="border rounded-xl border-nd_gray-200 ">
      <div className="border-b p-4 bg-nd_gray-25 rounded-t-xl   ">
        <p className={`${body.md.semibold} text-nd_gray-800`}> {accountName->React.string} </p>
      </div>
      <div className="p-4 flex flex-col gap-4">
        <AmountRow
          label={`Reconciled with ${otherAccountName}`}
          amount={reconciledAmount}
          count={reconciledCount}
        />
        <AmountRow
          label={`Mismatch with ${otherAccountName}`} amount={mismatchAmount} count={mismatchCount}
        />
        <div className="border-t pt-4">
          <p className={`${body.sm.semibold} text-nd_gray-600 mb-3`}>
            {"FUNDS IN FLIGHT"->React.string}
          </p>
          <AmountRow label={pendingLabel} amount={pendingAmount} count={pendingCount} />
        </div>
      </div>
    </div>
  }
}
module OverviewCard = {
  @react.component
  let make = (~title, ~value) => {
    <div
      className="flex flex-col gap-4 bg-white border border-nd_gray-200 rounded-xl p-4 shadow-xs">
      <div className={`${body.md.medium} text-nd_gray-400`}> {title->React.string} </div>
      <div className={`${heading.md.semibold} text-nd_gray-800`}> {value->React.string} </div>
    </div>
  }
}
