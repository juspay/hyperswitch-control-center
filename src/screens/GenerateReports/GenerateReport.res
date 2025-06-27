@react.component
let make = (~entityName, ~disableReport=false) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)
  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()

  let accessForGenerateReports = hasAnyGroupAccess(
    userHasAccess(~groupAccess=OperationsView),
    userHasAccess(~groupAccess=AnalyticsView),
  )

  <>
    <ACLButton
      text="Generate Reports"
      buttonType={Primary}
      buttonSize=Small
      buttonState={disableReport ? Disabled : Normal}
      onClick={_ => {
        setReportModal(_ => true)
        mixpanelEvent(~eventName="generate_reports")
      }}
      authorization={accessForGenerateReports}
      toolTipPosition={Left}
    />
    <RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </RenderIf>
  </>
}
