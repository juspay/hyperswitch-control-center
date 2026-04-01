// Default theme configuration
let themeDefaultJson = {
  "theme": "default",
  "locale": "en-gb",
  "layout": "tabs",
  "labels": "above",
  "primary_color": "#006DF9",
}->Identity.genericTypeToJson

let layoutMapper = val =>
  switch val {
  | "Accordion" => "accordion"
  | "Spaced Accordion" => "spaced"
  | "Tabs"
  | _ => "tabs"
  }

let getLocaleValueFromLabel = (label: string): string =>
  switch label {
  | "English (Global)" => "en-gb"
  | "French" => "fr"
  | "Arabic" => "ar"
  | "Japanese" => "ja"
  | "German" => "de"
  | "Spanish" => "es"
  | "Hebrew" => "he"
  | "Catalan" => "ca"
  | "Portuguese" => "pt"
  | "Italian" => "it"
  | "Polish" => "pl"
  | "Dutch" => "nl"
  | "Swedish" => "sv"
  | "Russian" => "ru"
  | "Chinese (Simplified)" => "zh"
  | "Chinese (Traditional)" => "zh-hant"
  | "French (Belgium)" => "fr-be"
  | "English" => "en"
  | _ => "en" // fallback
  }

let integrationType = ["Payment", "Unified Checkout"]

let theme = ["Default", "Brutal", "Midnight", "Soft", "Charcoal"]

let layouts = ["Tabs", "Accordion", "Spaced Accordion"]

let locales = [
  "English (Global)",
  "French",
  "Arabic",
  "Japanese",
  "German",
  "Spanish",
  "Hebrew",
  "Catalan",
  "Portuguese",
  "Italian",
  "Polish",
  "Dutch",
  "Swedish",
  "Russian",
  "Chinese (Simplified)",
  "Chinese (Traditional)",
  "French (Belgium)",
  "English",
]

let captureMethods = ["Automatic", "Manual"]

let setupFutureUsageOptions = ["Off Session", "On Session"]

let authenticationType = ["Three DS", "No Three DS"]

let requestExternal3dsAuthentication = ["True", "False"]

let showSavedCardOptions = ["Yes", "No"]

let labels = ["Above", "Floating"]

let initialValueForForm = (
  ~showSetupFutureUsage=false,
  ~sendAuthType=true,
  ~customCustomerId="hyperswitch_sdk_demo_id",
  ~profileId,
): SDKPaymentTypes.paymentType => {
  let setupFutureValue = showSetupFutureUsage ? Some("on_session") : None
  let authTypevalue = sendAuthType ? Some("three_ds") : None
  let shippingValue: SDKPaymentTypes.addressAndPhone = {
    address: {
      line1: "1600",
      line2: "Amphitheatre Parkway",
      city: "Mountain View",
      state: "California",
      zip: "94043",
      country: "US",
      first_name: "John",
      last_name: "Doe",
    },
    phone: {
      number: "6502530000",
      country_code: "+1",
    },
  }

  let billingValue: SDKPaymentTypes.addressAndPhone = {
    address: {
      line1: "1600",
      line2: "Amphitheatre Parkway",
      city: "Mountain View",
      state: "California",
      zip: "94043",
      country: "US",
      first_name: "John",
      last_name: "Doe",
    },
    phone: {
      number: "6502530000",
      country_code: "+1",
    },
  }

  {
    amount: 10000.00,
    currency: "USD",
    country_currency: "US-USD",
    profile_id: profileId,
    description: "Default value",
    customer_id: Some(customCustomerId),
    setup_future_usage: setupFutureValue,
    show_saved_card: "yes",
    request_external_three_ds_authentication: false,
    email: Nullable.make("guest@example.com"),
    authentication_type: authTypevalue,
    shipping: Some(shippingValue),
    billing: Some(billingValue),
    capture_method: "automatic",
  }
}

