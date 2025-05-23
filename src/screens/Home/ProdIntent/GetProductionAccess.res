@react.component
let make = () => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let textStyles = HSwitchUtils.getTextClass((P2, Medium))
  let {isProdIntentCompleted, setShowProdIntentForm} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let {hasAnyGroupAccess, userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
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
        isProdIntent
          ? ()
          : {
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
    !featureFlagDetails.isLiveMode &&
    !isInternalUser &&
    // TODO: Remove `MerchantDetailsManage` permission in future
    hasAnyGroupAccess(
      userHasAccess(~groupAccess=UserManagementTypes.MerchantDetailsManage),
      userHasAccess(~groupAccess=UserManagementTypes.AccountManage),
    ) === CommonAuthTypes.Access &&
    productsToShowProductionAccess->Array.includes(activeProduct)

  <>
    <RenderIf condition={showGetProductionAccess}>
      <div
        className="absolute w-fit max-w-fixedPageWidth bg-white flex flex-col items-center -top-11">
        <div
          className="bg-nd_orange-100 px-4 py-[6px] rounded-br-md rounded-bl-md w-fit flex gap-2 items-center">
          <Icon name="nd-toast-info" size=14 customIconColor="text-nd_yellow-200 text-fs-12" />
          <p className="text-nd_yellow-200 text-base leading-5 font-medium text-nowrap">
            {"You're in Test Mode"->React.string}
          </p>
          {prodAccess}
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!showGetProductionAccess}> React.null </RenderIf>
  </>
}
