module TabSwitch = {
  @react.component
  let make = (~viewType: ReconEngineOverviewSummaryTypes.viewType, ~setViewType) => {
    open ReconEngineOverviewSummaryTypes

    // Icons and styling change based on current viewType
    let (icon1Bg, icon1Shadow, icon1Color, icon1Name) = switch viewType {
    | Graph => ("bg-white", "shadow-sm", "text-gray-700", "graph-outline")
    | Table => ("bg-transparent", "", "text-gray-500", "graph-outline")
    }

    let (icon2Bg, icon2Shadow, icon2Color, icon2Name) = switch viewType {
    | Graph => ("bg-transparent", "", "text-gray-500", "grid-table")
    | Table => ("bg-white", "shadow-sm", "text-gray-700", "grid-table")
    }

    <div className="bg-gray-100 p-1 rounded-xl flex flex-row gap-2 w-fit mt-2">
      <div
        className={`rounded-lg px-3 py-2.5 transition-all duration-200 cursor-pointer ${icon1Bg} ${icon1Shadow}`}
        onClick={_ => setViewType(_ => Graph)}>
        <Icon className={icon1Color} name={icon1Name} size=12 />
      </div>
      <div
        className={`rounded-lg px-3 py-2.5 transition-all duration-200 cursor-pointer ${icon2Bg} ${icon2Shadow}`}
        onClick={_ => setViewType(_ => Table)}>
        <Icon className={icon2Color} name=icon2Name size=12 />
      </div>
    </div>
  }
}
