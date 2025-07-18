open ConnectorTypes
open LogicUtils
let connectorAuthTypeMapper = (str): connectorAuthType => {
  switch str->String.toLowerCase {
  | "headerkey" => HeaderKey
  | "bodykey" => BodyKey
  | "signaturekey" => SignatureKey
  | "multiauthkey" => MultiAuthKey
  | "currencyauthkey" => CurrencyAuthKey
  | "certificateauth" => CertificateAuth
  | "nokey" => NoKey
  | _ => UnKnownAuthType
  }
}

let getHeaderAuth = (dict): headerKey => {
  auth_type: dict->getString("auth_type", ""),
  api_key: dict->getString("api_key", ""),
}
let getBodyKeyAuth = (dict): bodyKey => {
  auth_type: dict->getString("auth_type", ""),
  api_key: dict->getString("api_key", ""),
  key1: dict->getString("key1", ""),
}
let getSignatureKeyAuth = (dict): signatureKey => {
  auth_type: dict->getString("auth_type", ""),
  api_key: dict->getString("api_key", ""),
  key1: dict->getString("key1", ""),
  api_secret: dict->getString("api_secret", ""),
}
let getMultiAuthKeyAuth = (dict): multiAuthKey => {
  auth_type: dict->getString("auth_type", ""),
  api_key: dict->getString("api_key", ""),
  key1: dict->getString("key1", ""),
  api_secret: dict->getString("api_secret", ""),
  key2: dict->getString("key2", ""),
}

let getCurrencyAuthKey = (dict): currencyAuthKey => {
  auth_type: dict->getString("auth_type", ""),
  auth_key_map: dict->getDictfromDict("auth_key_map"),
}
let getCertificateAuth = (dict): certificateAuth => {
  auth_type: dict->getString("auth_type", ""),
  certificate: dict->getString("certificate", ""),
  private_key: dict->getString("private_key", ""),
}
let getNoKeyAuth = dict => {
  auth_type: dict->getString("auth_type", ""),
}

let getAccountDetails = (dict): connectorAuthTypeObj => {
  let authType = dict->getString("auth_type", "")->connectorAuthTypeMapper
  switch authType {
  | HeaderKey => HeaderKey(dict->getHeaderAuth)
  | BodyKey => BodyKey(dict->getBodyKeyAuth)
  | SignatureKey => SignatureKey(dict->getSignatureKeyAuth)
  | MultiAuthKey => MultiAuthKey(dict->getMultiAuthKeyAuth)
  | CurrencyAuthKey => CurrencyAuthKey(dict->getCurrencyAuthKey)
  | CertificateAuth => CertificateAuth(dict->getCertificateAuth)
  | NoKey => NoKey(dict->getNoKeyAuth)
  | UnKnownAuthType => UnKnownAuthType(JSON.Encode.null)
  }
}

let parsePaymentMethodType = paymentMethodType => {
  let paymentMethodTypeDict = paymentMethodType->getDictFromJsonObject
  {
    payment_method_type: paymentMethodTypeDict->getString("payment_method_type", ""),
    flow: paymentMethodTypeDict->getString("flow", ""),
    action: paymentMethodTypeDict->getString("action", ""),
  }
}
let parsePaymentMethodResponse = paymentMethod => {
  let paymentMethodDict = paymentMethod->getDictFromJsonObject
  let payment_method_types =
    paymentMethodDict
    ->getArrayFromDict("payment_method_types", [])
    ->Array.map(parsePaymentMethodType)

  let flow = paymentMethodDict->getString("flow", "")

  {
    payment_method: paymentMethodDict->getString("payment_method", ""),
    payment_method_types,
    flow,
  }
}

let parsePaymentMethod = paymentMethod => {
  let paymentMethodDict = paymentMethod->getDictFromJsonObject
  let flow = paymentMethodDict->getString("flow", "")

  {
    payment_method: paymentMethodDict->getString("payment_method", ""),
    flow,
  }
}

let convertFRMConfigJsonToObjResponse = json => {
  json->Array.map(config => {
    let configDict = config->getDictFromJsonObject
    let payment_methods =
      configDict->getArrayFromDict("payment_methods", [])->Array.map(parsePaymentMethodResponse)

    {
      gateway: configDict->getString("gateway", ""),
      payment_methods,
    }
  })
}

let convertFRMConfigJsonToObj = json => {
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

let getPaymentMethodTypes = (dict): paymentMethodConfigType => {
  open ConnectorUtils
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_experience: dict->getOptionString("payment_experience"),
    card_networks: dict->getStrArrayFromDict("card_networks", []),
    accepted_countries: dict->getDictfromDict("accepted_countries")->acceptedValues,
    accepted_currencies: dict->getDictfromDict("accepted_currencies")->acceptedValues,
    minimum_amount: dict->getOptionInt("minimum_amount"),
    maximum_amount: dict->getOptionInt("maximum_amount"),
    recurring_enabled: dict->getOptionBool("recurring_enabled"),
    installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
  }
}

