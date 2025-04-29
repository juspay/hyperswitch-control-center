/*
Modules that depend on Merchant data are located within this container.
 */
@react.component
let make = (~setAppScreenState) => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (surveyModal, setSurveyModal) = React.useState(_ => false)
  let {
    userHasAccess,
    hasAnyGroupAccess,
    hasAllGroupsAccess,
    userHasResourceAccess,
  } = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

  <div>
    {switch url.path->urlPath {
    | list{"home"} => <Home setAppScreenState />
    | list{"recon"} =>
      <AccessControl
        isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
        authorization={userHasResourceAccess(~resourceAccess=ReconToken)}>
        <Recon />
      </AccessControl>
    | list{"upload-files"} =>
      <AccessControl
        isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
        authorization={userHasResourceAccess(~resourceAccess=ReconUpload)}>
        <ReconModule urlList={url.path->urlPath} />
      </AccessControl>
    | list{"run-recon"} =>
      <AccessControl
        isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
        authorization={userHasResourceAccess(~resourceAccess=RunRecon)}>
        <ReconModule urlList={url.path->urlPath} />
      </AccessControl>
    | list{"recon-analytics"} =>
      <AccessControl
        isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
        authorization={userHasResourceAccess(~resourceAccess=ReconAndSettlementAnalytics)}>
        <ReconModule urlList={url.path->urlPath} />
      </AccessControl>
    | list{"reports"} =>
      <AccessControl
        isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
        authorization={userHasResourceAccess(~resourceAccess=ReconReports)}>
        <ReconModule urlList={url.path->urlPath} />
      </AccessControl>
    | list{"config-settings"} =>
      <AccessControl
        isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
        authorization={userHasResourceAccess(~resourceAccess=ReconConfig)}>
        <ReconModule urlList={url.path->urlPath} />
      </AccessControl>

    // Commented as not needed now
    // | list{"file-processor"} =>
    //   <AccessControl
    //     isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
    //     authorization={userHasResourceAccess(~resourceAccess=ReconFiles)}>
    //     <ReconModule urlList={url.path->urlPath} />
    //   </AccessControl>
    | list{"sdk"} =>
      <AccessControl
        isEnabled={!featureFlagDetails.isLiveMode}
        authorization={hasAllGroupsAccess([
          userHasAccess(~groupAccess=OperationsManage),
          userHasAccess(~groupAccess=ConnectorsManage),
        ])}>
        <SDKProvider>
          <SDKPage />
        </SDKProvider>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
    <RenderIf
      condition={!featureFlagDetails.isLiveMode &&
      // TODO: Remove `MerchantDetailsManage` permission in future
      hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      ) === Access &&
      !checkUserEntity([#Profile]) &&
      merchantDetailsTypedValue.merchant_name->Option.isNone}>
      <SbxOnboardingSurvey showModal=surveyModal setShowModal=setSurveyModal />
    </RenderIf>
  </div>
}
