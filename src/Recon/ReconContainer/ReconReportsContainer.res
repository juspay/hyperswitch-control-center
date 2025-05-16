@react.component
let make = (~showOnBoarding) => {
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
  | list{"v2", "recon", "reports", ...remainingPath} =>
    <EntityScaffold
      entityName="Payments"
      remainingPath
      access=Access
      renderList={() => <ReconReports showOnBoarding />}
      renderShow={(id, _) => <ShowReconExceptionReport showOnBoarding id />}
    />
  | _ => React.null
  }
}
