module Tag = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~text: string,
    ~variant: [#noFill | #attentive | #subtle]=?,
    ~color: [#neutral | #primary | #success | #error | #warning | #purple]=?,
    ~size: [#xs | #sm | #md | #lg]=?,
    ~shape: [#rounded | #squarical]=?,
    ~leftSlot: React.element=?,
    ~rightSlot: React.element=?,
    ~splitTagPosition: [#left | #right]=?,
    ~onClick: ReactEvent.Mouse.t => unit=?,
    ~className: string=?,
    ~id: string=?,
  ) => React.element = "Tag"
}

module SplitTag = {
  type tagConfig = {
    text: string,
    variant?: [#noFill | #attentive | #subtle],
    color?: [#neutral | #primary | #success | #error | #warning | #purple],
    leftSlot?: React.element,
    rightSlot?: React.element,
    onClick?: ReactEvent.Mouse.t => unit,
    className?: string,
    id?: string,
  }

  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~primaryTag: tagConfig,
    ~secondaryTag: tagConfig=?,
    ~size: [#xs | #sm | #md | #lg]=?,
    ~shape: [#rounded | #squarical]=?,
  ) => React.element = "SplitTag"
}
