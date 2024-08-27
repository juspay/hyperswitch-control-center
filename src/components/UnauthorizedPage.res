@react.component
let make = (
  ~message="You don't have access to this module. Contact admin for access",
  ~url="unauthorized",
) => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  React.useEffect(() => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/unauthorized"))
    None
  }, [])
  <NoDataFound message renderType={Locked}>
    <Button
      text={"Go to Home"}
      buttonType=Primary
      onClick={_ => {
        setDashboardPageState(_ => #HOME)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
      }}
      customButtonStyle="mt-4 !p-2"
    />
  </NoDataFound>
}
