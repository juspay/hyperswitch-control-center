@react.component
let make = () => {
  open HSwitchUtils
  open UserManagementTypes
  open HyperswitchAtom

  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom

  <>
    {switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} =>
      <AccessControl isEnabled={featureFlagDetails.devReconEngineV1} authorization=Access>
        <ReconEngineOverviewContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transactions", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconTransactionsView)}>
        <ReconEngineTransactionContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "exceptions", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconExceptionsView)}>
        <ReconEngineExceptionContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "rules", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconRulesView)}>
        <ReconEngineRulesContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "pipelines", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1 &&
        featureFlagDetails.devReconEnginePipelines}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEnginePipelinesContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "sources", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineSourcesContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transformation", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineTransformationContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transformed-entries", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineTransformedEntriesContainer />
      </AccessControl>
    | _ => <EmptyPage path="/v1/recon-engine/overview" />
    }}
    <ReconEngineActivityFAB />
  </>
}
