@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <>
    {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
    | Processors(ZEN) =>
      <GooglePayZen connector update onCloseClickCustomFun setShowWalletConfigurationModal />
    | Processors(CYBERSOURCE) =>
      <>
        <RenderIf condition={!featureFlag.googlePayDirectFlow}>
          <GooglePayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
        </RenderIf>
        <RenderIf condition={featureFlag.googlePayDirectFlow}>
          <GPayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
        </RenderIf>
      </>
    | Processors(NUVEI)
    | Processors(WORLDPAYVANTIV) =>
      <GPayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
    | _ => <GooglePayFlow connector setShowWalletConfigurationModal update onCloseClickCustomFun />
    }}
  </>
}
