type breadcrumbItemType = {
  label: string,
  href: string,
  onClick?: ReactEvent.Mouse.t => unit,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~items: array<breadcrumbItemType>,
) => React.element = "Breadcrumb"
