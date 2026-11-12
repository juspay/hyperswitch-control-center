@react.component
let make = () => {
  open HSwitchUtils
  open UserManagementTypes
  open HyperswitchAtom
  open ReconEngineFilterUtils

  let url = RescriptReactRouter.useUrl()
  let {userHasAccess, userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchBusinessProfile = ReconEngineHooks.useFetchBusinessProfile()
  let {getCommonSessionDetails, checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {profileId} = getCommonSessionDetails()

  React.useEffect(() => {
    fetchBusinessProfile()->ignore
    None
  }, [profileId])

  <>
    <FilterContext
      key=globalDateFilterContextIndex index=globalDateFilterContextIndex persistOnUnmount=true>
      <ReconEngineGlobalDateFilter />
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
      | list{"v1", "recon-engine", "api-keys", ..._} =>
        <AccessControl
          isEnabled={featureFlagDetails.devReconEngineV1}
          authorization={checkUserEntity([#Profile])
            ? NoAccess
            : userHasResourceAccess(~resourceAccess=Account)}>
          <ReconEngineApiKeysContainer />
        </AccessControl>
      | list{"v1", "recon-engine", "pipelines", ..._} =>
        <AccessControl
          isEnabled={featureFlagDetails.devReconEngineV1}
          authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
          <ReconEnginePipelinesContainer />
        </AccessControl>
      | list{"v1", "recon-engine", "transformed-entries", ..._} =>
        <AccessControl
          isEnabled={featureFlagDetails.devReconEngineV1}
          authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
          <ReconEngineTransformedEntriesContainer />
        </AccessControl>
      | _ => <EmptyPage path="/v1/recon-engine/overview" />
      }}
    </FilterContext>
    <ReconEngineActivityFAB />
  </>
}
