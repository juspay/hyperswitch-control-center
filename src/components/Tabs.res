type tab = {
  title: string,
  tabElement?: React.element,
  renderContent: unit => React.element,
  onTabSelection?: unit => unit,
}

@react.component
let make = (
  ~tabs,
  ~initialIndex=?,
  ~onTitleClick=?,
  ~disabledTab=[],
  ~variant=TabsBinding.Underline,
  ~size=TabsBinding.Lg,
  ~fitContent=?,
) => {
  let initialIndex = initialIndex->Option.getOr(0)
  let (selectedValue, setSelectedValue) = React.useState(() => initialIndex->Int.toString)

  React.useEffect(() => {
    setSelectedValue(_ => initialIndex->Int.toString)
    None
  }, [initialIndex])

  let handleValueChange = (newValue: string) => {
    setSelectedValue(_ => newValue)
    let idx = newValue->LogicUtils.getIntFromString(0)
    onTitleClick->Option.forEach(fn => fn(idx))
    tabs
    ->Array.get(idx)
    ->Option.forEach(tab => tab.onTabSelection->Option.forEach(fn => fn()))
  }

  let items = React.useMemo(() => {
    tabs->Array.mapWithIndex((tab, i) => {
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
  }, (tabs, disabledTab))

  <ErrorBoundary>
    <TabsBinding
      value={selectedValue} onValueChange={handleValueChange} variant size ?fitContent items
    />
  </ErrorBoundary>
}
