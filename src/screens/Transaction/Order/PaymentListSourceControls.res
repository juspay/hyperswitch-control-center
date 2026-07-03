module SourceTabs = {
  let getPaymentListSourceLabel = (source: OrderTypes.paymentListSource) => (source :> string)

  let paymentListSources: array<OrderTypes.paymentListSource> = [
    OrderTypes.Normal,
    OrderTypes.Advanced,
  ]

  let getPaymentListSourceFromLabel = value =>
    paymentListSources->Array.find(source => source->getPaymentListSourceLabel == value)

  let getPaymentListSourceDescription = source =>
    switch source {
    | OrderTypes.Normal => "Standard payments list."
    | OrderTypes.Advanced => "Advanced payment list with expanded search, filters, columns, and CSV export."
    }

  @react.component
  let make = (
    ~source: OrderTypes.paymentListSource,
    ~setSource: (OrderTypes.paymentListSource => OrderTypes.paymentListSource) => unit,
    ~advancedEnabled,
  ) => {
    <TabsBinding
      value={source->getPaymentListSourceLabel}
      onValueChange={value => {
        switch value->getPaymentListSourceFromLabel {
        | Some(OrderTypes.Advanced) =>
          if advancedEnabled {
            setSource(_ => OrderTypes.Advanced)
          }
        | Some(OrderTypes.Normal) => setSource(_ => OrderTypes.Normal)
        | None => ()
        }
      }}
      variant=Boxed
      size=Md>
      <TabsBinding.List variant=Boxed size=Md fitContent=true>
        {paymentListSources
        ->Array.map(item => {
          let value = item->getPaymentListSourceLabel
          let isDisabled = item === OrderTypes.Advanced && !advancedEnabled
          <TabsBinding.Trigger
            key=value
            value
            variant=Boxed
            size=Md
            disabled=isDisabled
            className="min-w-20 justify-center">
            <ToolTip
              description={item->getPaymentListSourceDescription}
              toolTipFor={<span> {(item :> string)->React.string} </span>}
              toolTipPosition=ToolTip.Top
            />
          </TabsBinding.Trigger>
        })
        ->React.array}
      </TabsBinding.List>
    </TabsBinding>
  }
}

module ExportButton = {
  @react.component
  let make = (
    ~selectedRowsCount,
    ~canExportSelectedRows,
    ~buttonState: Button.buttonState,
    ~onExport,
  ) => {
    let selectedRowsCountClass = canExportSelectedRows ? "text-white" : "text-nd_gray-500"

    <div className="shrink-0">
      <Button
        text="Export"
        buttonType=Primary
        buttonState
        buttonSize=Small
        customButtonStyle="justify-start"
        customIconMargin="ml-2"
        customTextPaddingClass="!pl-2 !pr-1"
        leftIcon={Button.CustomIcon(<Icon name="nd-download-bar-down" size=16 />)}
        rightIcon={Button.CustomIcon(
          <span className={`${Typography.body.sm.semibold} ${selectedRowsCountClass}`}>
            {selectedRowsCount->Int.toString->React.string}
          </span>,
        )}
        onClick={_ => canExportSelectedRows ? onExport() : ()}
      />
    </div>
  }
}
