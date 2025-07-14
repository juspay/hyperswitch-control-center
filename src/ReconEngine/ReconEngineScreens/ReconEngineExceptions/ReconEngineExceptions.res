@react.component
let make = () => {
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Exceptions at Upload",
        renderContent: () => <ReconEngineExceptionStaging />,
      },
      {
        title: "Exceptions at Recon",
        renderContent: () => <ReconExceptionTransaction />,
      },
    ]
  }, [])

  <div className="flex flex-col gap-8 p-6">
    <div className="flex flex-row justify-between items-center gap-4">
      <div className="flex-shrink-0">
        <PageUtils.PageHeading
          title="Exceptions"
          subTitle="View your exceptions and their details"
          customTitleStyle="py-0"
        />
      </div>
      <div className="flex flex-row items-center gap-4">
        <div className="flex-shrink-0 mt-2">
          <Button
            text="Generate Report"
            buttonType=Primary
            buttonSize=Large
            onClick={_ => {
              mixpanelEvent(~eventName="recon_engine_exceptions_generate_reports_clicked")
            }}
          />
        </div>
      </div>
    </div>
    <div className="flex flex-col gap-2">
      <Tabs
        initialIndex={tabIndex >= 0 ? tabIndex : 0}
        tabs
        showBorder=true
        includeMargin=false
        defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center px-6 ${Typography.body.md.semibold}`}
        onTitleClick={index => {
          setTabIndex(_ => index)
        }}
        selectTabBottomBorderColor="bg-primary"
      />
    </div>
  </div>
}
