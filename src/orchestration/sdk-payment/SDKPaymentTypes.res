type clientSecretStatus = IntialPreview | Loading | Success | Error
type address = {
  line1: string,
  line2: string,
  city: string,
  state: string,
  zip: string,
  country: string,
  first_name: string,
  last_name: string,
}

type phone = {
  number: string,
  country_code: string,
}

type addressAndPhone = {
  address: address,
  phone: phone,
}

type paymentType = {
  amount: float,
  currency: string,
  profile_id: string,
  customer_id: option<string>,
  description: string,
  capture_method: string,
  email: Nullable.t<string>,
  authentication_type: option<string>,
  shipping: option<addressAndPhone>,
  billing: option<addressAndPhone>,
  setup_future_usage: option<string>,
  country_currency?: string,
  show_saved_card?: string,
  request_external_three_ds_authentication: bool,
}

type statusConfig = {
  iconName: string,
  statusText: string,
  bgColor: string,
  showErrorMessage: bool,
}

type sdkContextType = {
  showBillingAddress: bool,
  setShowBillingAddress: (bool => bool) => unit,
  isSameAsBilling: bool,
  setIsSameAsBilling: (bool => bool) => unit,
  sdkThemeInitialValues: JSON.t,
  setSdkThemeInitialValues: (JSON.t => JSON.t) => unit,
  keyForReRenderingSDK: string,
  setKeyForReRenderingSDK: (string => string) => unit,
  paymentStatus: ReactHyperJs.paymentStatus,
  setPaymentStatus: (ReactHyperJs.paymentStatus => ReactHyperJs.paymentStatus) => unit,
  paymentResult: JSON.t,
  setPaymentResult: (JSON.t => JSON.t) => unit,
  errorMessage: string,
  setErrorMessage: (string => string) => unit,
  isGuestMode: bool,
  setIsGuestMode: (bool => bool) => unit,
  showSetupFutureUsage: bool,
  setShowSetupFutureUsage: (bool => bool) => unit,
  sendAuthType: bool,
  setSendAuthType: (bool => bool) => unit,
  initialValuesForCheckoutForm: paymentType,
  setInitialValuesForCheckoutForm: (paymentType => paymentType) => unit,
  clientSecretStatus: clientSecretStatus,
  setClientSecretStatus: (clientSecretStatus => clientSecretStatus) => unit,
}
