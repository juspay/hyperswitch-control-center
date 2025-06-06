@react.component
let make = (
  ~message="You don't have access to this module. Contact admin for access",
  ~url="unauthorized",
  ~productType=ProductTypes.Orchestration,
) => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)

  let showSidebar = () => {
    setShowSideBar(_ => true)
  }

  React.useEffect(() => {
    showSidebar()
    None
  }, [])

  <NoDataFound message renderType={Locked}>
    <Button
      text={"Go to Home"}
      buttonType=Primary
      buttonSize=Small
      onClick={_ => {
        setDashboardPageState(_ => #HOME)
        let productUrl = ProductUtils.getProductUrl(~productType, ~url="v2/home")
        RescriptReactRouter.replace(productUrl)
      }}
      customButtonStyle="mt-4"
    />
  </NoDataFound>
}
