open ConnectorTypes
open LogicUtils
let getPaymentExperience = (connector, pm, pmt, pme) => {
  switch pm->ConnectorUtils.getPaymentMethodFromString {
  | BankRedirect => None
  | _ =>
    switch (
      ConnectorUtils.getConnectorNameTypeFromString(connector),
      pmt->ConnectorUtils.getPaymentMethodTypeFromString,
    ) {
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

let itemProviderMapper = dict => {
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    accepted_countries: dict->getDictfromDict("accepted_countries")->ConnectorUtils.acceptedValues,
    accepted_currencies: dict
    ->getDictfromDict("accepted_currencies")
    ->ConnectorUtils.acceptedValues,
    minimum_amount: dict->getOptionInt("minimum_amount"),
    maximum_amount: dict->getOptionInt("maximum_amount"),
    recurring_enabled: dict->getOptionBool("recurring_enabled"),
    installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
    payment_experience: dict->getOptionString("payment_experience"),
    card_networks: dict->getStrArrayFromDict("card_networks", []),
  }
}

let getPaymentMethodDictV2 = (dict, pm, connector) => {
  Js.log(dict)
  let paymentMethodType = dict->getString("payment_method_type", "")
  let (
    cardNetworks,
    modifedPaymentMethodType,
  ) = switch pm->ConnectorUtils.getPaymentMethodTypeFromString {
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
  let paymentExperience = dict->getOptionString("payment_experience")
  // Js.log(paymentExperience)
  let pme = getPaymentExperience(connector, pm, modifedPaymentMethodType, paymentExperience)
  let newPaymentMenthodDict =
    [
      ("payment_method_type", modifedPaymentMethodType->JSON.Encode.string),
      ("card_networks", cardNetworks->JSON.Encode.array),
      ("minimum_amount", minimumAmount->JSON.Encode.int),
      ("maximum_amount", maximumAmount->JSON.Encode.int),
      ("recurring_enabled", recurringEnabled->JSON.Encode.bool),
    ]->Dict.fromArray
  newPaymentMenthodDict->setOptionString("payment_experience", pme)
  // Js.log(newPaymentMenthodDict)
  newPaymentMenthodDict->itemProviderMapper
}

let getPaymentMethodMapper = (arr, connector, pm) => {
  arr->Array.map(val => {
    let dict = val->getDictFromJsonObject
    // Js.log(dict)
    getPaymentMethodDictV2(dict, pm, connector)
  })
}

let pmIcon = pm =>
  switch pm->ConnectorUtils.getPaymentMethodFromString {
  | Card => "card"
  | PayLater => "pay_later"
  | Wallet => "nd-wallet"
  | BankRedirect | BankDebit | BankTransfer => "nd-bank"
  | _ => ""
  }

let getPMTIndex = (~connData, ~pmIndex, ~cardNetworks, ~pmt) => {
  if connData.payment_methods_enabled->Array.length > 0 {
    let t = connData.payment_methods_enabled->Array.get(pmIndex)

    let index = switch t {
    | Some(k) => {
        let isPMTEnabled = k.payment_method_types->Array.findIndex(val => {
          if (
            val.payment_method_type->ConnectorUtils.getPaymentMethodTypeFromString == Credit ||
              val.payment_method_type->ConnectorUtils.getPaymentMethodTypeFromString == Debit
          ) {
            val.card_networks->Array.some(networks => {
              cardNetworks->Array.includes(networks)
            })
          } else {
            val.payment_method_type == pmt
          }
        })

        isPMTEnabled == -1 ? k.payment_method_types->Array.length : isPMTEnabled
      }
    | None => 0
    }
    index == -1 ? 0 : index
  } else {
    0
  }
}
