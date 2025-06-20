@react.component
let make = (~message="Error 404!") => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let url = RescriptReactRouter.useUrl()

  React.useEffect(() => {
    HyperSwitchAppUtils.setupProductUrl(~productType=Some(activeProduct), ~url)
    None
  }, [])

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
