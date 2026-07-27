@react.component
let make: (
  ~authorization: CommonAuthTypes.authorization,
  ~noAccessDescription: string=?,
  ~description: string=?,
  ~descriptionComponent: React.element=?,
  ~toolTipFor: React.element=?,
  ~toolTipPosition: ToolTip.toolTipPosition=?,
  ~hoverOnToolTip: bool=?,
  ~visibleOnClick: bool=?,
  ~enableTooltipDelay: bool=?,
  ~tooltipDelay: int=?,
) => React.element
