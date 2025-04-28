type hyperloader
type hyperPromise = promise<hyperloader>

type paymentStatus =
  | SUCCESS
  | INCOMPLETE
  | FAILED(string)
  | LOADING
  | PROCESSING
  | CHECKCONFIGURATION
  | CUSTOMSTATE

type confirmParamType = {return_url: string}
type confirmPaymentObj = {confirmParams: confirmParamType}

type dataValueType

type dataType = {
  elementType: string,
  complete: bool,
  empty: bool,
  collapsed: bool,
  value: dataValueType,
}

type paymentElement = {update: JSON.t => unit}

type hyperType = {
  clientSecret: string,
  confirmPayment: JSON.t => Promise.t<JSON.t>,
  retrievePaymentIntent: string => Promise.t<JSON.t>,
  paymentRequest: JSON.t => JSON.t,
  getElement: string => Js.nullable<paymentElement>,
  update: JSON.t => unit,
}

type styleForWallets = {
  theme?: string,
  type_?: string,
  height?: int,
}

type wallets = {
  walletReturnUrl: string,
  applePay?: string,
  googlePay?: string,
  style?: styleForWallets,
}

type checkoutElementOptions = {
  showCardFormByDefault?: bool,
  wallets?: wallets,
}

type variables = {
  fontFamily?: string,
  colorPrimary?: string,
  fontSizeBase?: string,
  colorBackground?: string,
}

type appearanceType = {
  theme?: string,
  labels?: string,
  innerLayout?: string,
  variables?: variables,
  rules?: JSON.t,
}

type optionsForElements = {
  clientSecret: string,
  appearance?: appearanceType,
  locale?: string,
  loader?: string,
}

type optionsTest = {
  clientSecret: string,
  appearance?: appearanceType,
  hideIcon?: bool,
}

type updateType = {appearance: appearanceType}

type country = {
  isoAlpha3: string,
  currency: string,
  countryName: string,
  isoAlpha2: string,
  icon: string,
}

type layout = {
  \"type"?: string,
  defaultCollapsed?: bool,
  radios?: bool,
  spacedAccordionItems?: bool,
}

type layoutType = {
  layout?: layout,
  paymentMethodOrder?: array<string>,
}

@module("@juspay-tech/hyper-js")
external loadHyper: string => hyperPromise = "loadHyper"

@module("@juspay-tech/react-hyper-js")
external useHyper: unit => hyperType = "useHyper"

@module("@juspay-tech/react-hyper-js")
external useWidgets: unit => hyperType = "useWidgets"

module Elements = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (
    ~options: optionsForElements,
    ~stripe: hyperPromise,
    ~children: React.element,
  ) => React.element = "Elements"
}

module PaymentElement = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: checkoutElementOptions) => React.element = "PaymentElement"
}
