@react.component
let make = (~className="", ~description="") => {
  let tag =
    <span className={`inline-flex shrink-0 items-center align-middle ${className}`}>
      <TagBinding text="NEW" color=Primary variant=Subtle shape=Squarical size=Xs />
    </span>
  description->LogicUtils.isNonEmptyString
    ? <ToolTip description toolTipFor=tag toolTipPosition=ToolTip.Top />
    : tag
}
