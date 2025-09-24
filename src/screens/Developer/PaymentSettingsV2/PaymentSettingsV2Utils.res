open PaymentSettingsV2Types
open HSwitchSettingTypes

let parseBusinessProfileForPaymentBehaviour = (profileRecord: profileEntity) => {
  open LogicUtils
  let {
    profile_name,
    webhook_details,
    return_url,
    collect_shipping_details_from_wallet_connector,
    collect_billing_details_from_wallet_connector,
    always_collect_billing_details_from_wallet_connector,
    always_collect_shipping_details_from_wallet_connector,
    is_auto_retries_enabled,
    max_auto_retries_enabled,
    is_connector_agnostic_mit_enabled,
    is_click_to_pay_enabled,
    authentication_product_ids,
    always_request_extended_authorization,
    is_network_tokenization_enabled,
    is_manual_retry_enabled,
    always_enable_overcapture,
  } = profileRecord
  let webhookDict = Dict.make()

  let profileInfo = [("profile_name", profile_name->JSON.Encode.string)]->Dict.fromArray
  profileInfo->setDictNull("return_url", return_url)
  profileInfo->setOptionBool(
    "collect_shipping_details_from_wallet_connector",
    collect_shipping_details_from_wallet_connector,
  )
  webhookDict->setDictNull("webhook_url", webhook_details.webhook_url)
  profileInfo->setOptionDict("webhook_details", Some(webhookDict))
  profileInfo->setOptionBool(
    "collect_billing_details_from_wallet_connector",
    collect_billing_details_from_wallet_connector,
  )
  profileInfo->setOptionBool(
    "always_collect_billing_details_from_wallet_connector",
    always_collect_billing_details_from_wallet_connector,
  )
  profileInfo->setOptionBool(
    "always_collect_shipping_details_from_wallet_connector",
    always_collect_shipping_details_from_wallet_connector,
  )

  profileInfo->setOptionBool("is_auto_retries_enabled", is_auto_retries_enabled)
  profileInfo->setOptionInt("max_auto_retries_enabled", max_auto_retries_enabled)

  profileInfo->setOptionBool("is_connector_agnostic_mit_enabled", is_connector_agnostic_mit_enabled)
  profileInfo->setOptionBool("is_click_to_pay_enabled", is_click_to_pay_enabled)
  profileInfo->setOptionJson("authentication_product_ids", authentication_product_ids)
  profileInfo->setOptionBool(
    "always_request_extended_authorization",
    always_request_extended_authorization,
  )
  profileInfo->setOptionBool("is_network_tokenization_enabled", is_network_tokenization_enabled)
  profileInfo->setOptionBool("is_manual_retry_enabled", is_manual_retry_enabled)
  profileInfo->setOptionBool("always_enable_overcapture", always_enable_overcapture)

  profileInfo
}

