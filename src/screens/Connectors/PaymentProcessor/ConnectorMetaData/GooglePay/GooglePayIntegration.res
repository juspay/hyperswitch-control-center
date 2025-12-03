@react.component
let make = (~connector, ~closeAccordionFn, ~update) => {
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="p-6">
    {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
    | Processors(ZEN) => <GooglePayZen connector update closeAccordionFn />
    | Processors(CYBERSOURCE) =>
      <>
        <RenderIf condition={!featureFlag.googlePayDirectFlow}>
          <GooglePayFlow connector closeAccordionFn update />
        </RenderIf>
        <RenderIf condition={featureFlag.googlePayDirectFlow}>
          <GPayFlow connector closeAccordionFn update />
        </RenderIf>
      </>
    | Processors(NUVEI)
    | Processors(TESOURO) =>
      <GPayFlow connector closeAccordionFn update />
    | _ => <GooglePayFlow connector closeAccordionFn update />
    }}
  </div>
}
