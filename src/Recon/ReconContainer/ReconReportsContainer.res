@react.component
let make = (~showOnBoarding) => {
  let url = RescriptReactRouter.useUrl()

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
