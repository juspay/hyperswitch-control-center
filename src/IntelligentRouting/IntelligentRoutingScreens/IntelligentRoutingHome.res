@react.component
let make = () => {
  let {setCreateNewMerchant, activeProduct} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let onExploreClick = () => {
    mixpanelEvent(~eventName="intelligent_routing_explore_simulator")
    if activeProduct == DynamicRouting {
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/dynamic-routing/home"))
    } else {
      setCreateNewMerchant(ProductTypes.DynamicRouting)
    }
  }

  React.useEffect(() => {
    setShowSideBar(_ => true)
    None
  }, [])

  let features = [
    (
      "arrow-increasing",
      "bg-orange-100",
      "text-orange-500",
      "Dynamic Authorization Optimization",
      "Maximizes approval rates by routing to best-performing processors.",
    ),
    (
      "nd-swap-arrow-horizontal",
      "bg-purple-100",
      "text-purple-500",
      "Adaptive Fallback & Rerouting",
      "Automatically reroutes payments during outages or declines, ensuring uninterrupted payment flows.",
    ),
    (
      "routing",
      "bg-pink-100",
      "text-pink-500",
      "Cost-Efficient Routing",
      "Optimizes paths to minimize processing and network scheme fees, enhancing your bottom line.",
    ),
    (
      "filter",
      "bg-teal-100",
      "text-teal-500",
      "Customizable Routing Rules",
      "Define preferences based on payment method, currency, region, and more.",
    ),
  ]

  <div className="flex flex-1 flex-col gap-6 items-center w-full">
    <img
      alt="intelligentRoutingPreview"
      src="/assets/IntelligentRoutingHomePreview.png"
      className="w-4/5 rounded-2xl"
    />
    <div className="flex flex-col gap-4 items-center">
      <div className="flex flex-col gap-2 items-center">
        <p className="text-xl font-bold text-center text-nd_gray-700">
          {"Maximize Payment Success & Optimize Costs"->React.string}
        </p>
        <p className="text-sm font-normal text-center text-nd_gray-500 max-w-lg">
          {"Track processor performances in real-time to route payments optimally"->React.string}
        </p>
      </div>
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text="Explore Intelligent Routing"
        onClick={_ => onExploreClick()}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
      <p className="text-xs text-nd_gray-400">
        {"Experience Simulator, No Credentials Required !"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-2 gap-x-10 gap-y-6 w-full max-w-2xl mt-2">
      {features
      ->Array.map(((iconName, bgColor, iconColor, title, description)) => {
        <div key=title className="flex flex-row gap-3 items-start">
          <div className={`${bgColor} rounded-xl p-2 flex-shrink-0`}>
            <Icon name=iconName size=24 className=iconColor />
          </div>
          <div className="flex flex-col gap-0.5">
            <p className="font-semibold text-nd_gray-700 text-sm">{title->React.string}</p>
            <p className="text-nd_gray-500 text-xs font-normal">{description->React.string}</p>
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}
