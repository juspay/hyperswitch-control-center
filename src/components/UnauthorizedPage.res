@react.component
let make = (
  ~message="You don't have access to this module. Contact admin for access",
  ~url="unauthorized",
  ~productType=ProductTypes.Orchestration(V1),
) => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

  <NoDataFound message renderType={Locked}>
    <Button
      text={"Go to Home"}
      buttonType=Primary
      buttonSize=Small
      onClick={_ => {
        setDashboardPageState(_ => #HOME)
        let productUrl = ProductUtils.getProductUrl(~productType, ~isLiveMode)
        RescriptReactRouter.replace(productUrl)
      }}
      customButtonStyle="mt-4"
    />
  </NoDataFound>
}
