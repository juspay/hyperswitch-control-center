open ConnectorTypes
open LogicUtils
let getPMFromString = paymentMethod => {
  switch paymentMethod->String.toLowerCase {
  | "card" => Card
  | "debit" | "credit" => Card
  | "pay_later" => PayLater
  | "wallet" => Wallet
  | "bank_redirect" => BankRedirect
  | "bank_transfer" => BankTransfer
  | "crypto" => Crypto
  | "bank_debit" => BankDebit
  | _ => UnknownPaymentMethod(paymentMethod)
  }
}

let getPMTFromString = paymentMethodType => {
  switch paymentMethodType->String.toLowerCase {
  | "credit" => Credit
  | "debit" => Debit
  | "google_pay" => GooglePay
  | "apple_pay" => ApplePay
  | "paypal" => PayPal
  | "klarna" => Klarna
  | "open_banking_pis" => OpenBankingPIS
  | "samsung_pay" => SamsungPay
  | "paze" => Paze
  | "alipay" => AliPay
  | "wechatpay" => WeChatPay
  | "directcarrierbilling" => DirectCarrierBilling
  | _ => UnknownPaymentMethodType(paymentMethodType)
  }
}

let getPaymentExperience = (connector, pm, pmt, pme) => {
  switch pm->getPMFromString {
  | BankRedirect => None
  | _ =>
    switch (ConnectorUtils.getConnectorNameTypeFromString(connector), pmt->getPMTFromString) {
    | (Processors(PAYPAL), PayPal) | (Processors(KLARNA), Klarna) => pme
    | (Processors(ZEN), GooglePay) | (Processors(ZEN), ApplePay) => Some("redirect_to_url")
    | (Processors(BRAINTREE), PayPal) => Some("invoke_sdk_client")
    | (Processors(GLOBALPAY), AliPay)
    | (Processors(GLOBALPAY), WeChatPay)
    | (Processors(STRIPE), WeChatPay) =>
      Some("display_qr_code")
    | (_, GooglePay)
    | (_, ApplePay)
    | (_, SamsungPay)
    | (_, Paze) =>
      Some("invoke_sdk_client")
    | (_, DirectCarrierBilling) => Some("collect_otp")
    | _ => Some("redirect_to_url")
    }
  }
}

let acceptedValues = dict => {
  let values = {
    type_: dict->getString("type", "enable_only"),
    list: dict->getStrArray("list"),
  }
  values.list->Array.length > 0 ? Some(values) : None
}

let getPaymentMethodDictV2 = (dict, pm, connector): ConnectorTypes.paymentMethodConfigTypeV2 => {
  let paymentMethodType =
    dict->getString("payment_method_subtype", dict->getString("payment_method_type", ""))
  let (cardNetworks, modifedPaymentMethodType) = switch pm->getPMTFromString {
  | Credit => {
      let cardNetworks = [paymentMethodType->JSON.Encode.string]
      let pmt = pm
      (cardNetworks, pmt)
    }
  | Debit => {
      let cardNetworks = [paymentMethodType->JSON.Encode.string]
      let pmt = pm
      (cardNetworks, pmt)
    }

  | _ => {
      let pmt = paymentMethodType
      ([], pmt)
    }
  }
  let cardNetworks = dict->getArrayFromDict("card_networks", cardNetworks)
  let minimumAmount = dict->getInt("minimum_amount", 0)
  let maximumAmount = dict->getInt("maximum_amount", 68607706)
  let recurringEnabled = dict->getBool("recurring_enabled", true)
  let installmentPaymentEnabled = dict->getBool("installment_payment_enabled", true)

  let paymentExperience = dict->getOptionString("payment_experience")
  let pme = getPaymentExperience(connector, pm, modifedPaymentMethodType, paymentExperience)
  let newPaymentMenthodDict =
    [
      ("payment_method_subtype", modifedPaymentMethodType->JSON.Encode.string),
      ("card_networks", cardNetworks->JSON.Encode.array),
      ("minimum_amount", minimumAmount->JSON.Encode.int),
      ("maximum_amount", maximumAmount->JSON.Encode.int),
      ("recurring_enabled", recurringEnabled->JSON.Encode.bool),
      ("installment_payment_enabled", installmentPaymentEnabled->JSON.Encode.bool),
    ]->Dict.fromArray
  newPaymentMenthodDict->setOptionString("payment_experience", pme)
  newPaymentMenthodDict->ConnectorInterfaceUtils.getPaymentMethodTypesV2
}

let getPaymentMethodMapper = (arr, connector, pm) => {
  arr->Array.map(val => {
    let dict = val->getDictFromJsonObject
    getPaymentMethodDictV2(dict, pm, connector)
  })
}

let pmIcon = pm =>
  switch pm->getPMFromString {
  | Card => "card"
  | PayLater => "pay_later"
  | Wallet => "nd-wallet"
  | BankRedirect | BankDebit | BankTransfer => "nd-bank"
  | _ => ""
  }

let checkKlaranRegion = (connData: connectorPayloadV2) =>
  switch connData.metadata
  ->getDictFromJsonObject
  ->getString("klarna_region", "")
  ->String.toLowerCase {
  | "europe" => true
  | _ => false
  }

let pmtWithMetaData = [GooglePay, ApplePay, SamsungPay, Paze]

let isMetaDataRequired = (pmt, connector) => {
  pmtWithMetaData->Array.includes(pmt->getPMTFromString) &&
    {
      switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(TRUSTPAY)
      | Processors(STRIPE_TEST) => false
      | _ => true
      }
    }
}
