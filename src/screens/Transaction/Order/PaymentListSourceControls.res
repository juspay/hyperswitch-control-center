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
        switch value {
        | "Advanced" =>
          if advancedEnabled {
            setSource(_ => OrderTypes.Advanced)
          }
        | _ => setSource(_ => OrderTypes.Normal)
        }
      }}
      variant=Boxed
      size=Md>
      <TabsBinding.List variant=Boxed size=Md fitContent=true>
        {[OrderTypes.Normal, OrderTypes.Advanced]
        ->Array.map(item => {
          let value = item->OrderTypes.getPaymentListSourceLabel
          let isDisabled = item === OrderTypes.Advanced && !advancedEnabled
          <TabsBinding.Trigger
            key=value
            value
            variant=Boxed
            size=Md
            disabled=isDisabled
            className="min-w-[75px] justify-center">
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
    ~disabledCountClass,
    ~onExport,
  ) => {
    let countClass = canExportSelectedRows
      ? "border-white bg-white text-primary"
      : `border-transparent bg-transparent ${disabledCountClass}`

    <div className="relative shrink-0">
      <Button
        text="Export"
        buttonType=Primary
        buttonState
        buttonSize=Small
        customButtonStyle="!w-[128px] justify-start"
        customIconMargin="ml-2"
        customTextPaddingClass="!pl-2 !pr-8"
        leftIcon={Button.CustomIcon(<Icon name="nd-download-bar-down" size=16 />)}
        onClick={_ => canExportSelectedRows ? onExport() : ()}
      />
      <span
        className={`pointer-events-none absolute right-2 top-1/2 flex h-5 min-w-5 -translate-y-1/2 items-center justify-center rounded-full border px-1 text-xs font-semibold leading-none ${countClass}`}>
        {selectedRowsCount->Int.toString->React.string}
      </span>
    </div>
  }
}
