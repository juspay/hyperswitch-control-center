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
            {
              categories: ["Total Orders"],
              data: [
                {
                  name: "Expected",
                  data: [400.0],
                  color: "#8BC2F3",
                },
                {
                  name: "Mismatch",
                  data: [400.0],
                  color: "#EA8A8F",
                },
                {
                  name: "Posted",
                  data: [1200.0],
                  color: "#7AB891",
                },
              ],
              labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
            },
            ~yMax=2000,
            ~labelItemDistance={isMiniLaptopView ? 45 : 90},
          )}
        />
      </div>
    </div>
  }
}
