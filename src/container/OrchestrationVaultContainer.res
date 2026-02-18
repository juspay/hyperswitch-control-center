@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let (sampleReport, setSampleReport) = React.useState(_ => false)
  let setIsOrchestrationVault = Recoil.useSetRecoilState(HyperswitchAtom.orchestrationVaultAtom)

  React.useEffect(() => {
    setIsOrchestrationVault(_ => true)
    None
  }, [])

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"vault-onboarding", ...remainingPath} =>
      <EntityScaffold
        entityName="VaultConnector"
        remainingPath
        access=Access
        renderList={() => <VaultConfiguration />}
        renderNewForm={() => <VaultOnboarding />}
      />
    | list{"vault-customers-tokens", ...remainingPath} =>
      <EntityScaffold
        entityName="Vault"
        remainingPath
        access=Access
        renderList={() => <VaultCustomersAndTokens sampleReport setSampleReport />}
        renderShow={(id, _) => <VaultCustomerSummary id sampleReport />}
      />
    | _ => React.null
    }
  }
}
