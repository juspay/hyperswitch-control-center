open LogicUtils
open ConnectorTypes

let getPayViaSingleUseTokenField = (config, ~formValues, ~paymentMethodType) => {
  open ConnectorUtils
  open ApplePayIntegrationUtils
  open GPayFlowUtils
  open CommonConnectorUtils
  let values = formValues->getDictFromJsonObject
  let walletFlow: walletFlow = switch paymentMethodType->getPaymentMethodTypeFromString {
  | ApplePay if values->isApplePayDecryptFlow => Decrypt
  | GooglePay if values->isGooglePayDecryptFlow => Decrypt
  | _ => Encrypt
  }
  let entry = config->getJsonObjectFromDict(paymentMethodType)->convertMapObjectToDict
  entry->getStrArrayFromDict("flows", [])->Array.includes((walletFlow :> string))
    ? Some(entry->inputFieldMapper)
    : None
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
  paymentMethodsEnabled->mapProviders(provider =>
    config
    ->getPayViaSingleUseTokenField(~formValues, ~paymentMethodType=provider.payment_method_type)
    ->Option.isSome
      ? provider
      : {...provider, pay_via_single_use_token: ?None}
  )
