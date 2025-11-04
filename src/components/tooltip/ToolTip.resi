type toolTipPosition = Top | Bottom | Left | Right | TopRight | TopLeft | BottomLeft | BottomRight
type contentPosition = Left | Right | Middle | Default
type toolTipSize = Large | Medium | Small | XSmall
@send external getBoundingClientRect: Dom.element => Window.boundingClient = "getBoundingClientRect"
type tooltipPositioning = [#absolute | #fixed | #static]
let toolTipArrowBorder: int
module TooltipMainWrapper: {
  @react.component
  let make: (
    ~children: React.element,
    ~visibleOnClick: bool,
    ~hoverOnToolTip: bool,
    ~setIsToolTipVisible: ('a => bool) => unit,
    ~isRelative: bool,
    ~flexClass: string,
    ~height: string,
    ~contentAlign: contentPosition,
    ~justifyClass: string,
    ~tooltipDelay: int=?,
    ~enableTooltipDelay: bool=?,
  ) => React.element
}
module TooltipWrapper: {
  let getToolTipFixedStyling: (
    ~hoverOnToolTip: bool,
    ~positionX: int,
    ~positionY: int,
    ~tooltipWidth: int,
    ~tooltipHeight: int,
    ~tooltipArrowSize: int,
    ~componentWidth: int,
    ~componentHeight: int,
    ~position: toolTipPosition,
  ) => ReactDOMStyle.t
  let getToolTipAbsoluteStyling: (
    ~tooltipArrowHeight: float,
    ~tooltipHeightFloat: float,
    ~tooltipArrowWidth: int,
    ~tooltipWidth: int,
    ~componentWidth: int,
    ~componentHeight: int,
    ~position: toolTipPosition,
  ) => ReactDOMStyle.t
  @react.component
  let make: (
    ~isToolTipVisible: bool,
    ~descriptionComponent: React.element,
    ~description: string,
    ~hoverOnToolTip: bool,
    ~tooltipPositioning: tooltipPositioning,
    ~tooltipWidthClass: string,
    ~toolTipRef: ReactDOM.Ref.currentDomRef,
    ~textStyle: string,
    ~bgColor: string,
    ~customStyle: string,
    ~positionX: int,
    ~positionY: int,
    ~tooltipArrowHeight: float,
    ~tooltipHeightFloat: float,
    ~tooltipArrowWidth: int,
    ~tooltipWidth: int,
    ~tooltipHeight: int,
    ~tooltipArrowSize: int,
    ~componentWidth: int,
    ~componentHeight: int,
    ~toolTipPosition: option<toolTipPosition>,
    ~defaultPosition: toolTipPosition,
    ~children: React.element,
  ) => React.element
}
module DescriptionSection: {
  @react.component
  let make: (
    ~description: string,
    ~descriptionComponent: React.element,
    ~textStyleGap: string,
    ~descriptionComponentClass: string,
    ~setIsToolTipVisible: (bool => bool) => unit,
    ~dismissable: bool,
  ) => React.element
}
module TooltipFor: {
  @react.component
  let make: (
    ~toolTipFor: option<React.element>,
    ~tooltipForWidthClass: string,
    ~componentRef: ReactDOM.Ref.currentDomRef,
    ~opacityVal: string=?,
  ) => React.element
}
module Arrow: {
  let getArrowFixedPosition: (
    ~hoverOnToolTip: bool,
    ~positionX: int,
    ~positionY: int,
    ~tooltipArrowSize: int,
    ~componentWidth: int,
    ~componentHeight: int,
    ~arrowColor: string,
    ~position: toolTipPosition,
  ) => ReactDOMStyle.t
  let getArrowAbsolutePosition: (
    ~tooltipArrowWidth: int,
    ~tooltipArrowHeight: float,
    ~tooltipHeightFloat: float,
    ~tooltipWidth: int,
    ~arrowColor: string,
    ~position: toolTipPosition,
  ) => ReactDOMStyle.t
  @react.component
  let make: (
    ~toolTipArrowRef: ReactDOM.Ref.currentDomRef,
    ~arrowCustomStyle: string,
    ~tooltipPositioning: tooltipPositioning,
    ~toolTipPosition: option<toolTipPosition>,
    ~hoverOnToolTip: bool,
    ~positionX: int,
    ~positionY: int,
    ~tooltipArrowWidth: int,
    ~tooltipArrowHeight: float,
    ~tooltipHeightFloat: float,
    ~tooltipArrowSize: int,
    ~tooltipWidth: int,
    ~componentWidth: int,
    ~componentHeight: int,
    ~bgColor: string,
    ~arrowBgClass: string,
    ~defaultPosition: toolTipPosition,
  ) => React.element
}
let getDefaultPosition: (
  ~positionX: int,
  ~positionY: int,
  ~componentWidth: int,
  ~componentHeight: int,
  ~tooltipWidth: int,
  ~tooltipHeight: int,
) => toolTipPosition
@react.component
let make: (
  ~description: string=?,
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
  ~newDesign: bool=?,
  ~iconOpacityVal: string=?,
  ~enableTooltipDelay: bool=?,
  ~tooltipDelay: int=?,
) => React.element
