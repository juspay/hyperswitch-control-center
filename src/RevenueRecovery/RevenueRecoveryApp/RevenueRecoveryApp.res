@react.component
let make = () => {
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

  if activeProduct == Recovery {
    <RecoveryConnectorContainer />
  } else {
    <RevenueRecoveryOnboardingLanding createMerchant=true />
  }
}
