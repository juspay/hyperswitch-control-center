@react.component
let make = (~createMerchant) => {
  open Typography
  open PageUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setCreateNewMerchant} = React.useContext(ProductSelectionProvider.defaultContext)
  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])

  <div className="flex flex-1 flex-col gap-6 items-center w-full">
    <object
      type_="image/svg+xml"
      data="/assets/RevenueRecoveryHomePreview.svg"
      className="w-4/5 rounded-2xl"
      ariaLabel="Revenue Recovery Dashboard Preview"
    />
    <div className="flex flex-col gap-4 items-center">
      <div className="flex flex-col gap-2 items-center">
        <p className={`${heading.md.bold} text-center text-nd_gray-700`}>
          {"Recover Lost Revenue & Minimize Churn"->React.string}
        </p>
        <p className={`${body.md.regular} text-center text-nd_gray-500 max-w-3xl`}>
          {"Harness smart retry strategies to automatically recover failed payments and protect your subscription revenue."->React.string}
        </p>
      </div>
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text="Explore Recovery"
        onClick={_ => {
          if createMerchant {
            mixpanelEvent(~eventName="recovery_get_started_new_merchant")
            setCreateNewMerchant(ProductTypes.Recovery)
          } else {
            mixpanelEvent(~eventName="recovery_get_started")
            RescriptReactRouter.replace(
              GlobalVars.appendDashboardPath(~url=`/v2/recovery/onboarding`),
            )
          }
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
      <p className={`${body.sm.regular} text-nd_gray-400`}>
        {"Experience Hasslefree Demo, No Credentials Required !"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-10 gap-y-6 w-full max-w-2xl mt-2">
      {RevenueRecoveryOnboardingUtils.features
      ->Array.map(feature => {
        <div key=feature.title className="flex flex-row gap-3 items-start">
          <div
            className={`${feature.bgColor} rounded-xl w-12 h-12 flex-shrink-0 flex items-center justify-center`}>
            <Icon
              name=feature.icon
              size=28
              className=feature.iconColor
              parentClass="w-full h-full flex items-center justify-center"
            />
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
