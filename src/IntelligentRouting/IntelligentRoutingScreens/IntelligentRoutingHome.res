open Typography
open IntelligentRoutingTypes

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
        <p className={`${heading.md.bold} text-center text-nd_gray-700`}>
          {"Maximize Payment Success & Optimize Costs"->React.string}
        </p>
        <p className={`${body.md.regular} text-center text-nd_gray-500 max-w-lg`}>
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
      <p className={`${body.sm.regular} text-nd_gray-400`}>
        {"Experience Simulator, No Credentials Required !"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-2 gap-x-10 gap-y-6 w-full max-w-2xl mt-2">
      {IntelligentRoutingUtils.features
      ->Array.map(feature => {
        <div key=feature.title className="flex flex-row gap-3 items-start">
          <div
            className={`${feature.bgColor} rounded-xl w-12 h-12 flex-shrink-0 flex items-center justify-center`}>
            <Icon name=feature.icon size=28 className=feature.iconColor />
          </div>
          <div className="flex flex-col gap-0.5">
            <p className={`${body.md.semibold} text-nd_gray-700`}>
              {feature.title->React.string}
            </p>
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
