@react.component
let make = () => {
  open PageUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setCreateNewMerchant} = React.useContext(ProductSelectionProvider.defaultContext)
  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <img alt="hypersenseOnboarding" src="/assets/DefaultHomeHypersenseCard.svg" />
    <div className="flex flex-col gap-8 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
        {"Cost Observability"->React.string}
      </div>
      <PageHeading
        customHeadingStyle="gap-3 flex flex-col items-center"
        title="AI Ops tool built for Payments Cost Observability "
        customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-500"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Audit, Observe and Optimize payment costs to uncover cost-saving opportunities"
      />
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text="Get Started"
        onClick={_ => {
          mixpanelEvent(~eventName="cost_observability_get_started_new_merchant")
          setCreateNewMerchant(ProductTypes.CostObservability)
        }}
        customTextPaddingClass="pr-0"
        rightIcon={CustomIcon(<Icon name="nd-angle-right" size=16 className="cursor-pointer" />)}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
  </div>
}
