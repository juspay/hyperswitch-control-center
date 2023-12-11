type hyperPromise
type sdkType = ELEMENT | WIDGET
type paymentStatus =
  SUCCESS | INCOMPLETE | FAILED | LOADING | PROCESSING | CHECKCONFIGURATION | CUSTOMSTATE
type confirmParamType = {return_url: string}
type confirmPaymentObj = {confirmParams: confirmParamType}
type appearanceType = {theme: string}
type options
type options2
type options1
type dataValueType
type dataType = {
  elementType: string,
  complete: bool,
  empty: bool,
  collapsed: bool,
  value: dataValueType,
}
type hyperType = {
  clientSecret: string,
  confirmPayment: Js.Json.t => Promise.t<Js.Json.t>,
  retrievePaymentIntent: string => Promise.t<Js.Json.t>,
  paymentRequest: Js.Json.t => Js.Json.t,
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
