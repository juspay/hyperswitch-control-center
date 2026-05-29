open Typography

type feature = {
  icon: string,
  bgColor: string,
  iconColor: string,
  title: string,
  description: string,
}

let features: array<feature> = [
  {
    icon: "arrow-increasing",
    bgColor: "bg-nd_orange-150",
    iconColor: "text-nd_orange-300",
    title: "Dynamic Authorization Optimization",
    description: "Maximizes approval rates by routing to best-performing processors.",
  },
  {
    icon: "nd-swap-arrow-horizontal",
    bgColor: "bg-nd_purple-200",
    iconColor: "text-nd_purple-300",
    title: "Adaptive Fallback & Rerouting",
    description: "Automatically reroutes payments during outages or declines, ensuring uninterrupted payment flows.",
  },
  {
    icon: "routing",
    bgColor: "bg-pink-100",
    iconColor: "text-pink-500",
    title: "Cost-Efficient Routing",
    description: "Optimizes paths to minimize processing and network scheme fees, enhancing your bottom line.",
  },
  {
    icon: "filter",
    bgColor: "bg-teal-100",
    iconColor: "text-teal-500",
    title: "Customizable Routing Rules",
    description: "Define preferences based on payment method, currency, region, and more.",
  },
]

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

  <div className="flex flex-1 flex-col gap-6 items-center w-full">
    <object
      type_="image/svg+xml"
      data="/assets/IntelligentRoutingHomePreview.svg"
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
      ->Array.map(feature => {
        <div key=feature.title className="flex flex-row gap-3 items-start">
          <div className={`${feature.bgColor} rounded-xl w-12 h-12 flex-shrink-0 flex items-center justify-center`}>
            <Icon name=feature.icon size=28 className=feature.iconColor />
          </div>
          <div className="flex flex-col gap-0.5">
            <p className={`${body.md.semibold} text-nd_gray-700`}>{feature.title->React.string}</p>
            <p className={`${body.sm.regular} text-nd_gray-500`}>
              {feature.description->React.string}
            </p>
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}
