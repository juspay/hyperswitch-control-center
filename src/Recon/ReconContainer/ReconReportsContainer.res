@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v2", "recon", "reports", ...remainingPath} =>
    <EntityScaffold
      entityName="Payments"
      remainingPath
      access=Access
      renderList={() => <ReconReports />}
      renderShow={(id, _) => <ShowReconExceptionReport id />}
    />
  | _ => React.null
  }
}
