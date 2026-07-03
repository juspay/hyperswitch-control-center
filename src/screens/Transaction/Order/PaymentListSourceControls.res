module SourceTabs = {
  @react.component
  let make = (
    ~source: OrderTypes.paymentListSource,
    ~setSource: (OrderTypes.paymentListSource => OrderTypes.paymentListSource) => unit,
    ~advancedEnabled,
  ) => {
    <TabsBinding
      value={source->OrderTypes.getPaymentListSourceLabel}
      onValueChange={value => {
        switch value->OrderTypes.getPaymentListSourceFromLabel {
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
        {OrderTypes.paymentListSources
        ->Array.map(item => {
          let value = item->OrderTypes.getPaymentListSourceLabel
          let isDisabled = item === OrderTypes.Advanced && !advancedEnabled
          <TabsBinding.Trigger
            key=value
            value
            variant=Boxed
            size=Md
            disabled=isDisabled
            className="min-w-20 justify-center">
            <ToolTip
              description={item->OrderTypes.getPaymentListSourceDescription}
              toolTipFor={<span>
                {item->OrderTypes.getPaymentListSourceDisplayName->React.string}
              </span>}
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
