@react.component
let make = (~createMerchant) => {
  open PageUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setCreateNewMerchant} = React.useContext(ProductSelectionProvider.defaultContext)
  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <img className="h-56" alt="recoveryOnboarging" src="/assets/DefaultHomeRecoveryCard.svg" />
    <div className="flex flex-col gap-7 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit mb-5">
        {"Recovery"->React.string}
      </div>
      <PageHeading
        customHeadingStyle="flex flex-col items-center"
        title="Never lose revenue to unwarranted churn"
        customTitleStyle="text-2xl text-center font-bold"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Maximize retention and recover failed transactions with automated retry strategies."
      />
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text={"Get Started"}
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
    </div>
  </div>
}
