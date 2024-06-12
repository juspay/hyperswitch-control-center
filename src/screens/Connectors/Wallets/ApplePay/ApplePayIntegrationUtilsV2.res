open ApplePayIntegrationTypesV2

let paymentRequestData = {
  label: "apple",
  supported_networks: ["visa", "masterCard", "amex", "discover"],
  merchant_capabilities: ["supports3DS"],
}
