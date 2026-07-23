@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom

  switch url.path->HSwitchUtils.urlPath {
  | list{"v1", "recon-engine", "pipelines", ...remainingPath} =>
    <AccessControl
      isEnabled={featureFlagDetails.devReconEngineV1 && featureFlagDetails.devReconEnginePipelines}
      authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
      <EntityScaffold
        entityName="IngestionHistory"
        remainingPath
        access=Access
        renderList={() =>
          <FilterContext key="recon-engine-pipelines" index="recon-engine-pipelines">
            <ReconEnginePipelines />
          </FilterContext>}
        renderShow={(id, _) =>
          <FilterContext key="recon-engine-pipeline-details" index="recon-engine-pipeline-details">
            <ReconEnginePipelineDetails ingestionHistoryId=id />
          </FilterContext>}
      />
    </AccessControl>
  | _ => React.null
  }
}
