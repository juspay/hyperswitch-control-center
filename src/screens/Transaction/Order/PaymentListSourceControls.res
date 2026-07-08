open OrderTypes

let paymentListSources: array<paymentListSource> = [Normal, Advanced]

let getPaymentListSourceFromLabel = value =>
  paymentListSources->Array.find(source => (source :> string) == value)

let getPaymentListSourceDescription = source =>
  switch source {
  | Normal => "Standard payments list."
  | Advanced => "Advanced payment list with expanded search, filters, columns, and CSV export."
  }

module SourceTabs = {
  @react.component
  let make = (
    ~source: paymentListSource,
    ~setSource: (paymentListSource => paymentListSource) => unit,
    ~advancedEnabled,
  ) => {
    <TabsBinding
      value={(source :> string)}
      onValueChange={value => {
        switch value->getPaymentListSourceFromLabel {
        | Some(Advanced) =>
          if advancedEnabled {
            setSource(_ => Advanced)
          }
        | Some(Normal) => setSource(_ => Normal)
        | None => ()
        }
      }}
      variant=Boxed
      size=Md>
      <TabsBinding.List variant=Boxed size=Md fitContent=true>
        {paymentListSources
        ->Array.map(item => {
          let value = (item :> string)
          let isDisabled = item === Advanced && !advancedEnabled
          <TabsBinding.Trigger
            key=value
            value
            variant=Boxed
            size=Md
            disabled=isDisabled
            className="min-w-20 justify-center">
            <ToolTip
              description={item->getPaymentListSourceDescription}
              toolTipFor={<span> {value->React.string} </span>}
              toolTipPosition=Top
            />
          </TabsBinding.Trigger>
        })
        ->React.array}
      </TabsBinding.List>
    </TabsBinding>
  }
}
