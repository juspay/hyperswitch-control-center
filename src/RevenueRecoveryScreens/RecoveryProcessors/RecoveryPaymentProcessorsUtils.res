open ConnectorTypes

let connectorList: array<connectorTypes> = [
  Processors(STRIPE),
  Processors(ADYEN),
  Processors(CYBERSOURCE),
  Processors(GLOBALPAY),
  Processors(WORLDPAY),
  Processors(NOON),
  Processors(BANKOFAMERICA),
]

let connectorListForLive: array<connectorTypes> = [
  Processors(STRIPE),
  Processors(ADYEN),
  Processors(CYBERSOURCE),
  Processors(GLOBALPAY),
  Processors(WORLDPAY),
  Processors(NOON),
  Processors(BANKOFAMERICA),
]

let stepsArr = [IntegFields, Webhooks, SummaryAndTest]

let getStepName = step => {
  switch step {
  | IntegFields => "Authenticate your processor"
  | Webhooks => "Setup Webhook"
  | Preview
  | SummaryAndTest => "Review and Connect"
  | PaymentMethods => "Payment Methods"
  | AutomaticFlow => "AutomaticFlow"
  }
}
