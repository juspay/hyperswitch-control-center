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

module PlaceHolder = {
  @react.component
  let make = () => {
    <div className="rounded-xl border border-gray-200 w-full bg-white">
      <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
        <h2 className="font-medium text-gray-800">
          {"Recovery leakage breakdown"->React.string}
        </h2>
      </div>
      <div className="p-4">
        <div className="flex items-center mb-6 space-x-6 text-sm">
          <div className="flex items-center space-x-1">
            <span className="w-3 h-3 rounded bg-blue-400 inline-block" />
            <span> {"Recovered"->React.string} </span>
          </div>
          <div className="flex items-center space-x-1">
            <span className="w-3 h-3 rounded bg-orange-200 inline-block" />
            <span> {"In schedule"->React.string} </span>
          </div>
          <div className="flex items-center space-x-1">
            <span className="w-3 h-3 rounded bg-gray-300 inline-block" />
            <span> {"Cancelled"->React.string} </span>
          </div>
        </div>
        <div className="relative space-y-8">
          <div className="flex items-center space-x-4">
            <div className="w-24 text-gray-500 text-sm"> {"Processor"->React.string} </div>
            <div className="w-72 h-4 bg-gray-100 rounded-full flex overflow-hidden">
              <div className="bg-blue-400 h-full" style={ReactDOM.Style.make(~width="63%", ())} />
              <div className="bg-orange-200 h-full" style={ReactDOM.Style.make(~width="27%", ())} />
              <div className="bg-gray-300 h-full" style={ReactDOM.Style.make(~width="10%", ())} />
            </div>
            <div className="ml-2 text-gray-500 text-sm"> {"57%"->React.string} </div>
          </div>
          <div className="flex items-center space-x-4">
            <div className="w-24 text-gray-500 text-sm"> {"Network"->React.string} </div>
            <div className="w-72 h-4 bg-gray-100 rounded-full flex overflow-hidden">
              <div className="bg-blue-400 h-full" style={ReactDOM.Style.make(~width="0%", ())} />
              <div className="bg-orange-200 h-full" style={ReactDOM.Style.make(~width="0%", ())} />
              <div className="bg-gray-300 h-full" style={ReactDOM.Style.make(~width="24%", ())} />
            </div>
            <div className="ml-2 text-gray-500 text-sm"> {"24%"->React.string} </div>
          </div>
          <div className="flex items-center space-x-4">
            <div className="w-24 text-gray-500 text-sm"> {"Issuer"->React.string} </div>
            <div className="w-72 h-4 bg-gray-100 rounded-full flex overflow-hidden">
              <div className="bg-blue-400 h-full" style={ReactDOM.Style.make(~width="19%", ())} />
              <div className="bg-orange-200 h-full" style={ReactDOM.Style.make(~width="0%", ())} />
              <div className="bg-gray-300 h-full" style={ReactDOM.Style.make(~width="0%", ())} />
            </div>
            <div className="ml-2 text-gray-500 text-sm"> {"19%"->React.string} </div>
          </div>
        </div>
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
      <PlaceHolder />
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
