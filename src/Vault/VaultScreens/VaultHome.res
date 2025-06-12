@react.component
let make = () => {
  open PageUtils
  let {setCreateNewMerchant} = React.useContext(ProductSelectionProvider.defaultContext)

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <object type_="image/svg+xml" data="/assets/VaultOnboarding.svg" alt="vaultOnboarding" />
    <div className="flex flex-col gap-8 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
        {"Vault"->React.string}
      </div>
      <PageHeading
        customHeadingStyle="gap-3 flex flex-col items-center"
        title="Securely store your users's sensitive data"
        customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-500"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Learn how to vault cards from your Server if you're PCI compliant and learn how to vault cards using Hyperswitch's Checkout if you're non-PCI compliant"
      />
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text="Get Started"
        onClick={_ => {
          mixpanelEvent(~eventName="vault_get_started_create_merchant")
          setCreateNewMerchant(ProductTypes.Vault)
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
  </div>
}
