type toolTipPosition = Top | Bottom | Left | Right | TopRight | TopLeft | BottomLeft | BottomRight
type contentPosition = Left | Right | Middle | Default
type toolTipSize = Large | Medium | Small | XSmall

type tooltipPositioning = [#absolute | #fixed | #static]
@react.component
let make: (
  ~description: Js.String2.t=?,
  ~descriptionComponent: React.element=?,
  ~tooltipPositioning: tooltipPositioning=?,
  ~toolTipFor: React.element=?,
  ~tooltipWidthClass: string=?,
  ~tooltipForWidthClass: string=?,
  ~toolTipPosition: toolTipPosition=?,
  ~customStyle: string=?,
  ~arrowCustomStyle: string=?,
  ~textStyleGap: string=?,
  ~arrowBgClass: string=?,
  ~bgColor: string=?,
  ~contentAlign: contentPosition=?,
  ~justifyClass: string=?,
  ~flexClass: string=?,
  ~height: string=?,
  ~textStyle: string=?,
  ~hoverOnToolTip: bool=?,
  ~tooltipArrowSize: int=?,
  ~visibleOnClick: bool=?,
  ~descriptionComponentClass: string=?,
  ~isRelative: bool=?,
  ~dismissable: bool=?,
) => React.element
