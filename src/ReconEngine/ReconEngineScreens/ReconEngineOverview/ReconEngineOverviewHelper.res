open Typography

module CreditDebitAmountRow = {
  @react.component
  let make = (
    ~statusType: ReconEngineOverviewSummaryTypes.amountType,
    ~label: string,
    ~creditAmount: ReconEngineTypes.balanceType,
    ~creditCount: int,
    ~debitAmount: ReconEngineTypes.balanceType,
    ~debitCount: int,
  ) => {
    open ReconEngineOverviewSummaryHelper
    let (iconName, iconColor) = ReconEngineOverviewSummaryUtils.getStatusIcon(statusType)

    <div className="flex flex-row items-center">
      <div className="flex flex-row items-center gap-1.5 flex-[1]">
        <Icon name={iconName} className={iconColor} size=12 />
        <p className={`${body.md.medium} text-nd_gray-500`}> {label->React.string} </p>
      </div>
      <div className="flex flex-row flex-[1] justify-between items-center">
        <div className="flex flex-1 flex-col items-center justify-center">
          <p className={`${body.md.semibold} text-nd_gray-600`}>
            <AmountCell value={Math.abs(debitAmount.value)} currency={debitAmount.currency} />
          </p>
          <p className={`${body.sm.medium} text-nd_gray-400`}>
            <NumberCell value=debitCount />
          </p>
        </div>
        <div className="flex flex-1 flex-col items-center justify-center">
          <p className={`${body.md.semibold} text-nd_gray-600`}>
            <AmountCell value={Math.abs(creditAmount.value)} currency={creditAmount.currency} />
          </p>
          <p className={`${body.sm.medium} text-nd_gray-400`}>
            <NumberCell value=creditCount />
          </p>
        </div>
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
    open ReconEngineOverviewSummaryTypes

    let pendingLabel = isSource ? "Pending" : "Expected"

    <div className="border rounded-xl border-nd_gray-200 ">
      <div className="border-b p-4 bg-nd_gray-25 rounded-t-xl   ">
        <p className={`${body.md.semibold} text-nd_gray-800`}> {accountName->React.string} </p>
      </div>
      <div className="p-4 flex flex-col gap-3">
        <div className="flex flex-row items-center">
          <div className="flex-[1]" />
          <div className="flex flex-row flex-[1] justify-between items-center">
            <p className={`${body.sm.semibold} text-nd_gray-400 uppercase flex-1 text-center`}>
              {"Debit"->React.string}
            </p>
            <p className={`${body.sm.semibold} text-nd_gray-400 uppercase flex-1 text-center`}>
              {"Credit"->React.string}
            </p>
          </div>
        </div>
        <CreditDebitAmountRow
          statusType=MatchedAmount
          label={`Matched with ${otherAccountName}`}
          creditAmount={transactionData.matched_transaction_amount}
          creditCount={transactionData.matched_transaction_count}
          debitAmount={transactionData.matched_confirmation_amount}
          debitCount={transactionData.matched_confirmation_count}
        />
        <CreditDebitAmountRow
          statusType=MismatchedAmount
          label={`Mismatch with ${otherAccountName}`}
          creditAmount={transactionData.mismatched_transaction_amount}
          creditCount={transactionData.mismatched_transaction_count}
          debitAmount={transactionData.mismatched_confirmation_amount}
          debitCount={transactionData.mismatched_confirmation_count}
        />
        <CreditDebitAmountRow
          statusType=PendingAmount
          label={pendingLabel}
          creditAmount={transactionData.pending_transaction_amount}
          creditCount={transactionData.pending_transaction_count}
          debitAmount={transactionData.pending_confirmation_amount}
          debitCount={transactionData.pending_confirmation_count}
        />
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
