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
