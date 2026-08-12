@react.component
let make = () => {
  open HSwitchUtils
  open UserManagementTypes
  open HyperswitchAtom
  open ReconEngineFilterUtils

  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom

  <>
    {switch url.path->urlPath {
    | list{"v1", "recon-engine", "rules", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconRulesView)}>
        <ReconEngineRulesContainer />
      </AccessControl>
    | _ =>
      <FilterContext
        key=globalDateFilterContextIndex index=globalDateFilterContextIndex persistOnUnmount=true>
        <ReconEngineGlobalDateFilterContainer />
      </FilterContext>
    }}
    <ReconEngineActivityFAB />
  </>
}
