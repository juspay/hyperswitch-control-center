type tabView = Compress | Expand
type tab = {
  title: string,
  tabElement?: React.element,
  renderContent: unit => React.element,
  onTabSelection?: unit => unit,
}
@react.component
let make: (
  ~tabs: array<tab>,
  ~initialIndex: int=?,
  ~onTitleClick: int => unit=?,
  ~disabledTab: array<string>=?,
) => React.element
