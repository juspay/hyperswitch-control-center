type tabsVariant =
  | @as("boxed") Boxed
  | @as("floating") Floating
  | @as("underline") Underline
  | @as("pills") Pills

type tabsSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type skeletonVariant = [#pulse | #wave | #shimmer]

@module("@juspay/blend-design-system") @react.component
external make: (
  ~defaultValue: string=?,
  ~value: string=?,
  ~onValueChange: string => unit=?,
  ~variant: tabsVariant=?,
  ~size: tabsSize=?,
  ~className: string=?,
  ~children: React.element=?,
  ~fitContent: bool=?,
  ~expanded: bool=?,
  ~disabled: bool=?,
  ~showSkeleton: bool=?,
  ~skeletonVariant: skeletonVariant=?,
  ~stickyHeader: bool=?,
  ~offsetTop: int=?,
) => React.element = "TabsV2"

module List = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~variant: tabsVariant=?,
    ~size: tabsSize=?,
    ~expanded: bool=?,
    ~fitContent: bool=?,
    ~stickyHeader: bool=?,
    ~offsetTop: int=?,
    ~className: string=?,
    @as("aria-label") ~ariaLabel: string=?,
    ~children: React.element,
  ) => React.element = "TabsV2List"
}

module Trigger = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~value: string,
    ~variant: tabsVariant=?,
    ~size: tabsSize=?,
    ~leftSlot: React.element=?,
    ~rightSlot: React.element=?,
    ~disabled: bool=?,
    ~closable: bool=?,
    ~onClose: unit => unit=?,
    ~showSkeleton: bool=?,
    ~skeletonVariant: skeletonVariant=?,
    ~isOverlay: bool=?,
    ~className: string=?,
    @as("aria-label") ~ariaLabel: string=?,
    ~children: React.element,
  ) => React.element = "TabsV2Trigger"
}

module Content = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~value: string,
    ~forceMount: bool=?,
    ~className: string=?,
    ~children: React.element,
  ) => React.element = "TabsV2Content"
}
