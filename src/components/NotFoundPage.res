@react.component
let make = (~message="Error 404!") => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)

  <NoDataFound message renderType={NotFound}>
    <Button
      text={"Go to Home"}
      buttonType=Primary
      buttonSize=Small
      onClick={_ => {
        setDashboardPageState(_ => #HOME)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
      }}
      customButtonStyle="mt-4"
    />
  </NoDataFound>
}
