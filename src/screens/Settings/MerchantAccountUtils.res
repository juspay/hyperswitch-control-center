open HSwitchSettingTypes
let parseKey = api_key => {
  api_key->String.slice(~start=0, ~end=6)->String.concat(String.repeat("*", 20))
}

let parseBussinessProfileJson = (profileRecord: profileEntity) => {
  open LogicUtils
  let {
    merchant_id,
    profile_id,
    profile_name,
    webhook_details,
    return_url,
    payment_response_hash_key,
    authentication_connector_details,
    collect_shipping_details_from_wallet_connector,
    outgoing_webhook_custom_http_headers,
    is_connector_agnostic_mit_enabled,
    collect_billing_details_from_wallet_connector,
    always_collect_billing_details_from_wallet_connector,
    always_collect_shipping_details_from_wallet_connector,
  } = profileRecord

  let profileInfo =
    [
      ("merchant_id", merchant_id->JSON.Encode.string),
      ("profile_id", profile_id->JSON.Encode.string),
      ("profile_name", profile_name->JSON.Encode.string),
    ]->Dict.fromArray
  profileInfo->setDictNull("return_url", return_url)
  profileInfo->setOptionBool(
    "collect_shipping_details_from_wallet_connector",
    collect_shipping_details_from_wallet_connector,
  )
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

  profileInfo->setDictNull("webhook_url", webhook_details.webhook_url)
  profileInfo->setOptionString("webhook_version", webhook_details.webhook_version)
  profileInfo->setOptionString("webhook_username", webhook_details.webhook_username)
  profileInfo->setOptionString("webhook_password", webhook_details.webhook_password)
  profileInfo->setOptionBool("payment_created_enabled", webhook_details.payment_created_enabled)
  profileInfo->setOptionBool("payment_succeeded_enabled", webhook_details.payment_succeeded_enabled)
  profileInfo->setOptionBool("payment_failed_enabled", webhook_details.payment_failed_enabled)
  profileInfo->setOptionString("payment_response_hash_key", payment_response_hash_key)
  profileInfo->setOptionArray(
    "authentication_connectors",
    authentication_connector_details.authentication_connectors,
  )
  profileInfo->setOptionString(
    "three_ds_requestor_url",
    authentication_connector_details.three_ds_requestor_url,
  )
  profileInfo->setOptionBool("is_connector_agnostic_mit_enabled", is_connector_agnostic_mit_enabled)
  profileInfo->setOptionDict(
    "outgoing_webhook_custom_http_headers",
    outgoing_webhook_custom_http_headers,
  )
  profileInfo
}

let parseMerchantJson = (merchantDict: merchantPayload) => {
  open LogicUtils
  let {merchant_details, merchant_name, publishable_key, primary_business_details} = merchantDict
  let primary_business_details = primary_business_details->Array.map(detail => {
    let {country, business} = detail
    let props = [
      ("country", country->JSON.Encode.string),
      ("business", business->JSON.Encode.string),
    ]

    props->Dict.fromArray->JSON.Encode.object
  })
  let merchantInfo =
    [
      ("primary_business_details", primary_business_details->JSON.Encode.array),
      ("publishable_key", publishable_key->JSON.Encode.string),
      ("publishable_key_hide", publishable_key->parseKey->JSON.Encode.string),
    ]->Dict.fromArray
  merchantInfo->setOptionString("merchant_name", merchant_name)
  merchantInfo->setOptionString("about_business", merchant_details.about_business)
  merchantInfo->setOptionString("primary_email", merchant_details.primary_email)
  merchantInfo->setOptionString("primary_phone", merchant_details.primary_phone)
  merchantInfo->setOptionString("primary_contact_person", merchant_details.primary_contact_person)
  merchantInfo->setOptionString("website", merchant_details.website)
  merchantInfo->setOptionString("secondary_phone", merchant_details.secondary_phone)
  merchantInfo->setOptionString("secondary_email", merchant_details.secondary_email)
  merchantInfo->setOptionString(
    "secondary_contact_person",
    merchant_details.secondary_contact_person,
  )
  merchantInfo->setOptionString("primary_phone", merchant_details.primary_phone)

  merchantInfo->setOptionString("line1", merchant_details.address.line1)
  merchantInfo->setOptionString("line2", merchant_details.address.line2)
  merchantInfo->setOptionString("line3", merchant_details.address.line3)
  merchantInfo->setOptionString("city", merchant_details.address.city)
  merchantInfo->setOptionString("state", merchant_details.address.state)
  merchantInfo->setOptionString("zip", merchant_details.address.zip)

  merchantInfo
}

