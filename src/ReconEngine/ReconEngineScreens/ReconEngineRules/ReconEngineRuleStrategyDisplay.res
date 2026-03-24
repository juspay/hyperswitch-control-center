open Typography
open ReconEngineRulesTypes

type strategyInfo = {
  key: string,
  title: string,
  shortLabel: string,
  description: string,
  icon: string,
}

let allStrategies: array<strategyInfo> = [
  {
    key: "one_to_one_single_single",
    title: "1:1 Single-Single",
    shortLabel: "1:1 SS",
    description: "One source entry matches one target entry. Simplest matching.",
    icon: "nd-arrow-right",
  },
  {
    key: "one_to_one_single_many",
    title: "1:1 Single-Many",
    shortLabel: "1:1 SM",
    description: "One source entry matches multiple target entries in the same account.",
    icon: "nd-arrow-right",
  },
  {
    key: "one_to_one_many_single",
    title: "1:1 Many-Single",
    shortLabel: "1:1 MS",
    description: "Multiple grouped source entries match one target entry.",
    icon: "nd-arrow-right",
  },
  {
    key: "one_to_one_many_many",
    title: "1:1 Many-Many",
    shortLabel: "1:1 MM",
    description: "Multiple grouped source entries match multiple target entries.",
    icon: "nd-arrow-right",
  },
  {
    key: "one_to_many_single_single",
    title: "1:N Single-Single",
    shortLabel: "1:N SS",
    description: "One source entry splits across multiple target accounts by percentage or fixed amount.",
    icon: "nd-arrow-right",
  },
]

let getActiveStrategyKey = (strategy: reconStrategyType): string => {
  switch strategy {
  | OneToOne(SingleSingle(_)) => "one_to_one_single_single"
  | OneToOne(SingleMany(_)) => "one_to_one_single_many"
  | OneToOne(ManySingle(_)) => "one_to_one_many_single"
  | OneToOne(ManyMany(_)) => "one_to_one_many_many"
  | OneToMany(SingleSingle(_)) => "one_to_many_single_single"
  | _ => ""
  }
}

module StrategyCard = {
  @react.component
  let make = (~strategy: strategyInfo, ~isActive: bool) => {
    let borderClass = isActive
      ? "border-nd_primary_blue-400 bg-nd_primary_blue-50"
      : "border-nd_gray-150 bg-white"
    let labelClass = isActive
      ? "bg-nd_primary_blue-100 text-nd_primary_blue-700"
      : "bg-nd_gray-100 text-nd_gray-600"

    <div
      className={`flex flex-col gap-2 p-4 border rounded-xl transition-colors ${borderClass}`}>
      <div className="flex flex-row items-center justify-between">
        <span
          className={`px-2 py-1 rounded-md ${body.sm.semibold} ${labelClass}`}>
          {strategy.shortLabel->React.string}
        </span>
        <RenderIf condition={isActive}>
          <Icon name="nd-check-circle" size=16 className="text-nd_primary_blue-500" />
        </RenderIf>
      </div>
      <p className={`${body.md.semibold} text-nd_gray-800`}> {strategy.title->React.string} </p>
      <p className={`${body.sm.medium} text-nd_gray-500`}>
        {strategy.description->React.string}
      </p>
    </div>
  }
}

@react.component
let make = (~activeStrategy: reconStrategyType) => {
  let activeKey = getActiveStrategyKey(activeStrategy)

  <div className="border border-nd_gray-150 rounded-xl p-5 bg-white">
    <div className="flex flex-col gap-1 mb-4">
      <p className={`${body.lg.semibold} text-nd_gray-800`}>
        {"Reconciliation Strategy"->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-400`}>
        {"The matching strategy defines how source entries are matched to target entries"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
      {allStrategies
      ->Array.map(strategy => {
        <StrategyCard key={strategy.key} strategy isActive={strategy.key === activeKey} />
      })
      ->React.array}
    </div>
  </div>
}