let validateEmptyArray = (key, errors, arrayValue) => {
  switch (key: validationFieldsV2) {
  | AuthenticationConnectors(_) =>
    let newDict = errors->LogicUtils.getDictfromDict("authentication_connector_details")

    if arrayValue->Array.length === 0 {
      Dict.set(
        newDict,
        "authentication_connectors",
        "Please select authentication connector"->JSON.Encode.string,
      )
      Dict.set(errors, "authentication_connector_details", newDict->JSON.Encode.object)
    }
  | _ => ()
  }
}
let validateCustom = (key, errors, value, isLiveMode) => {
  switch key {
  | WebhookDetails =>
    let regexUrl = isLiveMode
      ? RegExp.test(%re("/^https:\/\//i"), value) || value->String.includes("localhost")
      : RegExp.test(%re("/^(http|https):\/\//i"), value)

    let newDict = errors->LogicUtils.getDictfromDict("webhook_details")
    if !regexUrl {
      errors->Dict.set("webhook_details", JSON.Encode.null)
      Dict.set(newDict, "webhook_url", "Please Enter Valid Webhook URL"->JSON.Encode.string)
      Dict.set(errors, "webhook_details", newDict->JSON.Encode.object)
    }

  | ReturnUrl => {
      let regexUrl = isLiveMode
        ? RegExp.test(%re("/^https:\/\//i"), value) || value->String.includes("localhost")
        : RegExp.test(%re("/^(http|https):\/\//i"), value)
      if !regexUrl {
        Dict.set(errors, "return_url", "Please Enter Valid Return URL"->JSON.Encode.string)
      }
    }

  | ThreeDsRequestorUrl => {
      let regexUrl = isLiveMode
        ? RegExp.test(%re("/^https:\/\//i"), value) || value->String.includes("localhost")
        : RegExp.test(%re("/^(http|https):\/\//i"), value)
      let newDict = errors->LogicUtils.getDictfromDict("authentication_connector_details")
      if !regexUrl {
        errors->Dict.set("authentication_connector_details", JSON.Encode.null)
        Dict.set(
          newDict,
          "three_ds_requestor_url",
          "Please Enter Valid Threeds URL"->JSON.Encode.string,
        )
        Dict.set(errors, "authentication_connector_details", newDict->JSON.Encode.object)
      }
    }
  | ThreeDsRequestorAppUrl =>
    let httpUrlValid = isLiveMode
      ? RegExp.test(%re("/^https:\/\//i"), value) || value->String.includes("localhost")
      : RegExp.test(%re("/^(http|https):\/\//i"), value)

    let deepLinkValid = RegExp.test(%re("/^[a-zA-Z][a-zA-Z0-9]*:\/\//i"), value)
    if !(httpUrlValid || deepLinkValid) {
      let newDict = errors->LogicUtils.getDictfromDict("authentication_connector_details")
      errors->Dict.set("authentication_connector_details", JSON.Encode.null)
      Dict.set(
        newDict,
        "three_ds_requestor_app_url",
        "Please enter a valid URL or Mobile Deeplink"->JSON.Encode.string,
      )
      Dict.set(errors, "authentication_connector_details", newDict->JSON.Encode.object)
    }

  | _ => ()
  }
}

let validationFieldsReverseMapperV2 = value => {
  switch value {
  | "webhook_details" => WebhookDetails
  | "return_url" => ReturnUrl
  | "is_auto_retries_enabled" => AutoRetry
  | "authentication_connector_details" => AuthenticationConnectorDetails
  | _ => UnknownValidateFields(value)
  }
}

let validateMerchantAccountFormV2 = (
  ~values: JSON.t,
  ~isLiveMode,
  ~businessProfileRecoilVal: commonProfileEntity,
) => {
  open LogicUtils
  let errors = Dict.make()

  let valuesDict = values->getDictFromJsonObject
  let valuesDictArray = valuesDict->Dict.keysToArray

  valuesDictArray->Array.forEach(key => {
    switch key->validationFieldsReverseMapperV2 {
    | AutoRetry => {
        let value = valuesDict->getOptionBool(key)
        switch value {
        | Some(true) =>
          let value = getInt(valuesDict, "max_auto_retries_enabled", 0)
          if !RegExp.test(%re("/^(?:[1-5])$/"), value->Int.toString) {
            Dict.set(
              errors,
              "max_auto_retries_enabled",
              "Please enter integer value from 1 to 5"->JSON.Encode.string,
            )
          }

        | _ => ()
        }
      }

    | WebhookDetails =>
      let value =
        valuesDict
        ->getDictfromDict("webhook_details")
        ->getString("webhook_url", "")
        ->getNonEmptyString
      switch value {
      | Some(str) => key->validationFieldsReverseMapperV2->validateCustom(errors, str, isLiveMode)
      | _ => ()
      }
    | AuthenticationConnectorDetails =>
      let initiallyConnectedAuthConnectorsLength = switch businessProfileRecoilVal.authentication_connector_details {
      | None => 0
      | Some(val) => val.authentication_connectors->Option.mapOr(0, arr => {arr->Array.length})
      }

      let authenticationConnectorDetailsDict =
        valuesDict->getDictfromDict("authentication_connector_details")
      let threedsArray =
        authenticationConnectorDetailsDict
        ->getArrayFromDict("authentication_connectors", [])
        ->getNonEmptyArray
      let threeDsArrayVal = threedsArray->Option.mapOr([], arr => arr)
      let threedsUrl =
        authenticationConnectorDetailsDict
        ->getString("three_ds_requestor_url", "")
        ->getNonEmptyString
      let threedsAppUrl =
        authenticationConnectorDetailsDict
        ->getString("three_ds_requestor_app_url", "")
        ->getNonEmptyString

      if initiallyConnectedAuthConnectorsLength > 0 {
        let url = authenticationConnectorDetailsDict->getString("three_ds_requestor_url", "")
        AuthenticationConnectors(threeDsArrayVal)->validateEmptyArray(errors, threeDsArrayVal)
        ThreeDsRequestorUrl->validateCustom(errors, url, isLiveMode)
      }
      switch threedsArray {
      | Some(valArr) => {
          let url = authenticationConnectorDetailsDict->getString("three_ds_requestor_url", "")
          AuthenticationConnectors(valArr)->validateEmptyArray(errors, valArr)
          ThreeDsRequestorUrl->validateCustom(errors, url, isLiveMode)
        }
      | _ => ()
      }
      switch threedsUrl {
      | Some(str) => {
          let arr =
            authenticationConnectorDetailsDict->getArrayFromDict("authentication_connectors", [])
          AuthenticationConnectors(arr)->validateEmptyArray(errors, arr)
          ThreeDsRequestorUrl->validateCustom(errors, str, isLiveMode)
        }
      | _ => ()
      }
      switch threedsAppUrl {
      | Some(str) => {
          let arr =
            authenticationConnectorDetailsDict->getArrayFromDict("authentication_connectors", [])
          AuthenticationConnectors(arr)->validateEmptyArray(errors, arr)
          ThreeDsRequestorAppUrl->validateCustom(errors, str, isLiveMode)
        }
      | _ => ()
      }

    | _ => {
        let value = getString(valuesDict, key, "")->getNonEmptyString
        switch value {
        | Some(str) => key->validationFieldsReverseMapperV2->validateCustom(errors, str, isLiveMode)
        | _ => ()
        }
      }
    }
  })

  errors->JSON.Encode.object
}

