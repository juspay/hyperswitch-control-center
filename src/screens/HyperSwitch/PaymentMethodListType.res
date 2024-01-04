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
type paymentMethodTypes = {
  payment_method_type: string,
  payment_experience: array<paymentExperience>,
  card_networks: string,
  bank_names: array<bankNames>,
  bank_debits_connectors: array<string>,
  bank_transfers_connectors: array<string>,
}

type methods = {
  payment_method: paymentMethod,
  payment_method_types: array<paymentMethodTypes>,
}

let getMethod = str => {
  switch str {
  | "card" => Cards
  | "wallet" => Wallets
  | "pay_later" => PayLater
  | "bank_redirect" => BankRedirect
  | "bank_transfer" => BankTransfer
  | "bank_debit" => BankDebit
  | "crypto" => Crypto
  | _ => NONE
  }
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

let getPaymentMethodTypes = (dict, str) => {
  dict
  ->Dict.get(str)
  ->Belt.Option.flatMap(Js.Json.decodeArray)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Array.map(json => {
    {
      payment_method_type: getString(json, "payment_method_type", ""),
      payment_experience: getPaymentExperience(json, "payment_experience"),
      card_networks: getString(json, "card_networks", ""),
      bank_names: getBankNames(json, "bank_names"),
      bank_debits_connectors: getAchConnectors(json, "bank_debit"),
      bank_transfers_connectors: getAchConnectors(json, "bank_transfer"),
    }
  })
}

let getMethodsArr = (dict, str) => {
  dict
  ->Dict.get(str)
  ->Belt.Option.flatMap(Js.Json.decodeArray)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Array.map(json => {
    {
      payment_method: getString(json, "payment_method", "")->getMethod,
      payment_method_types: getPaymentMethodTypes(json, "payment_method_types"),
    }
  })
}
