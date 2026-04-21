type toolTipPosition = Top | Bottom | Left | Right | TopRight | TopLeft | BottomLeft | BottomRight

@react.component
let make: (
  ~description: string=?,
  ~descriptionComponent: React.element=?,
  ~toolTipFor: React.element=?,
  ~toolTipPosition: toolTipPosition=?,
  ~hoverOnToolTip: bool=?,
  ~visibleOnClick: bool=?,
  ~enableTooltipDelay: bool=?,
  ~tooltipDelay: int=?,
) => React.element
