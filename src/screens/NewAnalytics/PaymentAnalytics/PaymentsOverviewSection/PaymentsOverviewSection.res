module SmartRetryCard = {
  open NewAnalyticsHelper
  open NewAnalyticsUtils
  @react.component
  let make = () => {
    <Card> {"smart retry"->React.string} </Card>
  }
}

module OverViewStat = {
  open NewAnalyticsHelper
  open NewAnalyticsUtils
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
    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto">
        <RenderIf condition={true}>
          <div className="animate-spin self-end absolute">
            <Icon name="spinner" size=16 />
          </div>
        </RenderIf>
        <div className="flex justify-between w-full h-1/2 items-end">
          <div className="font-bold text-4xl w-1/3">
            {valueFormatter(10.0, "Amount")->String.toLowerCase->React.string}
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
