open OrderTypes

let paymentListSources: array<paymentListSource> = [Normal, Advanced]

module SourceTabs = {
  @react.component
  let make = (
    ~source: paymentListSource,
    ~setSource: paymentListSource => unit,
    ~advancedEnabled,
  ) => {
    let tabs = paymentListSources->Array.map((item): Tabs.tab => {
      title: (item :> string),
      renderContent: () => React.null,
    })
    let initialIndex = paymentListSources->Array.indexOf(source)->(idx => idx < 0 ? 0 : idx)
    let disabledTab = advancedEnabled ? [] : [(Advanced :> string)]

    let sourceTabs =
      <Tabs
        tabs
        initialIndex
        disabledTab
        variant=TabsBinding.Boxed
        size=TabsBinding.Md
        fitContent=true
        onTitleClick={idx =>
          switch paymentListSources->Array.get(idx) {
          | Some(Advanced) => advancedEnabled ? setSource(Advanced) : ()
          | Some(Normal) => setSource(Normal)
          | None => ()
          }}
      />

    advancedEnabled
      ? sourceTabs
      : <ToolTip
          description="Advanced payments list is not available for this account."
          toolTipFor=sourceTabs
          toolTipPosition=Top
        />
  }
}
