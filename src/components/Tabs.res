type tabView = Compress | Expand

type tab = {
  title: string,
  tabElement?: React.element,
  renderContent: unit => React.element,
  onTabSelection?: unit => unit,
}

@react.component
let make = (~tabs: array<tab>, ~initialIndex=?, ~onTitleClick=?, ~disabledTab=[]) => {
  let initialIndex = initialIndex->Option.getOr(0)
  let (selectedValue, setSelectedValue) = React.useState(() => initialIndex->Int.toString)

  React.useEffect(() => {
    setSelectedValue(_ => initialIndex->Int.toString)
    None
  }, [initialIndex])

  let handleValueChange = (newValue: string) => {
    setSelectedValue(_ => newValue)
    let idx = newValue->Int.fromString->Option.getOr(0)
    onTitleClick->Option.forEach(fn => fn(idx))
    tabs
    ->Array.get(idx)
    ->Option.forEach(tab => tab.onTabSelection->Option.forEach(fn => fn()))
  }

  let items: array<TabsBinding.tabItem> = tabs->Array.mapWithIndex((tab, i) => {
    let base: TabsBinding.tabItem = {
      value: i->Int.toString,
      label: tab.title,
      content: tab.renderContent(),
      disable: disabledTab->Array.includes(tab.title),
    }
    switch tab.tabElement {
    | Some(elem) => {...base, leftSlot: elem}
    | None => base
    }
  })

  <ErrorBoundary>
    <TabsBinding
      value={selectedValue}
      onValueChange={handleValueChange}
      variant=TabsBinding.Underline
      size=TabsBinding.Lg
      items
    />
  </ErrorBoundary>
}