let getPaymentMethodTypesV2 = (dict): paymentMethodConfigTypeV2 => {
  open ConnectorUtils
  {
    payment_method_subtype: dict->getString("payment_method_subtype", ""),
    payment_experience: dict->getOptionString("payment_experience"),
    card_networks: dict->getStrArrayFromDict("card_networks", []),
    accepted_countries: dict->getDictfromDict("accepted_countries")->acceptedValues,
    accepted_currencies: dict->getDictfromDict("accepted_currencies")->acceptedValues,
    minimum_amount: dict->getOptionInt("minimum_amount"),
    maximum_amount: dict->getOptionInt("maximum_amount"),
    recurring_enabled: dict->getOptionBool("recurring_enabled"),
    installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
  }
}

let getPaymentMethodsEnabled: Dict.t<JSON.t> => paymentMethodEnabledType = dict => {
  {
    payment_method: dict->getString("payment_method", ""),
    payment_method_types: dict
    ->Dict.get("payment_method_types")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodTypes),
  }
}

let mapDictToConnectorPayload = (dict): connectorPayload => {
  {
    connector_type: dict
    ->getString("connector_type", "")
    ->ConnectorUtils.connectorTypeStringToTypeMapper,
    connector_name: dict->getString("connector_name", ""),
    connector_label: dict->getString("connector_label", ""),
    connector_account_details: dict
    ->getObj("connector_account_details", Dict.make())
    ->getAccountDetails,
    test_mode: dict->getBool("test_mode", true),
    disabled: dict->getBool("disabled", true),
    payment_methods_enabled: dict
    ->Dict.get("payment_methods_enabled")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodsEnabled),
    profile_id: dict->getString("profile_id", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
    frm_configs: dict->getArrayFromDict("frm_configs", [])->convertFRMConfigJsonToObjResponse,
    status: dict->getString("status", "inactive"),
    connector_webhook_details: dict
    ->Dict.get("connector_webhook_details")
    ->Option.getOr(JSON.Encode.null),
    metadata: dict->getObj("metadata", Dict.make())->JSON.Encode.object,
    additional_merchant_data: dict
    ->getObj("additional_merchant_data", Dict.make())
    ->JSON.Encode.object,
  }
}

let getPaymentMethodsEnabledV2: Dict.t<JSON.t> => paymentMethodEnabledTypeV2 = dict => {
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_subtypes: dict
    ->Dict.get("payment_method_subtypes")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodTypesV2),
  }
}

let mapDictToConnectorPayloadV2 = (dict): connectorPayloadV2 => {
  {
    connector_type: dict
    ->getString("connector_type", "")
    ->ConnectorUtils.connectorTypeStringToTypeMapper,
    connector_name: dict->getString("connector_name", ""),
    connector_label: dict->getString("connector_label", ""),
    connector_account_details: dict
    ->getObj("connector_account_details", Dict.make())
    ->getAccountDetails,
    disabled: dict->getBool("disabled", true),
    payment_methods_enabled: dict
    ->getJsonObjectFromDict("payment_methods_enabled")
    ->getArrayDataFromJson(getPaymentMethodsEnabledV2),
    profile_id: dict->getString("profile_id", ""),
    id: dict->getString("id", ""),
    frm_configs: dict->getArrayFromDict("frm_configs", [])->convertFRMConfigJsonToObjResponse,
    status: dict->getString("status", "inactive"),
    connector_webhook_details: dict->getJsonObjectFromDict("connector_webhook_details"),
    metadata: dict->getObj("metadata", Dict.make())->JSON.Encode.object,
    additional_merchant_data: dict
    ->getObj("additional_merchant_data", Dict.make())
    ->JSON.Encode.object,
    feature_metadata: dict
    ->getObj("feature_metadata", Dict.make())
    ->JSON.Encode.object,
  }
}

// v1 to common type mappers

let paymentMethodsTypesMapperV1: paymentMethodConfigType => paymentMethodConfigTypeCommon = paymentMethodsTypes => {
  {
    payment_method_subtype: paymentMethodsTypes.payment_method_type,
    payment_experience: paymentMethodsTypes.payment_experience,
    card_networks: paymentMethodsTypes.card_networks,
    accepted_countries: paymentMethodsTypes.accepted_countries,
    accepted_currencies: paymentMethodsTypes.accepted_currencies,
    minimum_amount: paymentMethodsTypes.minimum_amount,
    maximum_amount: paymentMethodsTypes.maximum_amount,
    recurring_enabled: paymentMethodsTypes.recurring_enabled,
    installment_payment_enabled: paymentMethodsTypes.installment_payment_enabled,
  }
}

let paymentMethodsEnabledMapperV1: paymentMethodEnabledType => paymentMethodEnabledTypeCommon = paymentMethodsEnabled => {
  {
    payment_method_type: paymentMethodsEnabled.payment_method,
    payment_method_subtypes: paymentMethodsEnabled.payment_method_types->Array.map(
      paymentMethodsTypesMapperV1,
    ),
  }
}

