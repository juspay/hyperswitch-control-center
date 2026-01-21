@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open Typography
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="flex flex-col gap-6 p-6">
    {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
    | Processors(ZEN) => <GooglePayZen connector update onCloseClickCustomFun closeAccordionFn />
    | Processors(CYBERSOURCE) =>
      <>
        <RenderIf condition={!featureFlag.googlePayDirectFlow}>
          <GooglePayFlow connector closeAccordionFn update onCloseClickCustomFun />
        </RenderIf>
        <RenderIf condition={featureFlag.googlePayDirectFlow}>
          <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
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
