/*
Modules that depend on Merchant data are located within this container.
 */
@react.component
let make = (~setAppScreenState) => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (surveyModal, setSurveyModal) = React.useState(_ => false)
  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let hasMerchantAccountAccess =
    hasAnyGroupAccess(
      userHasAccess(~groupAccess=MerchantDetailsView),
      userHasAccess(~groupAccess=AccountView),
    ) === Access
  let fetchMerchantDetails = MerchantDetailsHook.useFetchMerchantDetails(~showErrorToast=false)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  React.useEffect(() => {
    if (
      hasMerchantAccountAccess &&
      merchantDetailsTypedValue.publishable_key->LogicUtils.isEmptyString
    ) {
      let loadDetails = async () => {
        try {
          let _ = await fetchMerchantDetails(~version)
        } catch {
        | _ => ()
        }
      }
      loadDetails()->ignore
    }
    None
  }, [])

  <div>
    {switch url.path->urlPath {
    | list{"home"} => <Home setAppScreenState />
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
