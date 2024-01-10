open HSwitchSettingTypes
let parseKey = api_key => {
  api_key->String.slice(~start=0, ~end=6)->String.concat(String.repeat("*", 20))
}

let passwordKeyValidation = (value, key, keyVal, errors) => {
  let mustHave: array<string> = []
  if value->String.length > 0 && key === keyVal {
    if value->String.length < 8 {
      Dict.set(
        errors,
        key,
        "Your password is not strong enough. Password size must be more than 8"->Js.Json.string,
      )
    } else {
      if !Js.Re.test_(%re("/^(?=.*[A-Z])/"), value) {
        mustHave->Array.push("uppercase")
      }
      if !Js.Re.test_(%re("/^(?=.*[a-z])/"), value) {
        mustHave->Array.push("lowercase")
      }
      if !Js.Re.test_(%re("/^(?=.*[0-9])/"), value) {
        mustHave->Array.push("numeric")
      }
      if !Js.Re.test_(%re("/^(?=.*[!@#$%^&*_])/"), value) {
        mustHave->Array.push("special")
      }
      if mustHave->Array.length > 0 {
        Dict.set(
          errors,
          key,
          `Your password is not strong enough. A good password must contain atleast ${mustHave->Array.joinWith(
              ",",
            )} character`->Js.Json.string,
        )
      }
    }
  }
}

let confirmPasswordCheck = (value, key, confirmKey, passwordKey, valuesDict, errors) => {
  if (
    key === confirmKey &&
    value !== "" &&
    !Js.Option.equal(
      (. a, b) => a == b,
      Dict.get(valuesDict, passwordKey),
      Dict.get(valuesDict, key),
    )
  ) {
    Dict.set(errors, key, "The New password does not match!"->Js.Json.string)
  }
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
  } = profileRecord
  let profileInfo =
    [
      ("merchant_id", merchant_id->Js.Json.string),
      ("profile_id", profile_id->Js.Json.string),
      ("profile_name", profile_name->Js.Json.string),
    ]->Dict.fromArray
  profileInfo->setOptionString("return_url", return_url)
  profileInfo->setOptionString("webhook_version", webhook_details.webhook_version)
  profileInfo->setOptionString("webhook_username", webhook_details.webhook_username)
  profileInfo->setOptionString("webhook_password", webhook_details.webhook_password)
  profileInfo->setOptionString("webhook_url", webhook_details.webhook_url)
  profileInfo->setOptionBool("payment_created_enabled", webhook_details.payment_created_enabled)
  profileInfo->setOptionBool("payment_succeeded_enabled", webhook_details.payment_succeeded_enabled)
  profileInfo->setOptionBool("payment_failed_enabled", webhook_details.payment_failed_enabled)
  profileInfo->setOptionString("payment_response_hash_key", payment_response_hash_key)
  profileInfo
}

