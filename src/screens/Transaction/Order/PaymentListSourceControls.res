open OrderTypes
open OrderUIUtils
module SourceTabs = {
  @react.component
  let make = (
    ~source: paymentListSource,
    ~setSource: (paymentListSource => paymentListSource) => unit,
    ~advancedEnabled,
  ) => {
    <TabsBinding
      value={source->getPaymentListSourceLabel}
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
          let value = item->getPaymentListSourceLabel
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
