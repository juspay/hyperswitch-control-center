@react.component
let make = () => {
  open PageUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()

  <div className="flex flex-1 flex-col w-full gap-14 items-center justify-center w-full h-screen">
    <img alt="vaultOnboarding" src="/assets/VaultOnboarding.svg" />
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
    </div>
    <div className="flex gap-4 w-full justify-center">
      <Button
        text="Processor configuration"
        onClick={_ => {
          mixpanelEvent(~eventName="vault_processor_configuration")
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/vault/onboarding"))
        }}
        buttonType={Primary}
        buttonSize=Large
        buttonState=Normal
      />
      <Button
        text="Customers & tokens"
        onClick={_ => {
          mixpanelEvent(~eventName="vault_customers_and_tokens")
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/vault/customers-tokens"))
        }}
        buttonType=Secondary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
  </div>
}
