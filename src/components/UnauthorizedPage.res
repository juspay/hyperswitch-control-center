@react.component
let make = (
  ~message="You don't have access to this module. Contact admin for access",
  ~url="unauthorized",
) => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)

  <NoDataFound message renderType={Locked}>
    <Button
      text={"Go to Home"}
      buttonType=Primary
      buttonSize=Small
      onClick={_ => {
        setDashboardPageState(_ => #HOME)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
      }}
      customButtonStyle="mt-4 !p-2"
    />
  </NoDataFound>
}