let getTypedPaymentData = (
  values,
  ~onlyEssential=false,
  ~showBillingAddress,
  ~isGuestMode,
  ~showSetupFutureUsage=false,
  ~sendAuthType=true,
) => {
  open LogicUtils
  open SDKPaymentTypes

  let dict = values->getDictFromJsonObject

  let getDict = key => dict->getDictfromDict(key)
  let getAddressAndPhone = section => {
    let address = section->getDictfromDict("address")
    let phone = section->getDictfromDict("phone")
    (address, phone)
  }

  let shipping = getDict("shipping")
  let billing = getDict("billing")
  let email = dict->getString("email", "")

  let (shippingAddress, shippingPhone) = getAddressAndPhone(shipping)
  let (billingAddress, billingPhone) = getAddressAndPhone(billing)
  let countryCurrency = dict->getString("country_currency", "US-USD")->String.split("-")
  let getCountry = () => countryCurrency->getValueFromArray(0, "US")
  let getCurrency = () => countryCurrency->getValueFromArray(1, "USD")

  let getAddress = address => {
    {
      line1: address->getString("line1", ""),
      line2: address->getString("line2", ""),
      city: address->getString("city", ""),
      state: address->getString("state", ""),
      zip: address->getString("zip", ""),
      country: getCountry(),
      first_name: address->getString("first_name", ""),
      last_name: address->getString("last_name", ""),
    }
  }

  let getPhone = phone => {
    {
      number: phone->getString("number", ""),
      country_code: phone->getString("country_code", ""),
    }
  }

  let createAddressAndPhone = (~address, ~phone) => {
    {
      address: address->getAddress,
      phone: phone->getPhone,
    }
  }

  let base = {
    amount: dict->getFloat("amount", 10000.0),
    currency: getCurrency(),
    profile_id: dict->getString("profile_id", ""),
    customer_id: !isGuestMode ? dict->getOptionString("customer_id") : None,
    description: dict->getString("description", "Payment Transaction"),
    email: email->isNonEmptyString ? Nullable.make(email) : Nullable.null,
    authentication_type: sendAuthType ? dict->getOptionString("authentication_type") : None,
    setup_future_usage: showSetupFutureUsage ? dict->getOptionString("setup_future_usage") : None,
    shipping: None,
    billing: None,
    capture_method: dict->getString("capture_method", "automatic"),
    request_external_three_ds_authentication: dict->getBool(
      "request_external_three_ds_authentication",
      false,
    ),
  }
  if onlyEssential {
    if showBillingAddress {
      {
        ...base,
        shipping: Some(createAddressAndPhone(~address=shippingAddress, ~phone=shippingPhone)),
        billing: Some(createAddressAndPhone(~address=billingAddress, ~phone=billingPhone)),
      }
    } else {
      base
    }
  } else {
    {
      ...base,
      show_saved_card: dict->getString("show_saved_card", "yes"),
      shipping: Some(createAddressAndPhone(~address=shippingAddress, ~phone=shippingPhone)),
      billing: Some(createAddressAndPhone(~address=billingAddress, ~phone=billingPhone)),
      country_currency: dict->getString("country_currency", "US-USD"),
    }
  }
}

let dropDownOptionsForCountryCurrency = Country.country->Array.map((
  item
): SelectBox.dropdownOption => {
  open CountryUtils
  let countryName = item.countryName->getCountryNameFromVariant->toReadableCountryName
  let countryCode = item.isoAlpha2->getCountryCodeStringFromVariant
  {
    label: `${item.flag} ${countryName} - (${item.currency})`,
    value: `${countryCode}-${item.currency}`,
  }
})

let dropDownOptionsForIntegrationType = integrationType->Array.map((
  item
): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase->String.split(" ")->Array.joinWith("_"),
})

let dropDownOptionsForLayouts = layouts->Array.map((item): SelectBox.dropdownOption => {
  label: item,
  value: item->layoutMapper,
})

let dropDownOptionsForLocales = locales->Array.map((item): SelectBox.dropdownOption => {
  label: item,
  value: item->getLocaleValueFromLabel,
})

let dropDownOptionsForTheme = theme->Array.map((item): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase->String.split(" ")->Array.joinWith("_"),
})

let dropDownOptionsForLabels = labels->Array.map((item): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase,
})

let dropDownOptionsForCaptureMethods = captureMethods->Array.map((
  item
): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase,
})

let dropDownOptionsForSetupFutureUsage = setupFutureUsageOptions->Array.map((
  item
): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase->String.split(" ")->Array.joinWith("_"),
})

let dropDownOptionsForAuthenticationType = authenticationType->Array.map((
  item
): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase->String.split(" ")->Array.joinWith("_"),
})

let dropDownOptionsForRequestThreeDSAuthentication = requestExternal3dsAuthentication->Array.map((
  item
): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase->String.split(" ")->Array.joinWith("_"),
})

let dropDownOptionsForShowSavedCard = showSavedCardOptions->Array.map((
  item
): SelectBox.dropdownOption => {
  label: item,
  value: item->String.toLowerCase,
})
