type tabsVariant =
  | @as("boxed") Boxed
  | @as("floating") Floating
  | @as("underline") Underline

type tabsSize =
  | @as("md") Md
  | @as("lg") Lg

type skeletonVariant = [#pulse | #wave | #shimmer]

type tabItem = {
  value: string,
  label: string,
  content: React.element,
  closable?: bool,
  isDefault?: bool,
  disable?: bool,
  showSkeleton?: bool,
  skeletonVariant?: skeletonVariant,
  leftSlot?: React.element,
  rightSlot?: React.element,
  newItem?: bool,
  stickyHeader?: bool,
  offsetTop?: int,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~defaultValue: string=?,
  ~value: string=?,
  ~onValueChange: string => unit=?,
  ~variant: tabsVariant=?,
  ~size: tabsSize=?,
  ~className: string=?,
  ~children: React.element=?,
  ~items: array<tabItem>=?,
  ~fitContent: bool=?,
  ~onTabClose: string => unit=?,
  ~stickyHeader: bool=?,
  ~offsetTop: int=?,
) => React.element = "Tabs"

module List = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~variant: tabsVariant=?,
    ~size: tabsSize=?,
    ~expanded: bool=?,
    ~fitContent: bool=?,
    ~className: string=?,
    ~children: React.element,
  ) => React.element = "TabsList"
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
    ~isOverlay: bool=?,
    ~className: string=?,
    @as("aria-label") ~ariaLabel: string=?,
    ~children: React.element,
  ) => React.element = "TabsTrigger"
}

module Content = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~value: string,
    ~forceMount: bool=?,
    ~className: string=?,
    ~children: React.element,
  ) => React.element = "TabsContent"
}
