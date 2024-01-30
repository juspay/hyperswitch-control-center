@react.component
let make = (~entityName) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (reportModal, setReportModal) = React.useState(_ => false)
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  <>
    <ACLButton
      text="Generate Reports"
      buttonType={Primary}
      buttonSize={XSmall}
      onClick={_ => {
        setReportModal(_ => true)
        mixpanelEvent(~eventName="generate_reports", ())
      }}
      access={userPermissionJson.paymentWrite}
      toolTipPosition={Left}
    />
    <UIUtils.RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal entityName />
    </UIUtils.RenderIf>
  </>
}
