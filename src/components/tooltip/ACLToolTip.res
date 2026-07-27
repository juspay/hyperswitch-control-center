open ToolTip

@react.component
let make = (
  ~authorization,
  ~noAccessDescription=HSwitchUtils.noAccessControlText,
  ~description="",
  ~descriptionComponent=React.null,
  ~toolTipFor=?,
  ~toolTipPosition: option<toolTipPosition>=?,
  ~hoverOnToolTip=false,
  ~visibleOnClick=false,
  ~enableTooltipDelay=false,
  ~tooltipDelay: option<int>=?,
) => {
  let description = authorization === CommonAuthTypes.Access ? description : noAccessDescription

  <ToolTip
    description
    descriptionComponent
    ?toolTipFor
    ?toolTipPosition
    hoverOnToolTip
    visibleOnClick
    enableTooltipDelay
    ?tooltipDelay
  />
}
