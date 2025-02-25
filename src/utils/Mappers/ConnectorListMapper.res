// open ConnectorTypes
// open LogicUtils
// let parsePaymentMethodType = paymentMethodType => {
//   let paymentMethodTypeDict = paymentMethodType->getDictFromJsonObject
//   {
//     payment_method_type: paymentMethodTypeDict->getString("payment_method_type", ""),
//     flow: paymentMethodTypeDict->getString("flow", ""),
//     action: paymentMethodTypeDict->getString("action", ""),
//   }
// }
// let parsePaymentMethodResponse = paymentMethod => {
//   let paymentMethodDict = paymentMethod->getDictFromJsonObject
//   let payment_method_types =
//     paymentMethodDict
//     ->getArrayFromDict("payment_method_types", [])
//     ->Array.map(parsePaymentMethodType)

//   let flow = paymentMethodDict->getString("flow", "")

//   {
//     payment_method: paymentMethodDict->getString("payment_method", ""),
//     payment_method_types,
//     flow,
//   }
// }

// let parsePaymentMethod = paymentMethod => {
//   let paymentMethodDict = paymentMethod->getDictFromJsonObject
//   let flow = paymentMethodDict->getString("flow", "")

//   {
//     payment_method: paymentMethodDict->getString("payment_method", ""),
//     flow,
//   }
// }

// let convertFRMConfigJsonToObjResponse = json => {
//   json->Array.map(config => {
//     let configDict = config->getDictFromJsonObject
//     let payment_methods =
//       configDict->getArrayFromDict("payment_methods", [])->Array.map(parsePaymentMethodResponse)

//     {
//       gateway: configDict->getString("gateway", ""),
//       payment_methods,
//     }
//   })
// }

// let convertFRMConfigJsonToObj = json => {
//   json->Array.map(config => {
//     let configDict = config->getDictFromJsonObject
//     let payment_methods =
//       configDict->getArrayFromDict("payment_methods", [])->Array.map(parsePaymentMethod)

//     {
//       gateway: configDict->getString("gateway", ""),
//       payment_methods,
//     }
//   })
// }

// let getPaymentMethodTypes = dict => {
//   open ConnectorUtils
//   {
//     payment_method_type: dict->getString("payment_method_type", ""),
//     payment_experience: dict->getOptionString("payment_experience"),
//     card_networks: dict->getStrArrayFromDict("card_networks", []),
//     accepted_countries: dict->getDictfromDict("accepted_countries")->acceptedValues,
//     accepted_currencies: dict->getDictfromDict("accepted_currencies")->acceptedValues,
//     minimum_amount: dict->getOptionInt("minimum_amount"),
//     maximum_amount: dict->getOptionInt("maximum_amount"),
//     recurring_enabled: dict->getOptionBool("recurring_enabled"),
//     installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
//   }
// }

// let getPaymentMethodsEnabled: Dict.t<JSON.t> => paymentMethodEnabledType = dict => {
//   {
//     payment_method: dict->getString("payment_method", ""),
//     payment_method_types: dict
//     ->Dict.get("payment_method_types")
//     ->Option.getOr(Dict.make()->JSON.Encode.object)
//     ->getArrayDataFromJson(getPaymentMethodTypes),
//   }
// }

// let getConnectorAccountDetails = dict => {
//   {
//     auth_type: dict->getString("auth_type", ""),
//     api_secret: dict->getString("api_secret", ""),
//     api_key: dict->getString("api_key", ""),
//     key1: dict->getString("key1", ""),
//   }
// }

// let connectorAuthTypeMapper = (str): connectorAuthType => {
//   switch str->String.toLowerCase {
//   | "headerkey" => HeaderKey
//   | "bodykey" => BodyKey
//   | "signaturekey" => SignatureKey
//   | "multiauthkey" => MultiAuthKey
//   | "currencyauthkey" => CurrencyAuthKey
//   | "certificateauth" => CertificateAuth
//   | _ => UnKnownAuthType
//   }
// }

