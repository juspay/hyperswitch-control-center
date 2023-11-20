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
type paymentElement = {update: Js.Json.t => unit}
type hyperType = {
  clientSecret: string,
  confirmPayment: Js.Json.t => Promise.t<Js.Json.t>,
  retrievePaymentIntent: string => Promise.t<Js.Json.t>,
  paymentRequest: Js.Json.t => Js.Json.t,
  getElement: string => Js.nullable<paymentElement>,
  update: Js.Json.t => unit,
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
  rules: Js.Json.t,
}
type updateType = {appearance: appearanceType}
