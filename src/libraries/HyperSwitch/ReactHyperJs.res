type hyperloader
type hyperPromise = promise<hyperloader>
type sdkType = ELEMENT | WIDGET
type paymentStatus =
  SUCCESS | INCOMPLETE | FAILED(string) | LOADING | PROCESSING | CHECKCONFIGURATION | CUSTOMSTATE
type confirmParamType = {return_url: string}
type confirmPaymentObj = {confirmParams: confirmParamType}
type options
type options2
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
type layout = {
  \"type": string,
  defaultCollapsed: bool,
  radios: bool,
  spacedAccordionItems: bool,
}
type layoutType = {
  layout: layout,
  paymentMethodOrder?: array<string>,
}
type appearanceTestType = {theme: string}
type optionsTest = {
  clientSecret: string,
  appearance: appearanceTestType,
  hideIcon: bool,
}
type country = {
  isoAlpha3: string,
  currency: string,
  countryName: string,
  isoAlpha2: string,
}
type variables = {
  fontFamily: string,
  colorPrimary: string,
  fontSizeBase: string,
  colorBackground: string,
}
type appearanceType = {
  theme: string,
  variables: variables,
  rules: JSON.t,
}
type updateType = {appearance: appearanceType}

@module("@juspay-tech/hyper-js")
external loadHyper: string => hyperPromise = "loadHyper"

@module("@juspay-tech/react-hyper-js")
external useHyper: unit => hyperType = "useHyper"
@module("@juspay-tech/react-hyper-js")
external useElements: unit => hyperType = "useElements"

module Elements = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (
    ~options: options,
    ~stripe: hyperPromise,
    ~children: React.element,
  ) => React.element = "Elements"
}

module PaymentElement = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: options2) => React.element = "PaymentElement"
}

module CardWidget = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: options2) => React.element = "CardWidget"
}

module ElementsTest = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (
    ~options: optionsTest,
    ~stripe: hyperPromise,
    ~children: React.element,
  ) => React.element = "Elements"
}

module PaymentElementTest = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: options2) => React.element = "PaymentElement"
}
