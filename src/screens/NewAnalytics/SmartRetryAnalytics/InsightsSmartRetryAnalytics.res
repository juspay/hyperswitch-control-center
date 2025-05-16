@react.component
let make = () => {
  open InsightsSmartRetryAnalyticsEntity
  let {newAnalyticsFilters} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <RenderIf condition={newAnalyticsFilters}>
      <div className="flex gap-2">
        <InsightsAnalyticsFilters domain={#payments} entityName={V1(ANALYTICS_PAYMENTS)} />
      </div>
    </RenderIf>
    <SmartRetryPaymentsProcessed
      entity={smartRetryPaymentsProcessedEntity}
      chartEntity={smartRetryPaymentsProcessedChartEntity}
    />
    <SuccessfulSmartRetryDistribution
      entity={successfulSmartRetryDistributionEntity}
      chartEntity={successfulSmartRetryDistributionChartEntity}
    />
    <FailureSmartRetryDistribution
      entity={failedSmartRetryDistributionEntity}
      chartEntity={failedSmartRetryDistributionChartEntity}
    />
  </div>
}
