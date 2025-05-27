@react.component
let make = () => {
  let textStyles = HSwitchUtils.getTextClass((P2, Medium))
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let {hasAnyGroupAccess, userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
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
  | Orchestration => "get_production_access"
  | _ => `${(Obj.magic(activeProduct) :> string)}_get_production_access`
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

  let productsToShowProductionAccess: array<ProductTypes.productTypes> = [
    Orchestration,
    DynamicRouting,
    Recon,
  ]

  let showGetProductionAccess =
    !isLiveMode &&
    !isInternalUser &&
    // TODO: Remove `MerchantDetailsManage` permission in future
    hasAnyGroupAccess(
      userHasAccess(~groupAccess=UserManagementTypes.MerchantDetailsManage),
      userHasAccess(~groupAccess=UserManagementTypes.AccountManage),
    ) === CommonAuthTypes.Access &&
    productsToShowProductionAccess->Array.includes(activeProduct)

  <RenderIf condition={showGetProductionAccess}> {prodAccess} </RenderIf>
}
