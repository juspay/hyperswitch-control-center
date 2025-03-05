@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding />
    | list{"v2", "recovery", "home"} => <RevenueRecoveryOnboarding />
    | list{"v2", "recovery", "summary", ..._} => <BillingConnectorsSummary />
    | list{"v2", "recovery", "onboarding", ..._}
    | list{"v2", "recovery", "connectors", ..._} =>
      <RecoveryConnectorContainer />
    | list{"v2", "recovery", "overview", ...remainingPath} =>
      <EntityScaffold
        entityName="Payments"
        remainingPath
        access=Access
        renderList={() => <RevenueRecoveryOverview />}
        renderCustomWithOMP={(id, _, _, _) => <ShowRevenueRecovery id />}
      />
    | _ => React.null
    }
  }
}
