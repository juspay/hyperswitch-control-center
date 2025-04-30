@react.component
let make = () => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let isProdIntent = isProdIntentCompleted->Option.getOr(false)
  let cursorStyles = isProdIntent ? "cursor-default" : "cursor-pointer"
  let productionAccessString = isProdIntent
    ? "Production Access Requested"
    : "Get Production Access"

  switch isProdIntentCompleted {
  | Some(_) =>
    switch isProdIntent {
    | true =>
      <ToolTip
        description="Production Access Already Requested"
        hoverOnToolTip=false
        iconOpacityVal="0"
        toolTipFor={<div
          className={`flex items-center gap-1 border border-nd_gray-200 hover:bg-nd_gray-25  bg-white text-nd_gray-500  ${cursorStyles} px-3 py-7-px whitespace-nowrap rounded-lg justify-between`}
          onClick={_ => {
            isProdIntent
              ? ()
              : {
                  setShowProdIntentForm(_ => true)
                  mixpanelEvent(~eventName="get_production_access")
                }
          }}>
          <RenderIf condition={isProdIntent}>
            <Icon name="nd-tick-gray" size=22 className="pt-1" />
          </RenderIf>
          <div className={`text-nd_gray-600 text-base !font-semibold`}>
            {productionAccessString->React.string}
          </div>
        </div>}
      />
    | false =>
      <div
        className={`flex items-center gap-1 border hover:bg-nd_orange-150 border-nd_orange-200  bg-nd_orange-50 text-nd_gray-700  ${cursorStyles} px-3 py-7-px whitespace-nowrap rounded-lg justify-between shadow-sm`}
        onClick={_ => {
          isProdIntent
            ? ()
            : {
                setShowProdIntentForm(_ => true)
                mixpanelEvent(~eventName="get_production_access")
              }
        }}>
        <RenderIf condition={!isProdIntent}>
          <Icon name="nd-rocket-ship" size=22 className="pt-1" />
        </RenderIf>
        <div className={`text-nd_orange-500 text-base !font-semibold`}>
          {productionAccessString->React.string}
        </div>
      </div>
    }

  | None =>
    <Shimmer
      styleClass="h-10 px-4 py-3 m-2 ml-2 mb-3 dark:bg-black bg-white rounded" shimmerType={Small}
    />
  }
}
