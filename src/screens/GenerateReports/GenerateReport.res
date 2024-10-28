@react.component
let make = (~entityName) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let accessForGenerateReports = GroupACLHooks.hasAnyGroupAccess(
    userHasAccess(~groupAccess=OperationsView),
    userHasAccess(~groupAccess=AnalyticsView),
  )

  <>
    <ACLButton
      text="Generate Reports"
      buttonType={Primary}
      buttonSize={XSmall}
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
