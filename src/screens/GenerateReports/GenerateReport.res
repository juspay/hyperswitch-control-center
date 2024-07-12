@react.component
let make = (~entityName) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let accessForGenerateReports = switch (
    userPermissionJson.operationsView,
    userPermissionJson.analyticsView,
  ) {
  | (NoAccess, NoAccess) => userPermissionJson.operationsView
  | (_, _) => Access
  }

  <>
    <ACLButton
      text="Generate Reports"
      buttonType={Primary}
      buttonSize={XSmall}
      onClick={_ => {
        setReportModal(_ => true)
        mixpanelEvent(~eventName="generate_reports", ())
      }}
      access={accessForGenerateReports}
      toolTipPosition={Left}
    />
    <UIUtils.RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </UIUtils.RenderIf>
  </>
}
