open ToolTip

@react.component
let make = (
  ~access,
  ~noAccessDescription=HSwitchUtils.noAccessControlText,
  ~description="",
  ~descriptionComponent=React.null,
  ~tooltipPositioning: tooltipPositioning=#fixed,
  ~toolTipFor=?,
  ~tooltipWidthClass="w-fit",
  ~tooltipForWidthClass="",
  ~toolTipPosition: option<toolTipPosition>=?,
  ~customStyle="",
  ~arrowCustomStyle="",
  ~textStyleGap="",
  ~arrowBgClass="",
  ~bgColor="",
  ~contentAlign: contentPosition=Middle,
  ~justifyClass="justify-center",
  ~flexClass="flex-col",
  ~height="h-full",
  ~textStyle="text-fs-11",
  ~hoverOnToolTip=false,
  ~tooltipArrowSize=5,
  ~visibleOnClick=false,
  ~descriptionComponentClass="flex flex-row-reverse",
  ~isRelative=true,
  ~dismissable=false,
) => {
  let description = access === AuthTypes.Access ? description : noAccessDescription

  <ToolTip
    description
    descriptionComponent
    tooltipPositioning
    ?toolTipFor
    tooltipWidthClass
    tooltipForWidthClass
    ?toolTipPosition
    customStyle
    arrowCustomStyle
    textStyleGap
    arrowBgClass
    bgColor
    contentAlign
    justifyClass
    flexClass
    height
    textStyle
    hoverOnToolTip
    tooltipArrowSize
    visibleOnClick
    descriptionComponentClass
    isRelative
    dismissable
  />
}