let getBusinessProfilePayload = (values: JSON.t) => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let webhookSettingsValue = Dict.make()
  webhookSettingsValue->setOptionString(
    "webhook_version",
    valuesDict->getOptionString("webhook_version"),
  )
  webhookSettingsValue->setOptionString(
    "webhook_username",
    valuesDict->getOptionString("webhook_username"),
  )
  webhookSettingsValue->setOptionString(
    "webhook_password",
    valuesDict->getOptionString("webhook_password"),
  )
  webhookSettingsValue->setDictNull(
    "webhook_url",
    valuesDict->getString("webhook_url", "")->getNonEmptyString,
  )
  webhookSettingsValue->setOptionBool(
    "payment_created_enabled",
    valuesDict->getOptionBool("payment_created_enabled"),
  )
  webhookSettingsValue->setOptionBool(
    "payment_succeeded_enabled",
    valuesDict->getOptionBool("payment_succeeded_enabled"),
  )
  webhookSettingsValue->setOptionBool(
    "payment_failed_enabled",
    valuesDict->getOptionBool("payment_failed_enabled"),
  )

  let authenticationConnectorDetails = Dict.make()
  authenticationConnectorDetails->setOptionArray(
    "authentication_connectors",
    valuesDict->getArrayFromDict("authentication_connectors", [])->getNonEmptyArray,
  )
  authenticationConnectorDetails->setOptionString(
    "three_ds_requestor_url",
    valuesDict->getString("three_ds_requestor_url", "")->getNonEmptyString,
  )

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

  let profileDetailsDict = Dict.make()
  profileDetailsDict->setDictNull(
    "return_url",
    valuesDict->getString("return_url", "")->getNonEmptyString,
  )
  profileDetailsDict->setOptionBool(
    "collect_shipping_details_from_wallet_connector",
    valuesDict->getOptionBool("collect_shipping_details_from_wallet_connector"),
  )
  profileDetailsDict->setOptionBool(
    "always_collect_shipping_details_from_wallet_connector",
    valuesDict->getOptionBool("always_collect_shipping_details_from_wallet_connector"),
  )
  profileDetailsDict->setOptionBool(
    "collect_billing_details_from_wallet_connector",
    valuesDict->getOptionBool("collect_billing_details_from_wallet_connector"),
  )
  profileDetailsDict->setOptionBool(
    "always_collect_billing_details_from_wallet_connector",
    valuesDict->getOptionBool("always_collect_billing_details_from_wallet_connector"),
  )
  profileDetailsDict->setOptionBool(
    "is_connector_agnostic_mit_enabled",
    valuesDict->getOptionBool("is_connector_agnostic_mit_enabled"),
  )

  profileDetailsDict->setOptionDict(
    "webhook_details",
    !(webhookSettingsValue->isEmptyDict) ? Some(webhookSettingsValue) : None,
  )
  profileDetailsDict->setOptionDict(
    "authentication_connector_details",
    !(authenticationConnectorDetails->isEmptyDict) ? Some(authenticationConnectorDetails) : None,
  )
  profileDetailsDict->setOptionDict(
    "outgoing_webhook_custom_http_headers",
    Some(outGoingWebHookCustomHttpHeaders),
  )
  profileDetailsDict
}

