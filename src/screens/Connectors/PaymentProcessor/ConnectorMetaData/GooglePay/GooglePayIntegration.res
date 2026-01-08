@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="p-6">
    {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
    | Processors(ZEN) => <GooglePayZen connector update onCloseClickCustomFun closeAccordionFn />
    | Processors(CYBERSOURCE) =>
      <>
        <RenderIf condition={!featureFlag.googlePayDirectFlow}>
          <GooglePayFlow connector closeAccordionFn update onCloseClickCustomFun />
        </RenderIf>
        <RenderIf condition={featureFlag.googlePayDirectFlow}>
          <GPayFlow connector closeAccordionFn update onCloseClickCustomFun />
        </RenderIf>
      </>
    | Processors(NUVEI)
    | Processors(TESOURO) =>
      <GPayFlow connector closeAccordionFn update onCloseClickCustomFun />
    | _ => <GooglePayFlow connector closeAccordionFn update onCloseClickCustomFun />
    }}
  </div>
}
