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

let getPayViaSingleUseTokenValues = (initialValues, ~config) => {
  let savedValues =
    initialValues
    ->getDictFromJsonObject
    ->getArrayFromDict("payment_methods_enabled", [])
    ->Array.flatMap(paymentMethod =>
      paymentMethod->getDictFromJsonObject->getArrayFromDict("payment_method_types", [])
    )
    ->Array.filterMap(paymentMethodType => {
      let dict = paymentMethodType->getDictFromJsonObject
      dict
      ->getOptionString("pay_via_single_use_token")
      ->Option.map(value => (dict->getString("payment_method_type", ""), value))
    })
    ->Dict.fromArray
  config
  ->Dict.keysToArray
  ->Array.map(paymentMethodType => (
    paymentMethodType,
    savedValues
    ->Dict.get(paymentMethodType)
    ->Option.getOr((#default: payViaSingleUseTokenValue :> string))
    ->JSON.Encode.string,
  ))
  ->getJsonFromArrayOfJson
}

let applyPayViaSingleUseToken = (paymentMethodsEnabled, ~config, ~formValues) => {
  let values = formValues->getDictFromJsonObject->getDictfromDict("pay_via_single_use_token")
  paymentMethodsEnabled->mapProviders(provider => {
    let paymentMethodType = provider.payment_method_type
    switch config->getPayViaSingleUseTokenEntry(~paymentMethodType) {
    | Some(_) => {
        ...provider,
        pay_via_single_use_token: ?(
          config
          ->getPayViaSingleUseTokenField(~formValues, ~paymentMethodType)
          ->Option.flatMap(_ => values->getOptionString(paymentMethodType))
        ),
      }
    | None => provider
    }
  })
}
