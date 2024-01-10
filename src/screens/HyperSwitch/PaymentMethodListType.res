type paymentMethod =
  Cards | Wallets | PayLater | BankRedirect | BankTransfer | BankDebit | Crypto | NONE

type cardType = Credit | Debit
type paymentMethodType =
  Card(cardType) | Klarna | Affirm | AfterPay | Gpay | Paypal | ApplePay | CryptoCurrency | NONE
type paymentExperienceType = RedirectToURL | InvokeSDK
type paymentExperience = {
  payment_experience_type: paymentExperienceType,
  eligible_connectors: array<string>,
}
type bankNames = {
  bank_name: array<string>,
  eligible_connectors: array<string>,
}

let getPaymentExperienceType = str => {
  switch str {
  | "redirect_to_url" => RedirectToURL
  | "invoke_sdk_client" => InvokeSDK
  | _ => RedirectToURL
  }
}
open LogicUtils
let getPaymentExperience = (dict, str) => {
  dict
  ->Dict.get(str)
  ->Belt.Option.flatMap(Js.Json.decodeArray)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Array.map(json => {
    {
      payment_experience_type: getString(
        json,
        "payment_experience_type",
        "",
      )->getPaymentExperienceType,
      eligible_connectors: getStrArray(json, "eligible_connectors"),
    }
  })
}

let getBankNames = (dict, str) => {
  dict
  ->Dict.get(str)
  ->Belt.Option.flatMap(Js.Json.decodeArray)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Array.map(json => {
    {
      bank_name: getStrArray(json, "bank_name"),
      eligible_connectors: getStrArray(json, "eligible_connectors"),
    }
  })
}

let getAchConnectors = (dict, str) => {
  dict
  ->Dict.get(str)
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.getWithDefault(Dict.make())
  ->getStrArray("elligible_connectors")
}
