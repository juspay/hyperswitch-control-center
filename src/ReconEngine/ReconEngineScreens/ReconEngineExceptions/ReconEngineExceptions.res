open Typography

@react.component
let make = () => {
  let mixpanelEvent = MixpanelHook.useSendEvent()

  <div className="flex flex-col gap-4 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Exceptions" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
      />
      <div className="flex-shrink-0">
        <Button
          text="Generate Report"
          buttonType=Primary
          buttonSize=Large
          buttonState=Disabled
          onClick={_ => {
            mixpanelEvent(~eventName="recon_engine_exceptions_generate_reports_clicked")
          }}
        />
      </div>
    </div>
    <div className="flex flex-col gap-2">
      <FilterContext
        key="recon-engine-exception-transaction" index="recon-engine-exception-transaction">
        <ReconExceptionTransaction />
      </FilterContext>
    </div>
  </div>
}
