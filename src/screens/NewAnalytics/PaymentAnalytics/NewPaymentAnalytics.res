@react.component
let make = () => {
  open NewPaymentAnalyticsEntity

  let {newAnalyticsFilters} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <>
    <div className="flex flex-col gap-14 mt-5 pt-7">
      <div className="flex gap-2">
        <NewAnalyticsHelper.SmartRetryToggle />
        <RenderIf condition={newAnalyticsFilters}>
          <NewAnalyticsFilters domain={#payments} entityName={V1(ANALYTICS_PAYMENTS)} />
        </RenderIf>
      </div>
      <NewPaymentsOverviewSection entity={overviewSectionEntity} />
      <PaymentsLifeCycle
        entity={paymentsLifeCycleEntity} chartEntity={paymentsLifeCycleChartEntity}
      />
      <PaymentsProcessed
        entity={paymentsProcessedEntity} chartEntity={paymentsProcessedChartEntity}
      />
      <PaymentsSuccessRate
        entity={paymentsSuccessRateEntity} chartEntity={paymentsSuccessRateChartEntity}
      />
      <SuccessfulPaymentsDistribution
        entity={successfulPaymentsDistributionEntity}
        chartEntity={successfulPaymentsDistributionChartEntity}
      />
      <FailedPaymentsDistribution
        entity={failedPaymentsDistributionEntity}
        chartEntity={failedPaymentsDistributionChartEntity}
      />
      <FailureReasonsPayments entity={failureReasonsEntity} />
    </div>
  </>
}
