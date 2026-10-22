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
  ~ariaLabel="Sections",
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

  <ErrorBoundary>
    // Preserve the V1 items-path inset without changing direct compound consumers.
    <TabsBinding
      value={selectedValue}
      onValueChange={handleValueChange}
      variant
      size
      ?fitContent
      className={variant === TabsBinding.Underline ? "pt-2" : ""}>
      <TabsBinding.List variant size ?fitContent ariaLabel>
        {tabs
        ->Array.mapWithIndex((tab, i) =>
          <TabsBinding.Trigger
            key={i->Int.toString}
            value={i->Int.toString}
            variant
            size
            disabled={disabledTab->Array.includes(tab.title)}
            leftSlot=?{tab.tabElement}>
            {tab.title->React.string}
          </TabsBinding.Trigger>
        )
        ->React.array}
      </TabsBinding.List>
      {tabs
      ->Array.mapWithIndex((tab, i) =>
        <TabsBinding.Content key={i->Int.toString} value={i->Int.toString}>
          {tab.renderContent()}
        </TabsBinding.Content>
      )
      ->React.array}
    </TabsBinding>
  </ErrorBoundary>
}
