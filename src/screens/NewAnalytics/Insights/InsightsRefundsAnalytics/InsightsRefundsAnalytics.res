@react.component
let make = () => {
  open InsightsRefundsAnalyticsEntity
  let {newAnalyticsFilters} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <RenderIf condition={newAnalyticsFilters}>
      <div className="flex gap-2">
        <InsightsAnalyticsFilters domain={#refunds} entityName={V1(ANALYTICS_REFUNDS)} />
      </div>
    </RenderIf>
    <RefundsOverviewSection entity={overviewSectionEntity} />
    <RefundsProcessed entity={refundsProcessedEntity} chartEntity={refundsProcessedChartEntity} />
    <RefundsSuccessRate
      entity={refundsSuccessRateEntity} chartEntity={refundsSuccessRateChartEntity}
    />
    <SuccessfulRefundsDistribution
      entity={successfulRefundsDistributionEntity}
      chartEntity={successfulRefundsDistributionChartEntity}
    />
    <FailedRefundsDistribution
      entity={failedRefundsDistributionEntity} chartEntity={failedRefundsDistributionChartEntity}
    />
    <RefundsReasons entity={refundsReasonsEntity} />
    <FailureReasonsRefunds entity={failureReasonsEntity} />
  </div>
}
