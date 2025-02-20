module Links = {
  @react.component
  let make = (~title, ~subTitle="", ~icon="") => {
    <div
      className="border rounded-lg p-3 flex items-center gap-4 shadow-cardShadow group cursor-pointer">
      <img alt="vaultServerImage" src=icon />
      <div className="flex flex-col gap-1">
        <p className="text-sm font-semibold"> {title->React.string} </p>
        <p className="text-xs text-nd_gray-400 font-normal"> {subTitle->React.string} </p>
      </div>
      <Icon name="angle-right" size=16 className="group-hover:scale-125" />
    </div>
  }
}

@react.component
let make = () => {
  open PageUtils

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <img alt="recoveryOnboarging" src="/assets/recoveryOnboarging.svg" />
    <div className="flex flex-col gap-8 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
        {"Recovery"->React.string}
      </div>
      <PageHeading
        customHeadingStyle="gap-3 flex flex-col items-center"
        title="Never lose revenue to unwarranted churn"
        customTitleStyle="text-2xl text-center font-bold"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Ability to store and retrieve sensitive data in an isolated manner (for e.g. PCI/PII sensitive data)"
      />
      <Button
        text="Get Started"
        onClick={_ => {
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v2/recovery/onboarding"),
          )
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
    <div className="flex gap-4 max-w-800">
      <Links
        title="Set up API Keys"
        subTitle="One Liner about this task"
        icon="/assets/VaultServerImage.svg"
      />
      <Links
        title="Developer Docs" subTitle="One Liner about this task" icon="/assets/VaultSdkImage.svg"
      />
    </div>
  </div>
}
