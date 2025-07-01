type reason = {
  label: string,
  value: float,
  color: string, // Tailwind color class or hex
}

module DonutChart = {
  @react.component
  let make = (~data: array<reason>) => {
    let total = data->Belt.Array.reduce(0.0, (acc, r) => acc +. r.value)
    let radius = 48.0
    let circumference = 2.0 *. 3.14 *. radius
    let offset = ref(0.0)

    <svg width="120" height="120" viewBox="0 0 120 120" className="block mx-auto">
      {data
      ->Belt.Array.mapWithIndex((i, r) => {
        let dash = circumference *. (r.value /. total)
        let dashArray = Js.Float.toString(dash) ++ " " ++ Js.Float.toString(circumference -. dash)
        let el =
          <circle
            key={i->Js.Int.toString}
            cx="60"
            cy="60"
            r={radius->Js.Float.toString}
            fill="none"
            stroke={r.color}
            strokeWidth="16"
            strokeDasharray={dashArray}
            strokeDashoffset={offset.contents->Js.Float.toString}
            style={ReactDOM.Style.make(~transition="stroke-dashoffset 0.3s", ())}
          />
        offset := offset.contents -. dash
        el
      })
      ->React.array}
    </svg>
  }
}

module FailureReasonsBreakDown = {
  @react.component
  let make = () => {
    let reasons = [
      {label: "Insufficient Balance", value: 5.88, color: "#FFE0B2"},
      {label: "Do not Honor", value: 4.76, color: "#FFCDD2"},
      {label: "Restricted Card", value: 8.88, color: "#CE93D8"},
      {label: "Invalid Card Number", value: 56.90, color: "#80DEEA"},
      {label: "Others", value: 16.88, color: "#B0BEC5"},
    ]

    <div className="flex items-center p-5">
      <DonutChart data=reasons />
      <div className="ml-8 space-y-3">
        {reasons
        ->Belt.Array.map(r =>
          <div className="flex items-center space-x-3">
            <span
              className="w-3 h-3 rounded-full inline-block"
              style={ReactDOM.Style.make(~background=r.color, ())}
            />
            <span className="text-gray-500 text-sm"> {React.string(r.label)} </span>
            <span className="text-gray-400 text-sm ml-2">
              {React.string(r.value->Float.toString ++ "%")}
            </span>
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <div>
    <div className="space-y-1 mb-5">
      <h2 className="text-xl font-semibold text-gray-900"> {"Failure Breakdown"->React.string} </h2>
      <p className="text-gray-500">
        {"Static Retries are executed based on predefined rules, whereas Smart Retries are dynamically triggered"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-2 gap-10">
      <div className="rounded-xl border border-gray-200 w-full bg-white">
        <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
          <h2 className="font-medium text-gray-800"> {"Top Reasons for failure"->React.string} </h2>
        </div>
        <div className="p-4">
          <FailureReasonsBreakDown />
        </div>
      </div>
    </div>
  </div>
}
