open Typography
open ReconEngineTypes
open CurrencyFormatUtils

type balanceCategory = {
  label: string,
  value: float,
  color: string,
  textColor: string,
}

let getBalanceCategories = (accountsData: array<accountType>): array<balanceCategory> => {
  let totalPosted =
    accountsData->Array.reduce(0.0, (acc, account) =>
      acc +. Math.abs(account.posted_debits.value) +. Math.abs(account.posted_credits.value)
    )
  let totalPending =
    accountsData->Array.reduce(0.0, (acc, account) =>
      acc +. Math.abs(account.pending_debits.value) +. Math.abs(account.pending_credits.value)
    )
  let totalMismatched =
    accountsData->Array.reduce(0.0, (acc, account) =>
      acc +. Math.abs(account.mismatched_debits.value) +. Math.abs(account.mismatched_credits.value)
    )

  [
    {label: "Reconciled", value: totalPosted, color: "bg-nd_green-400", textColor: "text-nd_green-700"},
    {label: "Pending", value: totalPending, color: "bg-nd_yellow-400", textColor: "text-nd_yellow-700"},
    {
      label: "Mismatched",
      value: totalMismatched,
      color: "bg-nd_red-400",
      textColor: "text-nd_red-700",
    },
  ]
}

@react.component
let make = (~accountsData: array<accountType>) => {
  let categories = React.useMemo(() => {
    getBalanceCategories(accountsData)
  }, [accountsData])

  let total = categories->Array.reduce(0.0, (acc, cat) => acc +. cat.value)

  <RenderIf condition={total > 0.0}>
    <div className="border border-nd_gray-150 rounded-xl p-4 bg-white mb-4">
      <p className={`text-nd_gray-700 ${body.md.semibold} mb-3`}>
        {"Balance Distribution"->React.string}
      </p>
      <div className="flex flex-row h-3 rounded-full overflow-hidden gap-0.5 w-full mb-3">
        {categories
        ->Array.mapWithIndex((cat, index) => {
          let widthPct = cat.value /. total *. 100.0
          <RenderIf key={index->Int.toString} condition={widthPct > 0.0}>
            <div
              className={`${cat.color} rounded-full transition-all duration-300`}
              style={ReactDOM.Style.make(
                ~width=`${widthPct->Float.toFixedWithPrecision(~digits=1)}%`,
                (),
              )}
            />
          </RenderIf>
        })
        ->React.array}
      </div>
      <div className="flex flex-row items-center gap-6">
        {categories
        ->Array.mapWithIndex((cat, index) => {
          <div key={index->Int.toString} className="flex flex-row items-center gap-2">
            <div className={`w-2.5 h-2.5 rounded-full ${cat.color}`} />
            <span className={`${body.sm.medium} text-nd_gray-500`}> {cat.label->React.string} </span>
            <span className={`${body.sm.semibold} ${cat.textColor}`}>
              {cat.value->valueFormatter(AmountWithSuffix)->React.string}
            </span>
          </div>
        })
        ->React.array}
      </div>
    </div>
  </RenderIf>
}
