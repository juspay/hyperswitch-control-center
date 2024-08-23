@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (surveyModal, setSurveyModal) = React.useState(_ => false)
  let userPermissionJson = Recoil.useRecoilValueFromAtom(userPermissionAtom)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userPermissionJson.connectorsView === Access ||
        userPermissionJson.workflowsView === Access ||
        userPermissionJson.workflowsManage === Access
      ) {
        let _ = await fetchMerchantAccountDetails()
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
  }, [userPermissionJson])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"home"} => featureFlagDetails.quickStart ? <HomeV2 /> : <Home />
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
    <RenderIf
      condition={!featureFlagDetails.isLiveMode &&
      userPermissionJson.merchantDetailsManage === Access &&
      merchantDetailsTypedValue.merchant_name->Option.isNone}>
      <SbxOnboardingSurvey showModal=surveyModal setShowModal=setSurveyModal />
    </RenderIf>
  </PageLoaderWrapper>
}
