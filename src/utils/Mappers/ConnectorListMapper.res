open ConnectorTypes
let parsePaymentMethodType = paymentMethodType => {
  open LogicUtils

  let paymentMethodTypeDict = paymentMethodType->getDictFromJsonObject
  {
    payment_method_type: paymentMethodTypeDict->getString("payment_method_type", ""),
    flow: paymentMethodTypeDict->getString("flow", ""),
    action: paymentMethodTypeDict->getString("action", ""),
  }
}
let parsePaymentMethod = paymentMethod => {
  open LogicUtils

  let paymentMethodDict = paymentMethod->getDictFromJsonObject
  let payment_method_types =
    paymentMethodDict
    ->getArrayFromDict("payment_method_types", [])
    ->Array.map(parsePaymentMethodType)

  {
    payment_method: paymentMethodDict->getString("payment_method", ""),
    payment_method_types,
  }
}

let convertFRMConfigJsonToObj = json => {
  open LogicUtils

  json->Array.map(config => {
    let configDict = config->getDictFromJsonObject
    let payment_methods =
      configDict->getArrayFromDict("payment_methods", [])->Array.map(parsePaymentMethod)

    {
      gateway: configDict->getString("gateway", ""),
      payment_methods,
    }
  })
}

let getPaymentMethodTypes = dict => {
  open LogicUtils
  open ConnectorUtils
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_experience: dict->getOptionString("payment_method_type"),
    card_networks: dict->getStrArrayFromDict("card_networks", []),
    accepted_countries: dict->getDictfromDict("accepted_countries")->acceptedValues,
    accepted_currencies: dict->getDictfromDict("accepted_countries")->acceptedValues,
    minimum_amount: dict->getOptionInt("minimum_amount"),
    maximum_amount: dict->getOptionInt("maximum_amount"),
    recurring_enabled: dict->getOptionBool("recurring_enabled"),
    installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
  }
}

let getPaymentMethodsEnabled: Dict.t<JSON.t> => paymentMethodEnabledType = dict => {
  open LogicUtils
  {
    payment_method: dict->getString("payment_method", ""),
    payment_method_types: dict
    ->Dict.get("payment_method_types")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodTypes),
  }
}

let getConnectorAccountDetails = dict => {
  open LogicUtils
  {
    auth_type: dict->getString("auth_type", ""),
    api_secret: dict->getString("api_secret", ""),
    api_key: dict->getString("api_key", ""),
    key1: dict->getString("key1", ""),
  }
}

let getProcessorPayloadType = dict => {
  open LogicUtils
  {
    connector_type: dict->getString("connector_type", ""),
    connector_name: dict->getString("connector_name", ""),
    connector_label: dict->getString("connector_label", ""),
    connector_account_details: dict
    ->getObj("connector_account_details", Dict.make())
    ->getConnectorAccountDetails,
    test_mode: dict->getBool("test_mode", true),
    disabled: dict->getBool("disabled", true),
    payment_methods_enabled: dict
    ->Dict.get("payment_methods_enabled")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodsEnabled),
    profile_id: dict->getString("profile_id", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
    frm_configs: dict->getArrayFromDict("frm_configs", [])->convertFRMConfigJsonToObj,
    status: dict->getString("status", "inactive"),
  }
}

let getArrayOfConnectorListPayloadType = json => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(connectorJson => {
    connectorJson->getDictFromJsonObject->getProcessorPayloadType
  })
}
