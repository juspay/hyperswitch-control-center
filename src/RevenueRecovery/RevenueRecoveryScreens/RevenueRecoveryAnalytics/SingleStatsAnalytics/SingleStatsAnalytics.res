module StatCard = {
  open Typography

  @react.component
  let make = (~title, ~value, ~change, ~soft, ~hard, ~invoiceCount="") => {
    <div className="bg-white border-1.5 border-nd_gray-150 rounded-xl p-5 flex-1">
      <div className="flex items-center justify-between">
        <span className={`${body.md.medium} text-nd_gray-400`}> {React.string(title)} </span>
      </div>
      <div className={`mt-2 ${heading.lg.semibold} flex items-center`}>
        {React.string(value)}
        <span className={`ml-2 ${body.md.medium} text-nd_green-400`}> {React.string(change)} </span>
      </div>
      <div className="flex justify-between w-full">
        <span className={`${body.sm.semibold} text-nd_gray-400 `}>
          {"Last month"->React.string}
        </span>
        <span className={`${body.sm.semibold} text-nd_gray-400 `}>
          {invoiceCount->React.string}
        </span>
      </div>
      <div className="border-t-1.5 border-dashed border-nd_br_gray-200 my-3" />
      <div className={`mt-4 ${body.xs.regular} text-nd_gray-400`}>
        <span className={body.sm.semibold}> {"Decline Breakdown:"->React.string} </span>
        <div className="mt-2 flex gap-4 text-nd_gray-500">
          <span>
            <span className={body.sm.semibold}> {"Soft : "->React.string} </span>
            {React.string(soft)}
          </span>
          <span>
            <span className={body.sm.semibold}> {"Hard : "->React.string} </span>
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
  open SingleStatsAnalyticsUtils

  let localStorageKey = "hard_decline_budget"
  let defaultBudget = "1600"

  @react.component
  let make = (~invoices) => {
    let budgetFromStorage = switch getItem(localStorageKey)->Nullable.toOption {
    | Some(value) => value
    | None => defaultBudget
    }

    let budget = budgetFromStorage->Float.fromString->Option.getOr(originalBudget)
    let budgetDisplay = budgetFromStorage->String.replace("$", "")->String.trim

    let (used, spent, recovered, pending) = React.useMemo(() => {
      calculateSplitValues(budget)
    }, [budget])

    let usedDisplay = used->valueFormatter(Amount)
    let spentDisplay = spent->valueFormatter(Amount)
    let recoveredDisplay = recovered->valueFormatter(Volume)
    let pendingDisplay = pending->valueFormatter(Volume)

    <div
      className="bg-white border border-nd_br_gray-200 rounded-xl p-5 flex flex-col justify-between">
      <div className={`${body.md.medium} text-nd_gray-400 flex items-center justify-between`}>
        <span> {"Budget for Recovering Decline Invoices"->React.string} </span>
      </div>
      <div className="mt-4">
        <div className={`${body.md.medium} text-nd_gray-400`}>
          {"Available Budget"->React.string}
        </div>
        <div className={`${heading.lg.bold} my-1`}>
          {"$"->React.string}
          {React.string(budgetDisplay)}
        </div>
        <div className="w-full bg-nd_gray-100 h-1 rounded mt-2">
          <div
            className="bg-nd_purple-150 h-1 rounded"
            style={ReactDOM.Style.make(
              ~width={usedPercentage(budget, used)->Float.toFixedWithPrecision(~digits=1) ++ "%"},
              (),
            )}
          />
        </div>
        <div className={`${body.sm.regular} text-nd_gray-500 mt-2`}>
          {"Used so far:: $"->React.string}
          <span className=body.sm.semibold> {React.string(usedDisplay)} </span>
        </div>
      </div>
      <div className="border-t-1.5 border-dashed border-nd_gray-200 my-2" />
      <div className={`${body.sm.medium} text-nd_gray-400`}>
        {"Hard-Decline Recovery Overview"->React.string}
      </div>
      <div
        className="grid grid-cols-2 gap-5 bg-nd_gray-25 p-3 rounded-xl border border-nd_br_gray-200">
        <div>
          <div className={`${body.lg.semibold}`}>
            {"$"->React.string}
            {React.string(spentDisplay)}
          </div>
          <div className={`${body.sm.regular} text-nd_gray-400 mt-1`}>
            {"Budget Spent to recover"->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.lg.semibold}`}>
            {"$"->React.string}
            {React.string(recoveredDisplay)}
          </div>
          <div className={`${body.sm.regular} text-nd_gray-400 mt-1`}>
            {"Recovered Amount"->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.lg.semibold}`}> {React.string(invoices)} </div>
          <div className={`${body.sm.regular} text-nd_gray-400 mt-1`}>
            {"Invoices Recovered"->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.lg.semibold}`}>
            {"$"->React.string}
            {React.string(pendingDisplay)}
          </div>
          <div className={`${body.sm.regular} text-nd_gray-400 mt-1`}>
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
        title="Total Declines invoices"
        value="121.5K"
        change="↑ 3.45%"
        soft="67.77%"
        hard="33.33%"
      />
      <StatCard
        title="Total Recovered invoice" value="66.8K" change="↑ 3.45%" soft="77%" hard="23%"
      />
      <StatCard title="Pending Recovery invoices" value="24.3K" change="" soft="82%" hard="18%" />
      <StatCard
        title="Recovered MRR"
        value="$ 1.33M"
        change=""
        soft="77%"
        hard="23%"
        invoiceCount="1.78K Invoices"
      />
    </div>
    <BudgetCard invoices="1 of 4" />
  </div>
}
