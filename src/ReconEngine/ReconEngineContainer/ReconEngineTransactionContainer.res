@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transactions", ...remainingPath} =>
    <EntityScaffold
      entityName="Transactions"
      remainingPath
      access=Access
      renderList={() =>
        <FilterContext key="recon-engine-transactions" index="recon-engine-transactions">
          <ReconEngineTransactions />
        </FilterContext>}
      renderShow={(id, _) => <ReconEngineTransactionsDetail id />}
    />
  | _ => React.null
  }
}
