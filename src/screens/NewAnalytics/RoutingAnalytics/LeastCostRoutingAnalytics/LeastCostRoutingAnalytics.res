@react.component
let make = () => {
  let {debitRouting} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <RenderIf condition={debitRouting}>
    <LeastCostRoutingAnalyticsDistribution />
    <LeastCostRoutingAnalyticsSummaryTable />
  </RenderIf>
}
