open SDKPaymentTypes

let defaultValue = {
  showBillingAddress: true,
  setShowBillingAddress: _ => (),
  isSameAsBilling: true,
  setIsSameAsBilling: _ => (),
  sdkThemeInitialValues: SDKPaymentUtils.themeDefaultJson,
  setSdkThemeInitialValues: _ => (),
  keyForReRenderingSDK: Date.now()->Float.toString,
  setKeyForReRenderingSDK: _ => (),
  paymentStatus: INCOMPLETE,
  setPaymentStatus: _ => (),
  paymentResult: JSON.Encode.null,
  setPaymentResult: _ => (),
  errorMessage: "",
  setErrorMessage: _ => (),
  isGuestMode: false,
  setIsGuestMode: _ => (),
  initialValuesForCheckoutForm: SDKPaymentUtils.initialValueForForm(
    BusinessProfileMapper.businessProfileTypeMapper(JSON.Encode.null),
  ),
  setInitialValuesForCheckoutForm: _ => (),
  clientSecretStatus: IntialPreview,
  setClientSecretStatus: _ => (),
}

let defaultContext = React.createContext(defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  open ReactHyperJs

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )

  let (showBillingAddress, setShowBillingAddress) = React.useState(_ => true)
  let (isSameAsBilling, setIsSameAsBilling) = React.useState(() => true)
  let (sdkThemeInitialValues, setSdkThemeInitialValues) = React.useState(_ =>
    SDKPaymentUtils.themeDefaultJson
  )
  let (keyForReRenderingSDK, setKeyForReRenderingSDK) = React.useState(_ =>
    Date.now()->Float.toString
  )
  let (paymentStatus, setPaymentStatus) = React.useState(_ => INCOMPLETE)
  let (clientSecretStatus, setClientSecretStatus) = React.useState(_ => IntialPreview)

  let (paymentResult, setPaymentResult) = React.useState(_ => JSON.Encode.null)
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (isGuestMode, setIsGuestMode) = React.useState(_ => false)

  let (initialValuesForCheckoutForm, setInitialValuesForCheckoutForm) = React.useState(_ =>
    SDKPaymentUtils.initialValueForForm(businessProfileRecoilVal)
  )

  <Provider
    value={
      showBillingAddress,
      setShowBillingAddress,
      isSameAsBilling,
      setIsSameAsBilling,
      sdkThemeInitialValues,
      setSdkThemeInitialValues,
      keyForReRenderingSDK,
      setKeyForReRenderingSDK,
      paymentStatus,
      setPaymentStatus,
      paymentResult,
      setPaymentResult,
      errorMessage,
      setErrorMessage,
      isGuestMode,
      setIsGuestMode,
      initialValuesForCheckoutForm,
      setInitialValuesForCheckoutForm,
      clientSecretStatus,
      setClientSecretStatus,
    }>
    children
  </Provider>
}
