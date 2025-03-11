@react.component
let make = () => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <img alt="vaultOnboarding" src="/assets/VaultOnboarding.svg" />
    <div className="flex flex-col gap-8 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
        {"Intelligent Routing"->React.string}
      </div>
      <PageUtils.PageHeading
        customHeadingStyle="gap-3 flex flex-col items-center"
        title="Intelligent Routing"
        customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-500"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Rule based and ML based algorithm to uplift auth rates."
      />
      <Button
        text="Try Demo"
        onClick={_ => {
          setShowSideBar(_ => false)
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v2/intelligent-routing/onboarding"),
          )
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
  </div>
}
