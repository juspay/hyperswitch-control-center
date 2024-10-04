module SmartRetryCard = {
  open NewAnalyticsHelper
  open NewAnalyticsUtils
  @react.component
  let make = () => {
    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto">
        <div className="font-semibold  dark:text-white">
          {"Total Payment Savings"->React.string}
        </div>
        <div className={"flex flex-col gap-1 justify-center  text-black h-full"}>
          <div className="font-semibold  text-2xl dark:text-white">
            {"Saved 2.3K USD"->React.string}
          </div>
          <div className="opacity-50 text-sm">
            {"Amount saved via payment retries"->React.string}
          </div>
        </div>
      </div>
    </Card>
  }
}

module OverViewStat = {
  open NewAnalyticsHelper
  open NewAnalyticsUtils
  open NewPaymentAnalyticsUtils
  @react.component
  let make = () => {
    /*
      <ToolTip
              description="Overall successful payment intents divided by total payment intents excluding dropoffs"
              toolTipFor={"..."->React.string}
              toolTipPosition=ToolTip.Top
              newDesign=true
            />
 */

    let (value, direction) = calculatePercentageChange(~primaryValue=100.0, ~secondaryValue=200.0)

    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto relative">
        <RenderIf condition={true}>
          <div className="animate-spin self-end absolute">
            <Icon name="spinner" size=16 />
          </div>
        </RenderIf>
        <div className="flex justify-between w-full items-end">
          <div className="flex gap-1 items-center">
            <div className="font-bold text-3xl">
              {valueFormatter(100000.0, "Amount")->String.toLowerCase->React.string}
            </div>
            <div className="scale-[0.9]">
              <StatisticsCard value direction />
            </div>
          </div>
        </div>
        <div className={"flex flex-col gap-1  text-black"}>
          <div className="font-semibold  dark:text-white">
            {"Total Authorization Rate"->React.string}
          </div>
          <div className="opacity-50 text-sm">
            {"Overall successful payment intents divided by total payment intents excluding dropoffs"->React.string}
          </div>
        </div>
      </div>
    </Card>
  }
}

@react.component
let make = () => {
  <div className="grid grid-cols-3 gap-3">
    <SmartRetryCard />
    <div className="col-span-2 grid grid-cols-2 grid-rows-2 gap-3">
      <OverViewStat />
      <OverViewStat />
      <OverViewStat />
      <OverViewStat />
    </div>
  </div>
}