let getSettingsPayload = (values: JSON.t, merchantId) => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let addressDetailsValue = Dict.make()
  addressDetailsValue->setOptionString("line1", valuesDict->getOptionString("line1"))
  addressDetailsValue->setOptionString("line2", valuesDict->getOptionString("line2"))
  addressDetailsValue->setOptionString("line3", valuesDict->getOptionString("line3"))
  addressDetailsValue->setOptionString("city", valuesDict->getOptionString("city"))
  addressDetailsValue->setOptionString("state", valuesDict->getOptionString("state"))
  addressDetailsValue->setOptionString("zip", valuesDict->getOptionString("zip"))
  let merchantDetailsValue = Dict.make()
  merchantDetailsValue->setOptionString(
    "primary_contact_person",
    valuesDict->getOptionString("primary_contact_person"),
  )
  let primaryEmail = valuesDict->getOptionString("primary_email")
  if primaryEmail->Option.getOr("")->isNonEmptyString {
    merchantDetailsValue->setOptionString("primary_email", primaryEmail)
  }
  merchantDetailsValue->setOptionString(
    "primary_phone",
    valuesDict->getOptionString("primary_phone"),
  )
  merchantDetailsValue->setOptionString(
    "secondary_contact_person",
    valuesDict->getOptionString("secondary_contact_person"),
  )
  let secondaryEmail = valuesDict->getOptionString("secondary_email")
  if secondaryEmail->Option.getOr("")->isNonEmptyString {
    merchantDetailsValue->setOptionString(
      "secondary_email",
      valuesDict->getOptionString("secondary_email"),
    )
  }
  merchantDetailsValue->setOptionString(
    "secondary_phone",
    valuesDict->getOptionString("secondary_phone"),
  )
  merchantDetailsValue->setOptionString("website", valuesDict->getOptionString("website"))
  merchantDetailsValue->setOptionString(
    "about_business",
    valuesDict->getOptionString("about_business"),
  )
  merchantDetailsValue->setOptionString(
    "about_business",
    valuesDict->getOptionString("about_business"),
  )

  !(addressDetailsValue->isEmptyDict)
    ? merchantDetailsValue->Dict.set("address", addressDetailsValue->JSON.Encode.object)
    : ()

  let primary_business_details =
    valuesDict
    ->LogicUtils.getArrayFromDict("primary_business_details", [])
    ->Array.map(detail => {
      let detailDict = detail->LogicUtils.getDictFromJsonObject

      let detailDict =
        [
          ("business", detailDict->getString("business", "")->JSON.Encode.string),
          ("country", detailDict->getString("country", "")->JSON.Encode.string),
        ]->Dict.fromArray

      detailDict->JSON.Encode.object
    })

  let settingsPayload = Dict.fromArray([
    ("merchant_id", merchantId->JSON.Encode.string),
    ("locker_id", "m0010"->JSON.Encode.string),
  ])

  settingsPayload->setOptionDict(
    "merchant_details",
    !(merchantDetailsValue->isEmptyDict) ? Some(merchantDetailsValue) : None,
  )

  settingsPayload->setOptionString("merchant_name", valuesDict->getOptionString("merchant_name"))

  settingsPayload->setOptionArray(
    "primary_business_details",
    primary_business_details->getNonEmptyArray,
  )

  settingsPayload->JSON.Encode.object
}

let validationFieldsMapper = key => {
  switch key {
  | PrimaryEmail => "primary_email"
  | SecondaryEmail => "secondary_email"
  | PrimaryPhone => "primary_phone"
  | SecondaryPhone => "secondary_phone"
  | Website => "website"
  | WebhookUrl => "webhook_url"
  | ReturnUrl => "return_url"
  | AuthetnticationConnectors(_) => "authentication_connectors"
  | ThreeDsRequestorUrl => "three_ds_requestor_url"
  | UnknownValidateFields(key) => key
  }
}

let checkValueChange = (~initialDict, ~valuesDict) => {
  let initialKeys = Dict.keysToArray(initialDict)
  let updatedKeys = Dict.keysToArray(valuesDict)
  let key =
    initialDict
    ->Dict.keysToArray
    ->Array.find(key => {
      switch key {
      | "collect_shipping_details_from_wallet_connector" => {
          let initialValue = initialDict->LogicUtils.getBool(key, false)
          let updatedValue = valuesDict->LogicUtils.getBool(key, false)
          initialValue !== updatedValue
        }
      | "outgoing_webhook_custom_http_headers" => {
          let initialDictLength =
            initialDict
            ->LogicUtils.getDictfromDict("outgoing_webhook_custom_http_headers")
            ->Dict.keysToArray
          let updatedDictLength =
            valuesDict
            ->LogicUtils.getDictfromDict("outgoing_webhook_custom_http_headers")
            ->Dict.keysToArray
          initialDictLength != updatedDictLength
        }
      | _ => {
          let initialValue = initialDict->LogicUtils.getString(key, "")
          let updatedValue = valuesDict->LogicUtils.getString(key, "")
          initialValue !== updatedValue
        }
      }
    })
  key->Option.isSome || updatedKeys > initialKeys
}

let validateEmptyValue = (key, errors) => {
  switch key {
  | ReturnUrl =>
    Dict.set(errors, key->validationFieldsMapper, "Please enter a return url"->JSON.Encode.string)
  | _ => ()
  }
}

