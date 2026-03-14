// Blend Design System - ReScript Bindings
// https://blend.juspay.design/docs/components/tooltip/

module Tooltip = {
  type tooltipSide = [#TOP | #RIGHT | #LEFT | #BOTTOM]
  type tooltipAlign = [#START | #END | #CENTER]
  type tooltipSize = [#SMALL | #LARGE]
  type tooltipSlotDirection = [#LEFT | #RIGHT]

  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~children: React.element,
    ~content: React.element=?,
    ~side: tooltipSide=?,
    ~align: tooltipAlign=?,
    ~showArrow: bool=?,
    ~size: tooltipSize=?,
    ~slot: React.element=?,
    ~slotDirection: tooltipSlotDirection=?,
    ~delayDuration: int=?,
    ~offset: int=?,
    ~open_: bool=?,
    ~maxWidth: string=?,
    ~fullWidth: bool=?,
    ~disableInteractive: bool=?,
  ) => React.element = "Tooltip"
}

// Re-export types for convenience
module TooltipTypes = {
  type side = Tooltip.tooltipSide
  type align = Tooltip.tooltipAlign
  type size = Tooltip.tooltipSize
  type slotDirection = Tooltip.tooltipSlotDirection
}
