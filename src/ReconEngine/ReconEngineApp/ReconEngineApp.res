@react.component
let make = () => {
  open HSwitchUtils
  open UserManagementTypes
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  /* FAB hidden on revamped routes — they surface activity in-page. */
  let showActivityFab = switch url.path->urlPath {
  | list{"v1", "recon-engine", "overview", ..._} => false
  | list{"v1", "recon-engine", "transactions", ..._} => false
  | list{"v1", "recon-engine", "sources", ..._} => false
  | list{"v1", "recon-engine", "transformation", ..._} => false
  | list{"v1", "recon-engine", "transformed-entries", ..._} => false
  | list{"v1", "recon-engine", "exceptions", ..._} => false
  | _ => true
  }

  <>
    {switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} => <ReconEngineOverviewContainer />
    | list{"v1", "recon-engine", "transactions", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ReconTransactionsView)}>
        <ReconEngineTransactionContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "exceptions", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ReconExceptionsView)}>
        <ReconEngineExceptionContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "rules", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ReconRulesView)}>
        <ReconEngineRulesContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "sources", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineSourcesContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transformation", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineTransformationContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transformed-entries", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineTransformedEntriesContainer />
      </AccessControl>
    | _ => <EmptyPage path="/v1/recon-engine/overview" />
    }}
    <RenderIf condition={showActivityFab}>
      <ReconEngineActivityFAB />
    </RenderIf>
  </>
}
