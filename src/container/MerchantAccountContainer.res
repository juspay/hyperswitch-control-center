/*
Modules that depend on Merchant data are located within this container.
 */
@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (surveyModal, setSurveyModal) = React.useState(_ => false)
  let {
    hasAnyGroupAccess,
    userHasAccess,
    userHasResourceAccess,
  } = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if !checkUserEntity([#Profile]) {
        let _ = await fetchMerchantAccountDetails()
      }
      if userHasAccess(~groupAccess=ConnectorsView) === Access {
        if !featureFlagDetails.isLiveMode {
          let _ = await fetchConnectorListResponse()
          let _ = await fetchBusinessProfiles()
        }
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setUpConnectoreContainer()->ignore
    None
  }, [])
  <div>
    <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
      {switch url.path->urlPath {
      | list{"home"} => <Home />

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
      | list{"file-processor"} =>
        <AccessControl
          isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])}
          authorization={userHasResourceAccess(~resourceAccess=ReconFiles)}>
          <ReconModule urlList={url.path->urlPath} />
        </AccessControl>
      | list{"sdk"} =>
        <AccessControl
          isEnabled={!featureFlagDetails.isLiveMode}
          authorization={userHasAccess(~groupAccess=ConnectorsView)}>
          <SDKPage />
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
    </PageLoaderWrapper>
  </div>
}
