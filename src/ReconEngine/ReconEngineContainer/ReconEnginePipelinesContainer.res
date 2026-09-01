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
      <FilterContext key="recon-engine-pipelines" index="recon-engine-pipelines">
        <EntityScaffold
          entityName="IngestionHistory"
          remainingPath
          access=Access
          renderList={() => <ReconEnginePipelines />}
          renderShow={(id, _) =>
            <FilterContext
              key="recon-engine-pipeline-details" index="recon-engine-pipeline-details">
              <ReconEnginePipelineDetails ingestionHistoryId=id />
            </FilterContext>}
        />
      </FilterContext>
    </AccessControl>
  | _ => React.null
  }
}
