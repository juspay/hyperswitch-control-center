@react.component
let make = () => {
  let {setCreateNewMerchant, activeProduct} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )
  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let onTryDemoClick = () => {
    mixpanelEvent(~eventName="intelligent_routing_explore_simulator")
    if activeProduct == DynamicRouting {
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/dynamic-routing/home"))
    } else {
      setCreateNewMerchant(ProductTypes.DynamicRouting)
    }
  }

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <img alt="intelligentRouting" src="/IntelligentRouting/IntelligentRoutingOnboarding.svg" />
    <div className="flex flex-col gap-8 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
        {"Intelligent Routing"->React.string}
      </div>
      <PageUtils.PageHeading
        customHeadingStyle="gap-3 flex flex-col items-center"
        title="Uplift your Payment Authorization Rate"
        customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-500"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Real-time ML based algorithms and rule-based constraints to route payments optimally"
      />
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text="Explore Simulator"
        onClick={_ => onTryDemoClick()}
        rightIcon={CustomIcon(<Icon name="nd-angle-right" size=15 />)}
        customTextPaddingClass="pr-0"
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
  </div>
}
