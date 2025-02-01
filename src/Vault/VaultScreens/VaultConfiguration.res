@react.component
let make = () => {
  open PageUtils

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
        customTitleStyle="text-2xl text-center font-bold"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Learn how to vault cards from your Server if you're PCI compliant and Learn how to vault cards using Hyperswitch's Checkout if you're non-PCI compliant"
      />
      <Button
        text="Get Started"
        onClick={_ => {
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v2/recon/configuration"),
          )
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
    <div className="flex gap-4 max-w-800">
      <div
        className="border rounded-lg p-3 flex items-center gap-4 shadow-cardShadow group cursor-pointer">
        <img alt="vaultServerImage" src="/assets/VaultServerImage.svg" />
        <div className="flex flex-col gap-1">
          <p className="text-sm font-semibold">
            {"Learn how to vault from your server"->React.string}
          </p>
          <p className="text-xs text-nd_gray-400 font-normal">
            {"If you're PCI compliant, you can vault cards directly to Hyperswitch's Vault service from your server."->React.string}
          </p>
        </div>
        <Icon name="angle-right" size=16 className="group-hover:scale-125" />
      </div>
      <div
        className="border rounded-lg p-3 flex items-center gap-4 shadow-cardShadow cursor-pointer group">
        <img alt="vaultSdkImage" src="/assets/VaultSdkImage.svg" />
        <div className="flex flex-col gap-1">
          <p className="text-sm font-semibold">
            {"Learn using Hyperswitch vault SDK"->React.string}
          </p>
          <p className="text-xs text-nd_gray-400 font-normal">
            {"If you're not PCI compliant, securely store cards using our Vault SDK with Hyperswitch's Vault service."->React.string}
          </p>
        </div>
        <Icon name="angle-right" size=16 className="group-hover:scale-125" />
      </div>
    </div>
  </div>
}
