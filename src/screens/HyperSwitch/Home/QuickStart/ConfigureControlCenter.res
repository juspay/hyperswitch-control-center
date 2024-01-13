@react.component
let make = () => {
  open QuickStartTypes

  let {quickStartPageState, setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)

  let landingButtonGroup = {
    <div className="flex flex-col gap-4 w-full">
      <Button
        text="Go to Home"
        buttonType={Primary}
        onClick={_ => {
          setDashboardPageState(_ => #HOME)
          RescriptReactRouter.replace("/home")
        }}
      />
    </div>
  }

  <div className="h-screen w-full bg-blue-background_blue">
    {switch quickStartPageState {
    | ConnectProcessor(connectProcessorValue) => <ConfigureConnector connectProcessorValue />
    | IntegrateApp(integrateAppValue) => <IntegrateYourAppLanding integrateAppValue />
    | GoLive(goLive) => <GoLive goLive />
    | FinalLandingPage =>
      <div className="h-screen flex items-center justify-center">
        <QuickStartUIUtils.StepCompletedPage
          headerText="Yay! you have successfully completed the setup!"
          buttonGroup={landingButtonGroup}
        />
      </div>
    }}
  </div>
}
