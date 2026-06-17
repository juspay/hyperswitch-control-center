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
      <AccessControl isEnabled={featureFlagDetails.devReconEngineRevamped} authorization=Access>
        <ReconEngineRevampedOverviewContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "inbox", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineRevamped}
        authorization={userHasAccess(~groupAccess=ReconExceptionsView)}>
        <ReconEngineRevampedInboxContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transactions", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineRevamped}
        authorization={userHasAccess(~groupAccess=ReconTransactionsView)}>
        <ReconEngineRevampedTransactionsContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "pipelines", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineRevamped}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineRevampedPipelinesContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "rules", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineRevamped}
        authorization={userHasAccess(~groupAccess=ReconRulesView)}>
        <ReconEngineRevampedRulesStudioContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transformations", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineRevamped}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineRevampedTransformationsContainer />
      </AccessControl>
    | _ => <EmptyPage path="/v1/recon-engine/overview" />
    }}
    <ReconEngineActivityFAB />
  </>
}
