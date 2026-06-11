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
  let merchantDetailsTypedValue = MerchantDetailsHook.useMerchantDetails(
    ~shouldFetch=hasMerchantAccountAccess,
  )

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
