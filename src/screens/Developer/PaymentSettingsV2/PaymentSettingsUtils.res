type validationFieldsV2 =
  | WebhookDetails
  | ReturnUrl
  | AuthenticationConnectorDetails
  | AuthenticationConnectors(array<JSON.t>)
  | ThreeDsRequestorUrl
  | ThreeDsRequestorAppUrl
  | MaxAutoRetries
  | AutoRetry
  | UnknownValidateFields(string)

let parseBusinessProfileForPaymentBehaviour = (
  profileRecord: HSwitchSettingTypes.profileEntity,
) => {
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

  profileInfo
}

let validateEmptyArray = (key, errors, arrayValue) => {
  switch key {
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
    if value->LogicUtils.isEmptyString {
      Dict.set(errors, "three_ds_requestor_app_url", "URL cannot be empty"->JSON.Encode.string)
    } else {
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
    }
  | _ => ()
  }
}

let validationFieldsReverseMapperV2 = value => {
  switch value {
  | "webhook_details" => WebhookDetails
  | "return_url" => ReturnUrl
  | "authentication_details.authentication_connectors" => AuthenticationConnectors([])
  | "authentication_details.three_ds_requestor_url" => ThreeDsRequestorUrl
  | "max_auto_retries_enabled" => MaxAutoRetries
  | "is_auto_retries_enabled" => AutoRetry
  | "authentication_details.three_ds_requestor_app_url" => ThreeDsRequestorAppUrl
  | "authentication_connector_details" => AuthenticationConnectorDetails
  | _ => UnknownValidateFields(value)
  }
}
let validateMerchantAccountFormV2 = (~values: JSON.t, ~isLiveMode) => {
  // Need to refactor
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
      let authenticationConnectorDetailsDict =
        valuesDict->getDictfromDict("authentication_connector_details")
      let threedsArray =
        authenticationConnectorDetailsDict
        ->getArrayFromDict("authentication_connectors", [])
        ->getNonEmptyArray
      let threedsUrl =
        authenticationConnectorDetailsDict
        ->getString("three_ds_requestor_url", "")
        ->getNonEmptyString
      let threedsAppUrl =
        authenticationConnectorDetailsDict
        ->getString("three_ds_requestor_app_url", "")
        ->getNonEmptyString
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
