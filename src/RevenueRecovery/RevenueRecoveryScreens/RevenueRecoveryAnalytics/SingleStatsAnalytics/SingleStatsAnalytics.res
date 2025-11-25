module StatCard = {
  open Typography

  @react.component
  let make = (~title, ~value, ~change, ~soft, ~hard) => {
    <div className="bg-white border border-nd_br_gray-200 rounded-xl p-5 flex-1">
      <div className="flex items-center justify-between">
        <span className={`${body.sm.medium} text-nd_gray-500`}> {React.string(title)} </span>
      </div>
      <div className={`mt-2 ${heading.xl.semibold} flex items-center`}>
        {React.string(value)}
        <span className={`ml-2 ${body.md.medium} text-nd_green-400`}> {React.string(change)} </span>
      </div>
      <div className="border-t border-dashed border-nd_br_gray-200 my-2" />
      <div className={`mt-4 ${body.xs.regular} text-nd_gray-500`}>
        <span className={body.sm.semibold}> {"Decline Breakdown:"->React.string} </span>
        <div className="mt-2 flex gap-4">
          <span>
            <span className={body.xs.semibold}> {"Soft : "->React.string} </span>
            {React.string(soft)}
          </span>
          <span>
            <span className={body.xs.semibold}> {"Hard : "->React.string} </span>
            {React.string(hard)}
          </span>
        </div>
      </div>
    </div>
  }
}

module BudgetCard = {
  open LocalStorage
  open CurrencyFormatUtils
  open Typography

  let localStorageKey = "hard_decline_budget"
  let defaultBudget = "1600"

  let originalBudget = 3000.0
  let originalUsed = 1380.0
  let originalSpent = 1380.0
  let originalRecovered = 72800.0
  let originalPending = 87480.0

  let calculateSplitValues = (newBudget: float) => {
    let splitPercentage = newBudget /. originalBudget
    let used = originalUsed *. splitPercentage
    let spent = originalSpent *. splitPercentage
    let recovered = originalRecovered *. splitPercentage
    let pending = originalPending *. splitPercentage
    (used, spent, recovered, pending)
  }

  @react.component
  let make = (~invoices) => {
    let budgetFromStorage = switch getItem(localStorageKey)->Nullable.toOption {
    | Some(value) => value
    | None => defaultBudget
    }

    let budget = budgetFromStorage->Float.fromString->Option.getOr(originalBudget)
    let budgetDisplay = budgetFromStorage->Js.String2.replace("$", "")->Js.String2.trim

    let (used, spent, recovered, pending) = calculateSplitValues(budget)

    let usedDisplay = used->valueFormatter(Amount)
    let spentDisplay = spent->valueFormatter(Amount)
    let recoveredDisplay = recovered->valueFormatter(Volume)
    let pendingDisplay = pending->valueFormatter(Volume)

    let usedPercentage = if budget > 0.0 {
      used /. budget *. 100.0
    } else {
      0.0
    }

    <div
      className="bg-white border border-nd_br_gray-200 rounded-xl p-5 flex flex-col justify-between">
      <div className={`${body.sm.medium} text-nd_gray-500 flex items-center justify-between`}>
        <span> {"Budget for Recovering Decline Invoices"->React.string} </span>
      </div>
      <div className="mt-4">
        <div className={`${body.sm.medium} text-nd_gray-500`}>
          {"Available Budget"->React.string}
        </div>
        <div className={`${heading.xl.bold} my-1`}>
          {"$"->React.string}
          {React.string(budgetDisplay)}
        </div>
        <div className="w-full bg-nd_gray-100 h-1 rounded mt-2">
          <div
            className="bg-nd_purple-300 h-1 rounded"
            style={ReactDOM.Style.make(
              ~width={usedPercentage->Float.toFixedWithPrecision(~digits=1) ++ "%"},
              (),
            )}
          />
        </div>
        <div className={`${body.sm.regular} text-nd_gray-500 mt-2`}>
          {"Budget used for doing Hard Retries: $"->React.string}
          {React.string(usedDisplay)}
        </div>
      </div>
      <div className="border-t border-dashed border-nd_br_gray-200 my-4" />
      <div className={`${body.sm.medium} text-nd_gray-500 mb-1`}>
        {"Hard-Decline Recovery Overview"->React.string}
      </div>
      <div
        className="grid grid-cols-2 gap-4 bg-nd_gray-50 p-4 rounded-xl border border-nd_br_gray-200">
        <div>
          <div className={`${body.lg.semibold}`}>
            {"$"->React.string}
            {React.string(spentDisplay)}
          </div>
          <div className={`${body.xs.regular} text-nd_gray-500`}>
            {"Budget Spent to recover"->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.lg.semibold}`}>
            {"$"->React.string}
            {React.string(recoveredDisplay)}
          </div>
          <div className={`${body.xs.regular} text-nd_gray-500`}>
            {"Recovered Amount"->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.lg.semibold}`}> {React.string(invoices)} </div>
          <div className={`${body.xs.regular} text-nd_gray-500`}>
            {"Invoices Recovered"->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.lg.semibold}`}>
            {"$"->React.string}
            {React.string(pendingDisplay)}
          </div>
          <div className={`${body.xs.regular} text-nd_gray-500`}>
            {"Pending Recovery Amount"->React.string}
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <div className="grid grid-cols-3 gap-4">
    <div className="col-span-2 grid grid-cols-2 gap-4">
      <StatCard
        title="Total Declines invoices" value="121.5K" change="" soft="67.77%" hard="33.33%"
      />
      <StatCard title="Total Recovered invoice" value="66.8K" change="" soft="77%" hard="23%" />
      <StatCard title="Pending Recovery invoices" value="24.3K" change="" soft="82%" hard="18%" />
      <StatCard title="Recovered MRR" value="$ 1.33M" change="" soft="77%" hard="23%" />
    </div>
    <BudgetCard invoices="1 of 4" />
  </div>
}
