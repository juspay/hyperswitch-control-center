@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let showSidebar = () => {
    setShowSideBar(_ => true)
  }

  React.useEffect(() => {
    showSidebar()
    None
  }, [])

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "transactions", ...remainingPath} =>
    <EntityScaffold
      entityName="Transactions"
      remainingPath
      access=Access
      renderList={() => <ReconEngineTransactions />}
      renderShow={(id, _) => <ReconEngineTransactionsDetail id />}
    />
  | _ => React.null
  }
}