let mapV1DictToCommonConnectorPayload: connectorPayload => connectorPayloadCommonType = connectorPayload => {
  {
    connector_type: connectorPayload.connector_type,
    connector_name: connectorPayload.connector_name,
    connector_label: connectorPayload.connector_label,
    connector_account_details: connectorPayload.connector_account_details,
    test_mode: connectorPayload.test_mode,
    disabled: connectorPayload.disabled,
    payment_methods_enabled: connectorPayload.payment_methods_enabled->Array.map(
      paymentMethodsEnabledMapperV1,
    ),
    profile_id: connectorPayload.profile_id,
    id: connectorPayload.merchant_connector_id,
    frm_configs: switch connectorPayload.frm_configs {
    | Some(frmConfigs) => frmConfigs
    | None => []
    },
    status: connectorPayload.status,
    connector_webhook_details: connectorPayload.connector_webhook_details,
    metadata: connectorPayload.metadata,
    additional_merchant_data: connectorPayload.additional_merchant_data,
  }
}

// v2 to commmon type mappers

let paymentMethodsTypesMapperV2: paymentMethodConfigTypeV2 => paymentMethodConfigTypeCommon = paymentMethodsTypes => {
  {
    payment_method_subtype: paymentMethodsTypes.payment_method_subtype,
    payment_experience: paymentMethodsTypes.payment_experience,
    card_networks: paymentMethodsTypes.card_networks,
    accepted_countries: paymentMethodsTypes.accepted_countries,
    accepted_currencies: paymentMethodsTypes.accepted_currencies,
    minimum_amount: paymentMethodsTypes.minimum_amount,
    maximum_amount: paymentMethodsTypes.maximum_amount,
    recurring_enabled: paymentMethodsTypes.recurring_enabled,
    installment_payment_enabled: paymentMethodsTypes.installment_payment_enabled,
  }
}

let paymentMethodsEnabledMapperV2: paymentMethodEnabledTypeV2 => paymentMethodEnabledTypeCommon = paymentMethodsEnabled => {
  {
    payment_method_type: paymentMethodsEnabled.payment_method_type,
    payment_method_subtypes: paymentMethodsEnabled.payment_method_subtypes->Array.map(
      paymentMethodsTypesMapperV2,
    ),
  }
}

let mapV2DictToCommonConnectorPayload: connectorPayloadV2 => connectorPayloadCommonType = connectorPayload => {
  {
    connector_type: connectorPayload.connector_type,
    connector_name: connectorPayload.connector_name,
    connector_label: connectorPayload.connector_label,
    connector_account_details: connectorPayload.connector_account_details,
    disabled: connectorPayload.disabled,
    payment_methods_enabled: connectorPayload.payment_methods_enabled->Array.map(
      paymentMethodsEnabledMapperV2,
    ),
    profile_id: connectorPayload.profile_id,
    id: connectorPayload.id,
    frm_configs: connectorPayload.frm_configs,
    status: connectorPayload.status,
    connector_webhook_details: connectorPayload.connector_webhook_details,
    metadata: connectorPayload.metadata,
    additional_merchant_data: connectorPayload.additional_merchant_data,
  }
}

let filter = (connectorType, ~retainInList) => {
  switch (retainInList, connectorType) {
  | (PaymentProcessor, PaymentProcessor)
  | (PaymentVas, PaymentVas)
  | (PayoutProcessor, PayoutProcessor)
  | (AuthenticationProcessor, AuthenticationProcessor)
  | (PMAuthProcessor, PMAuthProcessor)
  | (TaxProcessor, TaxProcessor)
  | (BillingProcessor, BillingProcessor) => true
  | _ => false
  }
}

let filterConnectorList = (items: array<connectorPayloadCommonType>, retainInList) => {
  items->Array.filter(connector => connector.connector_type->filter(~retainInList))
}

let filterConnectorListV2 = (items: array<connectorPayloadCommonType>, retainInList) => {
  items->Array.filter(connector => connector.connector_type->filter(~retainInList))
}

let mapConnectorPayloadToConnectorType = (
  ~connectorType=Processor,
  connectorsList: array<connectorPayloadCommonType>,
) => {
  connectorsList->Array.map(connectorDetail =>
    connectorDetail.connector_name->ConnectorUtils.getConnectorNameTypeFromString(~connectorType)
  )
}

let mapConnectorPayloadToConnectorTypeV2 = (
  ~connectorType=Processor,
  connectorsList: array<connectorPayloadCommonType>,
) => {
  connectorsList->Array.map(connectorDetail =>
    connectorDetail.connector_name->ConnectorUtils.getConnectorNameTypeFromString(~connectorType)
  )
}

let mapListToFilteredConnectorList = (list, retainInList) => {
  list->filterConnectorList(retainInList)
}

let mapListToFilteredConnectorListV2 = (list, retainInList) => {
  list->filterConnectorListV2(retainInList)
}

let getPaymentMethodsEnabledCommonType: Dict.t<JSON.t> => paymentMethodEnabledTypeCommon = dict => {
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_subtypes: dict
    ->Dict.get("payment_method_types")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(item => item->getPaymentMethodTypes->paymentMethodsTypesMapperV1),
  }
}