// let getHeaderAuth = (dict): headerKey => {
//   auth_type: dict->getString("auth_type", ""),
//   api_key: dict->getString("api_key", ""),
// }
// let getBodyKeyAuth = (dict): bodyKey => {
//   auth_type: dict->getString("auth_type", ""),
//   api_key: dict->getString("api_key", ""),
//   key1: dict->getString("key1", ""),
// }
// let getSignatureKeyAuth = (dict): signatureKey => {
//   auth_type: dict->getString("auth_type", ""),
//   api_key: dict->getString("api_key", ""),
//   key1: dict->getString("key1", ""),
//   api_secret: dict->getString("api_secret", ""),
// }
// let getMultiAuthKeyAuth = (dict): multiAuthKey => {
//   auth_type: dict->getString("auth_type", ""),
//   api_key: dict->getString("api_key", ""),
//   key1: dict->getString("key1", ""),
//   api_secret: dict->getString("api_secret", ""),
//   key2: dict->getString("key2", ""),
// }

// let getCurrencyAuthKey = (dict): currencyAuthKey => {
//   auth_type: dict->getString("auth_type", ""),
//   auth_key_map: dict->getDictfromDict("auth_key_map"),
// }
// let getCertificateAuth = (dict): certificateAuth => {
//   auth_type: dict->getString("auth_type", ""),
//   certificate: dict->getString("certificate", ""),
//   private_key: dict->getString("private_key", ""),
// }

// let getAccountDetails = (dict): connectorAuthTypeObj => {
//   let authType = dict->getString("auth_type", "")->connectorAuthTypeMapper
//   let d = switch authType {
//   | HeaderKey => HeaderKey(dict->getHeaderAuth)
//   | BodyKey => BodyKey(dict->getBodyKeyAuth)
//   | SignatureKey => SignatureKey(dict->getSignatureKeyAuth)
//   | MultiAuthKey => MultiAuthKey(dict->getMultiAuthKeyAuth)
//   | CurrencyAuthKey => CurrencyAuthKey(dict->getCurrencyAuthKey)
//   | CertificateAuth => CertificateAuth(dict->getCertificateAuth)
//   | UnKnownAuthType => UnKnownAuthType(JSON.Encode.null)
//   }
//   d
// }

// let getProcessorPayloadType = (dict): connectorPayload => {
//   {
//     connector_type: dict
//     ->getString("connector_type", "")
//     ->ConnectorUtils.connectorTypeStringToTypeMapper,
//     connector_name: dict->getString("connector_name", ""),
//     connector_label: dict->getString("connector_label", ""),
//     connector_account_details: dict
//     ->getObj("connector_account_details", Dict.make())
//     ->getAccountDetails,
//     test_mode: dict->getBool("test_mode", true),
//     disabled: dict->getBool("disabled", true),
//     payment_methods_enabled: dict
//     ->Dict.get("payment_methods_enabled")
//     ->Option.getOr(Dict.make()->JSON.Encode.object)
//     ->getArrayDataFromJson(getPaymentMethodsEnabled),
//     profile_id: dict->getString("profile_id", ""),
//     merchant_connector_id: dict->getString("merchant_connector_id", ""),
//     frm_configs: dict->getArrayFromDict("frm_configs", [])->convertFRMConfigJsonToObjResponse,
//     status: dict->getString("status", "inactive"),
//     connector_webhook_details: dict
//     ->Dict.get("connector_webhook_details")
//     ->Option.getOr(JSON.Encode.null),
//     metadata: dict->getObj("metadata", Dict.make())->JSON.Encode.object,
//     additional_merchant_data: dict
//     ->getObj("additional_merchant_data", Dict.make())
//     ->JSON.Encode.object,
//   }
// }

// let getArrayOfConnectorListPayloadType = json => {
//   json
//   ->getArrayFromJson([])
//   ->Array.map(connectorJson => {
//     connectorJson->getDictFromJsonObject->getProcessorPayloadType
//   })
// }