let validateEmptyArray = (key, errors, arrayValue) => {
  switch key {
  | AuthetnticationConnectors(_) =>
    if arrayValue->Array.length === 0 {
      Dict.set(
        errors,
        key->validationFieldsMapper,
        "Please select authentication connector"->JSON.Encode.string,
      )
    }
  | _ => ()
  }
}

let validateCustom = (key, errors, value, isLiveMode) => {
  switch key {
  | PrimaryEmail | SecondaryEmail =>
    if value->HSwitchUtils.isValidEmail {
      Dict.set(
        errors,
        key->validationFieldsMapper,
        "Please enter valid email id"->JSON.Encode.string,
      )
    }
  | PrimaryPhone | SecondaryPhone =>
    if !RegExp.test(%re("/^(?:\+\d{1,15}?[.-])??\d{3}?[.-]?\d{3}[.-]?\d{3,9}$/"), value) {
      Dict.set(
        errors,
        key->validationFieldsMapper,
        "Please enter valid phone number"->JSON.Encode.string,
      )
    }
  | Website | WebhookUrl | ReturnUrl | ThreeDsRequestorUrl => {
      let regexUrl = isLiveMode
        ? RegExp.test(%re("/^https:\/\//i"), value) || value->String.includes("localhost")
        : RegExp.test(%re("/^(http|https):\/\//i"), value)

      if !regexUrl {
        Dict.set(errors, key->validationFieldsMapper, "Please Enter Valid URL"->JSON.Encode.string)
      }
    }

  | _ => ()
  }
}

let validateMerchantAccountForm = (
  ~values: JSON.t,
  ~fieldsToValidate: array<validationFields>,
  ~isLiveMode,
) => {
  // Need to refactor
  open LogicUtils
  let errors = Dict.make()

  let valuesDict = values->getDictFromJsonObject
  fieldsToValidate->Array.forEach(key => {
    let value = getString(valuesDict, key->validationFieldsMapper, "")->getNonEmptyString
    switch value {
    | Some(str) => key->validateCustom(errors, str, isLiveMode)
    | _ => ()
    }
  })

  let threedsArray = getArrayFromDict(valuesDict, "authentication_connectors", [])->getNonEmptyArray
  let threedsUrl = getString(valuesDict, "three_ds_requestor_url", "")->getNonEmptyString
  switch threedsArray {
  | Some(valArr) => {
      let url = getString(valuesDict, "three_ds_requestor_url", "")
      AuthetnticationConnectors(valArr)->validateEmptyArray(errors, valArr)
      ThreeDsRequestorUrl->validateCustom(errors, url, isLiveMode)
    }
  | _ => ()
  }
  switch threedsUrl {
  | Some(str) => {
      let arr = getArrayFromDict(valuesDict, "authentication_connectors", [])
      AuthetnticationConnectors(arr)->validateEmptyArray(errors, arr)
      ThreeDsRequestorUrl->validateCustom(errors, str, isLiveMode)
    }
  | _ => ()
  }

  errors->JSON.Encode.object
}

let defaultValueForBusinessProfile = {
  merchant_id: "",
  profile_id: "",
  profile_name: "",
  return_url: None,
  payment_response_hash_key: None,
  webhook_details: {
    webhook_version: None,
    webhook_username: None,
    webhook_password: None,
    webhook_url: None,
    payment_created_enabled: None,
    payment_succeeded_enabled: None,
    payment_failed_enabled: None,
  },
  authentication_connector_details: {
    authentication_connectors: None,
    three_ds_requestor_url: None,
  },
  collect_shipping_details_from_wallet_connector: None,
  always_collect_shipping_details_from_wallet_connector: None,
  collect_billing_details_from_wallet_connector: None,
  always_collect_billing_details_from_wallet_connector: None,
  outgoing_webhook_custom_http_headers: None,
  is_connector_agnostic_mit_enabled: None,
}

let getValueFromBusinessProfile = businessProfileValue => {
  businessProfileValue->Array.get(0)->Option.getOr(defaultValueForBusinessProfile)
}

let businessProfileNameDropDownOption = arrBusinessProfile =>
  arrBusinessProfile->Array.map(ele => {
    let obj: SelectBox.dropdownOption = {
      label: {`${ele.profile_name} (${ele.profile_id})`},
      value: ele.profile_id,
    }
    obj
  })