let parseMerchantJson = (merchantDict: merchantPayload) => {
  open LogicUtils
  let {merchant_details, merchant_name, publishable_key, primary_business_details} = merchantDict
  let primary_business_details = primary_business_details->Array.map(detail => {
    let {country, business} = detail
    let props = [("country", country->Js.Json.string), ("business", business->Js.Json.string)]

    props->Dict.fromArray->Js.Json.object_
  })
  let merchantInfo =
    [
      ("primary_business_details", primary_business_details->Js.Json.array),
      ("merchant_name", merchant_name->Js.Json.string),
      ("publishable_key", publishable_key->Js.Json.string),
      ("publishable_key_hide", publishable_key->parseKey->Js.Json.string),
    ]->Dict.fromArray

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

let getMerchantDetails = (values: Js.Json.t) => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let merchantDetails = valuesDict->getObj("merchant_details", Dict.make())
  let address = merchantDetails->getObj("address", Dict.make())

  let primary_business_details =
    valuesDict
    ->getArrayFromDict("primary_business_details", [])
    ->Array.map(detail => {
      let detailDict = detail->getDictFromJsonObject

      let info = {
        business: detailDict->getString("business", ""),
        country: detailDict->getString("country", ""),
      }

      info
    })

  let reconStatusMapper = reconStatus => {
    switch reconStatus->String.toLowerCase {
    | "notrequested" => NotRequested
    | "requested" => Requested
    | "active" => Active
    | "disabled" => Disabled
    | _ => NotRequested
    }
  }

  let payload: merchantPayload = {
    merchant_name: valuesDict->getString("merchant_name", ""),
    api_key: valuesDict->getString("api_key", ""),
    publishable_key: valuesDict->getString("publishable_key", ""),
    merchant_id: valuesDict->getString("merchant_id", ""),
    locker_id: valuesDict->getString("locker_id", ""),
    primary_business_details,
    merchant_details: {
      primary_contact_person: merchantDetails->getOptionString("primary_contact_person"),
      primary_email: merchantDetails->getOptionString("primary_email"),
      primary_phone: merchantDetails->getOptionString("primary_phone"),
      secondary_contact_person: merchantDetails->getOptionString("secondary_contact_person"),
      secondary_email: merchantDetails->getOptionString("secondary_email"),
      secondary_phone: merchantDetails->getOptionString("secondary_phone"),
      website: merchantDetails->getOptionString("website"),
      about_business: merchantDetails->getOptionString("about_business"),
      address: {
        line1: address->getOptionString("line1"),
        line2: address->getOptionString("line2"),
        line3: address->getOptionString("line3"),
        city: address->getOptionString("city"),
        state: address->getOptionString("state"),
        zip: address->getOptionString("zip"),
      },
    },
    enable_payment_response_hash: getBool(valuesDict, "enable_payment_response_hash", false),
    sub_merchants_enabled: getBool(valuesDict, "sub_merchants_enabled", false),
    metadata: valuesDict->getString("metadata", ""),
    parent_merchant_id: valuesDict->getString("parent_merchant_id", ""),
    payment_response_hash_key: valuesDict->getOptionString("payment_response_hash_key"),
    redirect_to_merchant_with_http_post: getBool(
      valuesDict,
      "redirect_to_merchant_with_http_post",
      true,
    ),
    recon_status: getString(valuesDict, "recon_status", "")->reconStatusMapper,
  }
  payload
}

let getBusinessProfilePayload = (values: Js.Json.t) => {
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
  webhookSettingsValue->setOptionString("webhook_url", valuesDict->getOptionString("webhook_url"))
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

  let profileDetailsDict = Dict.make()
  profileDetailsDict->setOptionString("return_url", valuesDict->getOptionString("return_url"))
  profileDetailsDict->setOptionDict(
    "webhook_details",
    !(webhookSettingsValue->isEmptyDict) ? Some(webhookSettingsValue) : None,
  )
  profileDetailsDict
}

