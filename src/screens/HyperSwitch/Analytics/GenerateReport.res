@react.component
let make = (~entityName) => {
  let url = RescriptReactRouter.useUrl()
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)

  <>
    <Button
      text="Generate Reports"
      buttonType={Primary}
      onClick={_ => {
        hyperswitchMixPanel(
          ~eventName=Some(`${url.path->LogicUtils.getListHead}_generate_reports`),
          (),
        )
        setReportModal(_ => true)
      }}
    />
    <UIUtils.RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </UIUtils.RenderIf>
  </>
}
