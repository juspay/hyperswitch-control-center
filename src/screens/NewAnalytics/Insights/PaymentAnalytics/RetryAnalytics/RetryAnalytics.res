@react.component
let make = () => {
  open RetryAnalyticsEntity

  <div className="flex flex-col gap-14 mt-5 pt-7">
    <NormalizedDeclineDistribution
      entity={normalizedDeclineDistributionEntity}
      chartEntity={normalizedDeclineDistributionChartEntity}
    />
    <ConnectorDeclineMatrix
      entity={connectorDeclineMatrixEntity} chartEntity={connectorDeclineMatrixChartEntity}
    />
  </div>
}
