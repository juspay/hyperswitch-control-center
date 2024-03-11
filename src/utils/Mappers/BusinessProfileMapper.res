open HSwitchSettingTypes

let constructWebhookDetailsObject = webhookDetailsDict => {
  open LogicUtils
  let webhookDetails = {
    webhook_version: webhookDetailsDict->getOptionString("webhook_version"),
    webhook_username: webhookDetailsDict->getOptionString("webhook_username"),
    webhook_password: webhookDetailsDict->getOptionString("webhook_password"),
    webhook_url: webhookDetailsDict->getOptionString("webhook_url"),
    payment_created_enabled: webhookDetailsDict->getOptionBool("payment_created_enabled"),
    payment_succeeded_enabled: webhookDetailsDict->getOptionBool("payment_succeeded_enabled"),
    payment_failed_enabled: webhookDetailsDict->getOptionBool("payment_failed_enabled"),
  }
  webhookDetails
}
let constructAuthConnectorObject = authConnectorDict => {
  open LogicUtils
  let authConnectorDetails = {
    authentication_connectors: authConnectorDict->getOptionalArrayFromDict(
      "authentication_connectors",
    ),
    three_ds_requestor_url: authConnectorDict->getOptionString("three_ds_requestor_url"),
  }
  authConnectorDetails
}

let businessProfileTypeMapper = values => {
  open LogicUtils
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let authenticationConnectorDetails = jsonDict->getDictfromDict("authentication_connector_details")
  let businessProfile = {
    merchant_id: jsonDict->getString("merchant_id", ""),
    profile_id: jsonDict->getString("profile_id", ""),
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: webhookDetailsDict->constructWebhookDetailsObject,
    authentication_connector_details: authenticationConnectorDetails->constructAuthConnectorObject,
  }
  businessProfile
}

let convertObjectToType = value => {
  let reversedArray = value->Array.toReversed
  reversedArray->Array.map(businessProfileTypeMapper)
}

let getArrayOfBusinessProfile = businessProfileValue => {
  open LogicUtils
  businessProfileValue->getArrayFromJson([])->convertObjectToType
}
