@react.component
let make = (~entityName) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let accessForGenerateReports = PermissionUtils.hasAnyPermission(
    userPermissionJson.operationsView,
    userPermissionJson.analyticsView,
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
      access={accessForGenerateReports}
      toolTipPosition={Left}
    />
    <RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </RenderIf>
  </>
}
