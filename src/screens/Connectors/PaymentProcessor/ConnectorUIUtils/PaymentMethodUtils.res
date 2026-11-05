open LogicUtils
open ConnectorTypes
open ConnectorUtils

let getPayViaSingleUseTokenField = (config, ~formValues, ~paymentMethodType) => {
  open ApplePayIntegrationUtils
  open GPayFlowUtils
  open CommonConnectorUtils
  let values = formValues->getDictFromJsonObject
  let walletFlow: walletFlow = switch paymentMethodType->getPaymentMethodTypeFromString {
  | ApplePay if values->isApplePayDecryptFlow => Decrypt
  | GooglePay if values->isGooglePayDecryptFlow => Decrypt
  | _ => Encrypt
  }
  config
  ->getPayViaSingleUseTokenEntry(~paymentMethodType)
  ->Option.filter(entry => entry->isPayViaSingleUseTokenFlow(walletFlow))
  ->Option.map(inputFieldMapper)
}

let mapProviders = (paymentMethodsEnabled: array<paymentMethodEnabled>, fn) =>
  paymentMethodsEnabled->Array.map(paymentMethodObj => {
    ...paymentMethodObj,
    provider: ?paymentMethodObj.provider->Option.map(providers => providers->Array.map(fn)),
  })

let updatePayViaSingleUseToken = (paymentMethodsEnabled, ~paymentMethodType, ~value) =>
  paymentMethodsEnabled->mapProviders(provider =>
    provider.payment_method_type === paymentMethodType
      ? {...provider, pay_via_single_use_token: ?value}
      : provider
  )

let removeInapplicablePayViaSingleUseToken = (paymentMethodsEnabled, ~config, ~formValues) =>
  paymentMethodsEnabled->mapProviders(provider => {
    let paymentMethodType = provider.payment_method_type
    let isInapplicable =
      config->getPayViaSingleUseTokenEntry(~paymentMethodType)->Option.isSome &&
        config->getPayViaSingleUseTokenField(~formValues, ~paymentMethodType)->Option.isNone
    isInapplicable ? {...provider, pay_via_single_use_token: ?None} : provider
  })
