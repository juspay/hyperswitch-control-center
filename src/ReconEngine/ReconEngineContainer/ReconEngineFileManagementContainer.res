@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "file-management", _, "transformation-history", ...remainingPath} =>
    <EntityScaffold
      entityName="TransformationHistory"
      remainingPath
      access=Access
      renderList={() => React.null}
      renderShow={(id, _) =>
        <FilterContext
          key={`recon-engine-transformation-history-details-${id}`}
          index={`recon-engine-transformation-history-details-${id}`}>
          <ReconEngineTransformationDetails transformationHistoryId=id />
        </FilterContext>}
    />
  | list{"v1", "recon-engine", "file-management", ...remainingPath} =>
    <EntityScaffold
      entityName="IngestionHistory"
      remainingPath
      access=Access
      renderList={() => <ReconEngineIngestion />}
      renderShow={(id, _) =>
        <FilterContext
          key={`recon-engine-ingestion-history-details-${id}`}
          index={`recon-engine-ingestion-history-details-${id}`}>
          <ReconEngineIngestionDetails id />
        </FilterContext>}
    />
  | _ => React.null
  }
}