let parseBusinessProfileForThreeDS = (profileRecord: HSwitchSettingTypes.profileEntity) => {
  open LogicUtils
  let {
    authentication_connector_details,
    force_3ds_challenge,
    is_debit_routing_enabled,
  } = profileRecord

  let threeDsInfo = Dict.make()
  let authConnectorDetails = Dict.make()
  switch authentication_connector_details {
  | Some(val) =>
    authConnectorDetails->setOptionArray("authentication_connectors", val.authentication_connectors)
    authConnectorDetails->setOptionString("three_ds_requestor_url", val.three_ds_requestor_url)
    authConnectorDetails->setOptionString(
      "three_ds_requestor_app_url",
      val.three_ds_requestor_app_url,
    )
  | None => ()
  }

  threeDsInfo->setOptionBool("force_3ds_challenge", force_3ds_challenge)
  threeDsInfo->setOptionBool("is_debit_routing_enabled", is_debit_routing_enabled)

  threeDsInfo->setOptionDict(
    "authentication_connector_details",
    !(authConnectorDetails->isEmptyDict) ? Some(authConnectorDetails) : None,
  )
  threeDsInfo
}

let isAuthConnectorArrayEmpty = values => {
  open LogicUtils
  values
  ->getDictFromJsonObject
  ->getDictfromDict("authentication_connector_details")
  ->getArrayFromDict("authentication_connectors", [])
  ->Array.length === 0
}

let parseCustomHeadersFromEntity = (profileRecord: profileEntity) => {
  open LogicUtils

  let customHeaderDict = Dict.make()

  switch profileRecord.outgoing_webhook_custom_http_headers {
  | Some(headers) =>
    customHeaderDict->setOptionDict("outgoing_webhook_custom_http_headers", Some(headers))
  | None => ()
  }

  customHeaderDict
}

