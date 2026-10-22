type breadcrumbV2ItemType = {
  id?: string,
  label: string,
  href: string,
  leftSlot?: React.element,
  rightSlot?: React.element,
  onClick?: ReactEvent.Mouse.t => unit,
}

@module("@juspay/blend-design-system") @react.component
external make: (~items: array<breadcrumbV2ItemType>, ~maxItems: int=?) => React.element =
  "BreadcrumbV2"
