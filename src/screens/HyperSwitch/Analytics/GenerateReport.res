@react.component
let make = (~entityName) => {
  let (reportModal, setReportModal) = React.useState(_ => false)

  <>
    <Button
      text="Generate Reports"
      buttonType={Primary}
      onClick={_ => {
        setReportModal(_ => true)
      }}
    />
    <UIUtils.RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </UIUtils.RenderIf>
  </>
}