let getCustomHeadersPayload = valuesDict => {
  open LogicUtils
  let customHeaderDict = Dict.make()
  let outGoingWebHookCustomHttpHeaders = Dict.make()
  let formValues = valuesDict->getDictfromDict("outgoing_webhook_custom_http_headers")

  let _ =
    valuesDict
    ->getDictfromDict("outgoing_webhook_custom_http_headers")
    ->Dict.keysToArray
    ->Array.forEach(val => {
      outGoingWebHookCustomHttpHeaders->setOptionString(
        val,
        formValues->getString(val, "")->getNonEmptyString,
      )
    })
  customHeaderDict->setOptionDict(
    "outgoing_webhook_custom_http_headers",
    Some(outGoingWebHookCustomHttpHeaders),
  )
  customHeaderDict
}
let removeEmptyValues = (~dict, ~key) => {
  open LogicUtils
  let finalDict = Dict.make()
  let formValues = dict->getDictfromDict(key)
  let _ =
    dict
    ->getDictfromDict(key)
    ->Dict.keysToArray
    ->Array.forEach(val => {
      finalDict->setOptionString(val, formValues->getString(val, "")->getNonEmptyString)
    })
  finalDict
}
let parseMetadataCustomHeadersFromEntity = (profileRecord: profileEntity) => {
  open LogicUtils

  let customHeaderDict = Dict.make()

  switch profileRecord.metadata {
  | Some(headers) => customHeaderDict->setOptionDict("metadata", Some(headers))
  | None => ()
  }

  customHeaderDict
}
let getMetdataKeyValuePayload = valuesDict => {
  open LogicUtils
  let customHeaderDict = Dict.make()
  let customMetadataVal = Dict.make()
  let formValues = valuesDict->getDictfromDict("metadata")

  let _ =
    valuesDict
    ->getDictfromDict("metadata")
    ->Dict.keysToArray
    ->Array.forEach(val => {
      customMetadataVal->setOptionString(val, formValues->getString(val, "")->getNonEmptyString)
    })
  customHeaderDict->setOptionDict("metadata", Some(customMetadataVal))
  customHeaderDict
}

let commonTypeJsonToV1ForRequest: JSON.t => profileEntity = json => {
  open LogicUtils
  let dict = json->getDictFromJsonObject
  let outgoingWebhookdict = removeEmptyValues(~dict, ~key="outgoing_webhook_custom_http_headers")
  let metadataDict = removeEmptyValues(~dict, ~key="metadata")
  let authenticationConnectorDetails = dict->getDictfromDict("authentication_connector_details")

  {
    profile_name: dict->getString("profile_name", ""),
    collect_billing_details_from_wallet_connector: dict->getOptionBool(
      "collect_billing_details_from_wallet_connector",
    ),
    always_collect_billing_details_from_wallet_connector: dict->getOptionBool(
      "always_collect_billing_details_from_wallet_connector",
    ),
    is_connector_agnostic_mit_enabled: dict->getOptionBool("is_connector_agnostic_mit_enabled"),
    force_3ds_challenge: dict->getOptionBool("force_3ds_challenge"),
    is_debit_routing_enabled: dict->getOptionBool("is_debit_routing_enabled"),
    outgoing_webhook_custom_http_headers: Some(outgoingWebhookdict),
    metadata: Some(metadataDict),
    is_auto_retries_enabled: dict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: dict->getOptionInt("max_auto_retries_enabled"),
    is_click_to_pay_enabled: dict->getOptionBool("is_click_to_pay_enabled"),
    acquirer_configs: None,
    authentication_product_ids: Some(dict->getJsonObjectFromDict("authentication_product_ids")),
    merchant_category_code: dict->getOptionString("merchant_category_code"),
    is_network_tokenization_enabled: dict->getOptionBool("is_network_tokenization_enabled"),
    always_request_extended_authorization: dict->getOptionBool(
      "always_request_extended_authorization",
    ),
    is_manual_retry_enabled: dict->getOptionBool("is_manual_retry_enabled"),
    always_enable_overcapture: dict->getOptionBool("always_enable_overcapture"),
    return_url: dict->getOptionString("return_url"),
    payment_response_hash_key: dict->getOptionString("payment_response_hash_key"),
    webhook_details: {
      webhook_version: dict->getOptionString("webhook_version"),
      webhook_username: dict->getOptionString("webhook_username"),
      webhook_password: dict->getOptionString("webhook_password"),
      webhook_url: dict->getOptionString("webhook_url"),
      payment_created_enabled: dict->getOptionBool("payment_created_enabled"),
      payment_succeeded_enabled: dict->getOptionBool("payment_succeeded_enabled"),
      payment_failed_enabled: dict->getOptionBool("payment_failed_enabled"),
    },
    collect_shipping_details_from_wallet_connector: dict->getOptionBool(
      "collect_shipping_details_from_wallet_connector",
    ),
    always_collect_shipping_details_from_wallet_connector: dict->getOptionBool(
      "always_collect_shipping_details_from_wallet_connector",
    ),
    authentication_connector_details: if authenticationConnectorDetails->isEmptyDict {
      None
    } else {
      Some(
        authenticationConnectorDetails->BusinessProfileInterfaceUtils.constructAuthConnectorObject,
      )
    },
  }
}
