@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open AdditionalDetailsSidebarHelper

  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <>
    <Heading title="Google Pay" iconName="google_pay" />
    {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
    | Processors(ZEN) =>
      <GooglePayZen connector update onCloseClickCustomFun setShowWalletConfigurationModal />
    | Processors(CYBERSOURCE) =>
      <>
        <RenderIf condition={!featureFlag.googlePayDecryptionFlow}>
          <GooglePayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
        </RenderIf>
        <RenderIf condition={featureFlag.googlePayDecryptionFlow}>
          <GPayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
        </RenderIf>
      </>
    | _ => <GooglePayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
    }}
  </>
}
