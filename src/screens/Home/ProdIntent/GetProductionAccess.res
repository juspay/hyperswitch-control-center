@react.component
let make = () => {
  let textStyles = HSwitchUtils.getTextClass((P2, Medium))
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let {hasAnyGroupAccess, userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let {resolvedUserInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let isProdIntent = isProdIntentCompleted->Option.getOr(false)

  let cursorStyles = isProdIntent ? "cursor-default" : "cursor-pointer underline"
  let productionAccessString = isProdIntent
    ? "Production Access Requested"
    : "Get Production Access"
  let eventName = switch activeProduct {
  | DynamicRouting => "intelligent_routing_get_production_access"
  | Orchestration(V1) => "get_production_access"
  | _ => `${activeProduct->ProductUtils.getProductStringName}_get_production_access`
  }

  let prodAccess = switch isProdIntentCompleted {
  | Some(_) =>
    <div
      className={`flex items-center gap-2 text-nd_yellow-200  ${cursorStyles}  whitespace-nowrap rounded-lg justify-between `}
      onClick={_ => {
        if !isProdIntent {
          setShowProdIntentForm(_ => true)
          mixpanelEvent(~eventName)
        }
      }}>
      <div className={`text-nd_yellow-200 ${textStyles} !font-semibold `}>
        {productionAccessString->React.string}
      </div>
    </div>
  | None => React.null
  }

  let isProdAccessAvailableForProduct = switch activeProduct {
  | Orchestration(V1)
  | DynamicRouting
  | Recon(V2) => true
  | _ => false
  }

  let showGetProductionAccess =
    !isLiveMode &&
    !isInternalUser &&
    // TODO: Remove `MerchantDetailsManage` permission in future
    hasAnyGroupAccess(
      userHasAccess(~groupAccess=UserManagementTypes.MerchantDetailsManage),
      userHasAccess(~groupAccess=UserManagementTypes.AccountManage),
    ) === CommonAuthTypes.Access &&
    isProdAccessAvailableForProduct

  <RenderIf condition={showGetProductionAccess}> {prodAccess} </RenderIf>
}
