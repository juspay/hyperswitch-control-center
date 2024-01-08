@react.component
let make = (~entityName) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)

  <>
    <Button
      text="Generate Reports"
      buttonType={Primary}
      onClick={_ => {
        setReportModal(_ => true)
        mixpanelEvent(~eventName="generate_reports", ())
      }}
    />
    <UIUtils.RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </UIUtils.RenderIf>
  </>
}