let getSettingsPayload = (values: Js.Json.t, merchantId) => {
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
  if primaryEmail->Belt.Option.getWithDefault("")->String.length > 0 {
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
  if secondaryEmail->Belt.Option.getWithDefault("")->String.length > 0 {
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
    ? merchantDetailsValue->Dict.set("address", addressDetailsValue->Js.Json.object_)
    : ()

  let primary_business_details =
    valuesDict
    ->LogicUtils.getArrayFromDict("primary_business_details", [])
    ->Array.map(detail => {
      let detailDict = detail->LogicUtils.getDictFromJsonObject

      let detailDict =
        [
          ("business", detailDict->getString("business", "")->Js.Json.string),
          ("country", detailDict->getString("country", "")->Js.Json.string),
        ]->Dict.fromArray

      detailDict->Js.Json.object_
    })

  let settingsPayload = Dict.fromArray([
    ("merchant_id", merchantId->Js.Json.string),
    ("locker_id", "m0010"->Js.Json.string),
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

  settingsPayload->Js.Json.object_
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
      let initialValue = initialDict->LogicUtils.getString(key, "")
      let updatedValue = valuesDict->LogicUtils.getString(key, "")

      initialValue !== updatedValue
    })
  key->Belt.Option.isSome || updatedKeys > initialKeys
}

let validateEmptyValue = (key, errors) => {
  switch key {
  | ReturnUrl =>
    Dict.set(errors, key->validationFieldsMapper, "Please enter a return url"->Js.Json.string)
  | _ => ()
  }
}

let validateCustom = (key, errors, value) => {
  switch key {
  | PrimaryEmail | SecondaryEmail =>
    if value->HSwitchUtils.isValidEmail {
      Dict.set(errors, key->validationFieldsMapper, "Please enter valid email id"->Js.Json.string)
    }
  | PrimaryPhone | SecondaryPhone =>
    if !Js.Re.test_(%re("/^(?:\+\d{1,15}?[.-])??\d{3}?[.-]?\d{3}[.-]?\d{3,9}$/"), value) {
      Dict.set(
        errors,
        key->validationFieldsMapper,
        "Please enter valid phone number"->Js.Json.string,
      )
    }
  | Website | WebhookUrl | ReturnUrl =>
    if !Js.Re.test_(%re("/^https:\/\//i"), value) || value->String.includes("localhost") {
      Dict.set(errors, key->validationFieldsMapper, "Please Enter Valid URL"->Js.Json.string)
    }

  | _ => ()
  }
}

let validateMerchantAccountForm = (
  ~values: Js.Json.t,
  ~fieldsToValidate: array<validationFields>,
  ~setIsDisabled,
  ~initialData,
) => {
  let errors = Dict.make()
  let initialDict = initialData->LogicUtils.getDictFromJsonObject
  let valuesDict = values->LogicUtils.getDictFromJsonObject

  fieldsToValidate->Array.forEach(key => {
    let value = LogicUtils.getString(valuesDict, key->validationFieldsMapper, "")

    value->String.length <= 0 ? key->validateEmptyValue(errors) : key->validateCustom(errors, value)
  })

  setIsDisabled->Belt.Option.mapWithDefault((), disableBtn => {
    let isValueChanged = checkValueChange(~initialDict, ~valuesDict)
    disableBtn(_ => !isValueChanged)
  })

  errors->Js.Json.object_
}

let businessProfileTypeMapper = values => {
  open LogicUtils
  let jsonDict = values->getDictFromJsonObject
  let webhookDetailsDict = jsonDict->getDictfromDict("webhook_details")
  let businessProfile = {
    merchant_id: jsonDict->getString("merchant_id", ""),
    profile_id: jsonDict->getString("profile_id", ""),
    profile_name: jsonDict->getString("profile_name", ""),
    return_url: jsonDict->getOptionString("return_url"),
    payment_response_hash_key: jsonDict->getOptionString("payment_response_hash_key"),
    webhook_details: webhookDetailsDict->constructWebhookDetailsObject,
  }
  businessProfile
}

let convertObjectToType = value => {
  value->Js.Array2.reverseInPlace->Array.map(businessProfileTypeMapper)
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
}

let getArrayOfBusinessProfile = businessProfileValue => {
  open LogicUtils
  businessProfileValue->safeParse->getArrayFromJson([])->convertObjectToType
}

let getValueFromBusinessProfile = businessProfileValue => {
  open LogicUtils
  let businessDetails =
    businessProfileValue
    ->safeParse
    ->getArrayFromJson([])
    ->Js.Array2.reverseInPlace
    ->convertObjectToType
  businessDetails->Belt.Array.get(0)->Belt.Option.getWithDefault(defaultValueForBusinessProfile)
}

let useGetBusinessProflile = profileId => {
  HyperswitchAtom.businessProfilesAtom
  ->Recoil.useRecoilValueFromAtom
  ->getArrayOfBusinessProfile
  ->Array.find(profile => profile.profile_id == profileId)
  ->Belt.Option.getWithDefault(defaultValueForBusinessProfile)
}

module BusinessProfile = {
  @react.component
  let make = (~profile_id: string, ~className="") => {
    let {profile_name} = useGetBusinessProflile(profile_id)
    <div className> {(profile_name->String.length > 0 ? profile_name : "NA")->React.string} </div>
  }
}

let businessProfileNameDropDownOption = arrBusinessProfile =>
  arrBusinessProfile->Array.map(ele => {
    let obj: SelectBox.dropdownOption = {
      label: {`${ele.profile_name} (${ele.profile_id})`},
      value: ele.profile_id,
    }
    obj
  })

let useFetchBusinessProfiles = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let setBusinessProfiles = Recoil.useSetRecoilState(HyperswitchAtom.businessProfilesAtom)

  async _ => {
    try {
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Get, ())
      let res = await fetchDetails(url)
      let stringifiedResponse = res->Js.Json.stringify
      setBusinessProfiles(._ => stringifiedResponse)
      Js.Nullable.return(stringifiedResponse->getValueFromBusinessProfile)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        Js.Exn.raiseError(err)
      }
    }
  }
}

let useFetchMerchantDetails = () => {
  let setMerchantDetailsValue = Recoil.useSetRecoilState(HyperswitchAtom.merchantDetailsValueAtom)

  let fetchDetails = APIUtils.useGetMethod()

  async _ => {
    try {
      let accountUrl = APIUtils.getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get, ())
      let merchantDetailsJSON = await fetchDetails(accountUrl)
      setMerchantDetailsValue(._ => merchantDetailsJSON->Js.Json.stringify)
    } catch {
    | _ => ()
    }
  }
}
