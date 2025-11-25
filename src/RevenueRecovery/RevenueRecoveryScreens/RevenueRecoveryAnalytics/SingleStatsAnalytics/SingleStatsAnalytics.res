module StatCard = {
  @react.component
  let make = (~title, ~value, ~change, ~soft, ~hard) => {
    <div className="bg-white border border-nd_br_gray-200 rounded-xl p-5 flex-1">
      <div className="flex items-center justify-between">
        <span className="text-nd_gray-500 font-medium text-sm"> {React.string(title)} </span>
      </div>
      <div className="mt-2 text-3xl font-medium flex items-center">
        {React.string(value)}
        <span className="ml-2 text-nd_green-400 text-base font-medium">
          {React.string(change)}
        </span>
      </div>
      <div className="border-t border-dashed border-nd_br_gray-200 my-2" />
      <div className="mt-4 text-xs text-nd_gray-500">
        <span className="font-semibold "> {"Decline Breakdown:"->React.string} </span>
        <div className="mt-2 flex gap-4">
          <span>
            <b> {"Soft : "->React.string} </b>
            {React.string(soft)}
          </span>
          <span>
            <b> {"Hard : "->React.string} </b>
            {React.string(hard)}
          </span>
        </div>
      </div>
    </div>
  }
}

module BudgetCard = {
  @react.component
  let make = (~budget, ~used, ~spent, ~recovered, ~pending, ~invoices) => {
    <div
      className="bg-white border border-nd_br_gray-200 rounded-xl p-5 flex flex-col justify-between">
      <div className="text-nd_gray-500 text-sm font-medium flex items-center justify-between">
        <span> {"Budget for Recovering Decline Invoices"->React.string} </span>
      </div>
      <div className="mt-4">
        <div className="text-nd_gray-500 text-sm"> {"Available Budget"->React.string} </div>
        <div className="text-3xl font-bold my-1">
          {"$"->React.string}
          {React.string(budget)}
        </div>
        <div className="w-full bg-nd_gray-100 h-1 rounded mt-2">
          <div
            className="bg-nd_purple-300 h-1 rounded" style={ReactDOM.Style.make(~width="33%", ())}
          />
        </div>
        <div className="text-xs text-nd_gray-500 mt-2">
          {"Budget used for doing Hard Retries: $"->React.string}
          {React.string(used)}
        </div>
      </div>
      <div className="border-t border-dashed border-nd_br_gray-200 my-4" />
      <div className="text-sm text-nd_gray-500 font-medium mb-1">
        {"Hard-Decline Recovery Overview"->React.string}
      </div>
      <div
        className="grid grid-cols-2 gap-4 bg-nd_gray-50 p-4 rounded-xl border border-nd_br_gray-200">
        <div>
          <div className="text-lg font-medium">
            {"$"->React.string}
            {React.string(spent)}
          </div>
          <div className="text-xs text-nd_gray-500">
            {"Budget Spent to recover"->React.string}
          </div>
        </div>
        <div>
          <div className="text-lg font-medium">
            {"$"->React.string}
            {React.string(recovered)}
          </div>
          <div className="text-xs text-nd_gray-500"> {"Recovered Amount"->React.string} </div>
        </div>
        <div>
          <div className="text-lg font-medium"> {React.string(invoices)} </div>
          <div className="text-xs text-nd_gray-500"> {"Invoices Recovered"->React.string} </div>
        </div>
        <div>
          <div className="text-lg font-medium">
            {"$"->React.string}
            {React.string(pending)}
          </div>
          <div className="text-xs text-nd_gray-500">
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
    <BudgetCard
      budget="1600" used="736" spent="736" recovered="38K" pending="46K" invoices="1 of 4"
    />
  </div>
}
