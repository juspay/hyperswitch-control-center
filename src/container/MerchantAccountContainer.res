/*
Modules that depend on Merchant data are located within this container.
 */
@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (surveyModal, setSurveyModal) = React.useState(_ => false)
  let {userHasAccess} = PermissionHooks.useUserGroupPermissionsHook()
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

      let _ = await fetchMerchantAccountDetails()
      if userHasAccess(~permission=ConnectorsView) === Access {
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
          isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])} permission=Access>
          <Recon />
        </AccessControl>
      | list{"upload-files"}
      | list{"run-recon"}
      | list{"recon-analytics"}
      | list{"reports"}
      | list{"config-settings"}
      | list{"file-processor"} =>
        <AccessControl
          isEnabled={featureFlagDetails.recon && !checkUserEntity([#Profile])} permission=Access>
          <ReconModule urlList={url.path->urlPath} />
        </AccessControl>
      | list{"sdk"} =>
        <AccessControl
          isEnabled={!featureFlagDetails.isLiveMode}
          permission={userHasAccess(~permission=ConnectorsView)}>
          <SDKPage />
        </AccessControl>
      | list{"unauthorized"} => <UnauthorizedPage />
      | _ => <NotFoundPage />
      }}
      <RenderIf
        condition={!featureFlagDetails.isLiveMode &&
        userHasAccess(~permission=MerchantDetailsManage) === Access &&
        merchantDetailsTypedValue.merchant_name->Option.isNone}>
        <SbxOnboardingSurvey showModal=surveyModal setShowModal=setSurveyModal />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
