open Typography

module StackedBarGraph = {
  @react.component
  let make = () => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")

    <div
      className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className={`text-nd_gray-400 ${body.sm.medium}`}> {"Total Orders"->React.string} </p>
      <p className={`text-nd_gray-800 ${heading.lg.semibold}`}> {"2000"->React.string} </p>
      <div className="w-full">
        <StackedBarGraph
          options={StackedBarGraphUtils.getStackedBarGraphOptions(
            ReconEngineTransactionsUtils.getSampleStackedBarGraphData(),
            ~yMax=2000,
            ~labelItemDistance={isMiniLaptopView ? 45 : 90},
          )}
        />
      </div>
    </div>
  }
}
