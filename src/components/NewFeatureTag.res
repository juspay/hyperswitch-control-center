@react.component
let make = (~className="", ~description="") => {
  let hasDescription = description->LogicUtils.isNonEmptyString
  let tag =
    <span className={`inline-flex shrink-0 items-center align-middle ${className}`}>
      <TagBinding text="NEW" color=Primary variant=Subtle shape=Squarical size=Xs />
    </span>
  <>
    <RenderIf condition=hasDescription>
      <ToolTip description toolTipFor=tag toolTipPosition=ToolTip.Top />
    </RenderIf>
    <RenderIf condition={!hasDescription}> tag </RenderIf>
  </>
}
