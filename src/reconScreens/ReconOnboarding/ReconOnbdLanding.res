@react.component
let make = () => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let onClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/configuration"))
    setShowSideBar(prev => !prev)
  }
  <div className="flex flex-col w-full gap-6 items-center py-14 px-10">
    <img alt="reconLanding" className="w-[453px] h-[348px]" src="/Recon/landing.svg" />
    <p className="border border-green-400 px-2 py-1 rounded-lg text-sm text-green-500">
      {"Recon"->React.string}
    </p>
    <Button
      text="Get Started"
      rightIcon={CustomIcon(<Icon name="nd-arrow-right" size=10 />)}
      onClick={_ => onClick()}
      buttonType=Primary
      buttonSize=Large
      buttonState=Normal
    />
  </div>
}
