type side =
  | @as("top") Top
  | @as("right") Right
  | @as("left") Left
  | @as("bottom") Bottom

type align =
  | @as("start") Start
  | @as("end") End
  | @as("center") Center

type size =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type slotDirection =
  | @as("left") Leading
  | @as("right") Trailing

@module("@juspay/blend-design-system") @react.component
external make: (
  ~children: React.element,
  ~content: React.element,
  @as("open") ~open_: bool=?,
  ~side: side=?,
  ~align: align=?,
  ~showArrow: bool=?,
  ~size: size=?,
  ~slot: React.element=?,
  ~slotDirection: slotDirection=?,
  ~delayDuration: int=?,
  ~offset: int=?,
  ~maxWidth: string=?,
  ~fullWidth: bool=?,
  ~disableInteractive: bool=?,
  ~onOpenChange: bool => unit=?,
) => React.element = "TooltipV2"
