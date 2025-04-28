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

let countries: array<ReactHyperJs.country> = [
  {
    isoAlpha3: "ARE",
    currency: "AED",
    countryName: "United Arab Emirates",
    isoAlpha2: "AE",
    icon: `🇦🇪`,
  },
  {
    isoAlpha3: "AUS",
    currency: "AUD",
    countryName: "Australia",
    isoAlpha2: "AU",
    icon: `🇦🇺`,
  },
  {
    isoAlpha3: "BRA",
    currency: "BRL",
    countryName: "Brazil",
    isoAlpha2: "BR",
    icon: `🇧🇷`,
  },
  {
    isoAlpha3: "CHN",
    currency: "CNY",
    countryName: "China",
    isoAlpha2: "CN",
    icon: `🇨🇳`,
  },
  {
    isoAlpha3: "DEU",
    currency: "EUR",
    countryName: "Germany",
    isoAlpha2: "DE",
    icon: `🇩🇪`,
  },
  {
    isoAlpha3: "GBR",
    currency: "GBP",
    countryName: "United Kingdom",
    isoAlpha2: "GB",
    icon: `🇬🇧`,
  },
  {
    isoAlpha3: "IDN",
    currency: "IDR",
    countryName: "Indonesia",
    isoAlpha2: "ID",
    icon: `🇮🇩`,
  },
  {
    isoAlpha3: "JPN",
    currency: "JPY",
    countryName: "Japan",
    isoAlpha2: "JP",
    icon: `🇯🇵`,
  },
  {
    isoAlpha3: "MEX",
    currency: "MXN",
    countryName: "Mexico",
    isoAlpha2: "MX",
    icon: `🇲🇽`,
  },
  {
    isoAlpha3: "MYS",
    currency: "MYR",
    countryName: "Malaysia",
    isoAlpha2: "MY",
    icon: `🇲🇾`,
  },
  {
    isoAlpha3: "POL",
    currency: "PLN",
    countryName: "Poland",
    isoAlpha2: "PL",
    icon: `🇵🇱`,
  },
  {
    isoAlpha3: "SGP",
    currency: "SGD",
    countryName: "Singapore",
    isoAlpha2: "SG",
    icon: `🇸🇬`,
  },
  {
    isoAlpha3: "THA",
    currency: "THB",
    countryName: "Thailand",
    isoAlpha2: "TH",
    icon: `🇹🇭`,
  },
  {
    isoAlpha3: "USA",
    currency: "USD",
    countryName: "United States",
    isoAlpha2: "US",
    icon: `🇺🇸`,
  },
  {
    isoAlpha3: "NLD",
    currency: "EUR",
    countryName: "Netherlands",
    isoAlpha2: "NL",
    icon: `🇳🇱`,
  },
  {
    isoAlpha3: "FRA",
    currency: "EUR",
    countryName: "France",
    isoAlpha2: "FR",
    icon: `🇫🇷`,
  },
  {
    isoAlpha3: "HKG",
    currency: "HKD",
    countryName: "Hong Kong SAR",
    isoAlpha2: "HK",
    icon: `🇭🇰`,
  },
  {
    isoAlpha3: "ITA",
    currency: "EUR",
    countryName: "Italy",
    isoAlpha2: "IT",
    icon: `🇮🇹`,
  },
  {
    isoAlpha3: "CHE",
    currency: "CHF",
    countryName: "Switzerland",
    isoAlpha2: "CH",
    icon: `🇨🇭`,
  },
  {
    isoAlpha3: "CAN",
    currency: "CAD",
    countryName: "Canada",
    isoAlpha2: "CA",
    icon: `🇨🇦`,
  },
  {
    isoAlpha3: "ESP",
    currency: "EUR",
    countryName: "Spain",
    isoAlpha2: "ES",
    icon: `🇪🇸`,
  },
  {
    isoAlpha3: "PRT",
    currency: "EUR",
    countryName: "Portugal",
    isoAlpha2: "PT",
    icon: `🇵🇹`,
  },
  {
    isoAlpha3: "NOR",
    currency: "NOK",
    countryName: "Norway",
    isoAlpha2: "NO",
    icon: `🇳🇴`,
  },
  {
    isoAlpha3: "SWE",
    currency: "SEK",
    countryName: "Sweden",
    isoAlpha2: "SE",
    icon: `🇸🇪`,
  },
  {
    isoAlpha3: "FIN",
    currency: "EUR",
    countryName: "Finland",
    isoAlpha2: "FI",
    icon: `🇫🇮`,
  },
]

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

let labels = ["Above", "Floating"]

let initialValueForForm: HSwitchSettingTypes.profileEntity => SDKPaymentTypes.paymentType = defaultBusinessProfile => {
  {
    amount: 10000.00,
    currency: "USD",
    country_currency: "US-USD",
    profile_id: defaultBusinessProfile.profile_id,
    description: "Default value",
    customer_id: "hyperswitch_sdk_demo_id",
    setup_future_usage: "off_session",
    request_external_three_ds_authentication: true,
    email: "guest@example.com",
    authentication_type: "no_three_ds",
    shipping: {
      address: {
        line1: "1600 Amphitheatre Parkway",
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
    },
    billing: {
      address: {
        line1: "1600 Amphitheatre Parkway",
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
    },
    capture_method: "automatic",
    theme: "default",
    locale: "en-gb",
    innerLayout: "accordion",
    labels: "above",
  }
}

let getTypedValueForPayment = values => {
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

  let (shippingAddress, shippingPhone) = getAddressAndPhone(shipping)
  let (billingAddress, billingPhone) = getAddressAndPhone(billing)

  let amount = dict->getFloat("amount", 10000.0)
  let countryCurrency = dict->getString("country_currency", "US-USD")->String.split("-")

  let getCountry = () => countryCurrency->Array.at(0)->Option.getOr("US")
  let getCurrency = () => countryCurrency->Array.at(1)->Option.getOr("USD")

  let getAddress = address => {
    {
      line1: address->getString("line1", ""),
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

  {
    amount,
    currency: getCurrency(),
    profile_id: dict->getString("profile_id", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", "Payment Transaction"),
    email: dict->getString("email", ""),
    authentication_type: dict->getString("authentication_type", ""),
    shipping: {
      address: shippingAddress->getAddress,
      phone: shippingPhone->getPhone,
    },
    billing: {
      address: billingAddress->getAddress,
      phone: billingPhone->getPhone,
    },
    capture_method: "automatic",
    setup_future_usage: "off_session",
    request_external_three_ds_authentication: dict->getBool(
      "request_external_three_ds_authentication",
      false,
    ),
  }
}

let dropDownOptionsForCountryCurrency = countries->Array.map((item): SelectBox.dropdownOption => {
  label: `${item.icon} ${item.countryName} - (${item.currency})`,
  value: `${item.isoAlpha2}-${item.currency}`,
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

let enterAmountField = (initialValues: SDKPaymentTypes.paymentType) => {
  FormRenderer.makeFieldInfo(~label="Enter amount", ~name="amount", ~customInput=(
    ~input,
    ~placeholder as _,
  ) =>
    InputFields.numericTextInput(
      ~isDisabled=false,
      ~customStyle="w-full border-nd_gray-200 rounded-lg",
      ~precision=2,
    )(
      ~input={
        ...input,
        value: (initialValues.amount /. 100.00)->Float.toString->JSON.Encode.string,
        onChange: {
          ev => {
            let eventValueToFloat =
              ev->Identity.formReactEventToString->LogicUtils.getFloatFromString(0.00)
            let valInCents =
              (eventValueToFloat *. 100.00)->Float.toString->Identity.stringToFormReactEvent
            input.onChange(valInCents)
          }
        },
      },
      ~placeholder="Enter amount",
    )
  )
}

let enterPrimaryColorValue = defaultValue =>
  FormRenderer.makeFieldInfo(
    ~label="Color Picker Input",
    ~name="primary_color",
    ~placeholder="",
    ~isRequired=false,
    ~customInput=InputFields.colorPickerInput(~defaultValue),
  )

let enterCustomerId = FormRenderer.makeFieldInfo(
  ~label="Customer ID",
  ~name="customer_id",
  ~customInput=(~input, ~placeholder as _) =>
    InputFields.textInput(~isDisabled=false, ~customStyle="w-full border-nd_gray-200 rounded-lg")(
      ~input={
        ...input,
        onChange: ev => input.onChange(ev),
      },
      ~placeholder="Enter Customer ID",
    ),
)

let selectEnterIntegrationType = FormRenderer.makeFieldInfo(
  ~label="Integration Type",
  ~name="integration_type",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForIntegrationType,
    ~buttonText="Select Integration Type",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectCurrencyField = FormRenderer.makeFieldInfo(
  ~label="Currency",
  ~name="country_currency",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForCountryCurrency,
    ~buttonText="Select Currency",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectThemeField = FormRenderer.makeFieldInfo(
  ~label="Theme",
  ~name="theme",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForTheme,
    ~buttonText="Select Theme",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectLocaleField = FormRenderer.makeFieldInfo(
  ~label="Locale",
  ~name="locale",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForLocales,
    ~buttonText="Select Locale",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectLayoutField = FormRenderer.makeFieldInfo(
  ~label="Layout",
  ~name="layout",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForLayouts,
    ~buttonText="Select Layout",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectLabelsField = FormRenderer.makeFieldInfo(
  ~label="Labels",
  ~name="label",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForLabels,
    ~buttonText="Select Label",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectCaptureMethodField = FormRenderer.makeFieldInfo(
  ~label="Capture Method",
  ~name="capture_method",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForCaptureMethods,
    ~buttonText="Select Capture Method",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectSetupFutureUsageField = FormRenderer.makeFieldInfo(
  ~label="Setup Future Usage",
  ~name="setup_future_usage",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForSetupFutureUsage,
    ~buttonText="Select Setup Future Usage",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectAuthenticationField = FormRenderer.makeFieldInfo(
  ~label="Authentication Type",
  ~name="authentication_type",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForAuthenticationType,
    ~buttonText="Select Authentication Type",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let selectExternal3DSAuthentication = FormRenderer.makeFieldInfo(
  ~label="Request External 3DS Authentication",
  ~name="request_external_three_ds_authentication",
  ~placeholder="",
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.selectInput(
      ~customStyle="max-h-48",
      ~options={dropDownOptionsForRequestThreeDSAuthentication},
      ~buttonText="Select Value",
    )(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="",
    )
  },
)

let external3DSAuthToggle = FormRenderer.makeFieldInfo(
  ~name="request_external_three_ds_authentication",
  ~label="Request External 3DS Authentication",
  ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
)

let enterEmailField = FormRenderer.makeFieldInfo(
  ~label="Email",
  ~name="email",
  ~placeholder="Enter your Email",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Email",
    )
  },
)

let enterBillingFirstName = FormRenderer.makeFieldInfo(
  ~label="First Name",
  ~name="billing.address.first_name",
  ~placeholder="Enter your First Name",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Name",
    )
  },
)

let enterBillingLastName = FormRenderer.makeFieldInfo(
  ~label="Last Name",
  ~name="billing.address.last_name",
  ~placeholder="Enter your Last Name",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Last Name",
    )
  },
)

let enterBillingAddress = FormRenderer.makeFieldInfo(
  ~label="Address",
  ~name="billing.address.line1",
  ~placeholder="Enter your Address",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Address",
    )
  },
)

let enterBillingCity = FormRenderer.makeFieldInfo(
  ~label="City",
  ~name="billing.address.city",
  ~placeholder="Enter your City",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your City",
    )
  },
)

let enterBillingState = FormRenderer.makeFieldInfo(
  ~label="City",
  ~name="billing.address.state",
  ~placeholder="Enter your State",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your State",
    )
  },
)

let enterBillingCountry = FormRenderer.makeFieldInfo(
  ~label="Country",
  ~name="billing.address.country",
  ~placeholder="Enter your Country",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your country",
    )
  },
)

let enterBillingZipcode = FormRenderer.makeFieldInfo(
  ~label="Zipcode",
  ~name="billing.address.zip",
  ~placeholder="Enter your zipcode",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your zipcode",
    )
  },
)

let selectCountryPhoneCodeFieldForBilling = FormRenderer.makeFieldInfo(
  ~label="Phone Number",
  ~name="billing.phone.country_code",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=Country.country->Array.map((item): SelectBox.dropdownOption => {
      label: `${item.flag} ${item.phoneCode}`,
      value: item.phoneCode,
    }),
    ~buttonText="Select Country Code",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let enterBillingPhoneNumber = {
  FormRenderer.makeFieldInfo(
    ~label="",
    ~name="billing.phone.number",
    ~customInput=InputFields.numericTextInput(
      ~isDisabled=false,
      ~customStyle="w-full border-nd_gray-200 rounded-lg mt-[20px]",
    ),
  )
}

let enterShippingFirstName = FormRenderer.makeFieldInfo(
  ~label="First Name",
  ~name="shipping.address.first_name",
  ~placeholder="Enter your First Name",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Name",
    )
  },
)

let enterShippingLastName = FormRenderer.makeFieldInfo(
  ~label="Last Name",
  ~name="shipping.address.last_name",
  ~placeholder="Enter your Last Name",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Last Name",
    )
  },
)

let enterShippingAddress = FormRenderer.makeFieldInfo(
  ~label="Address",
  ~name="shipping.address.line1",
  ~placeholder="Enter your Address",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Address",
    )
  },
)

let enterShippingCity = FormRenderer.makeFieldInfo(
  ~label="City",
  ~name="shipping.address.city",
  ~placeholder="Enter your City",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your City",
    )
  },
)

let enterShippingState = FormRenderer.makeFieldInfo(
  ~label="City",
  ~name="shipping.address.state",
  ~placeholder="Enter your State",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your State",
    )
  },
)

let enterShippingCountry = FormRenderer.makeFieldInfo(
  ~label="Country",
  ~name="shipping.address.country",
  ~placeholder="Enter your Country",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your country",
    )
  },
)

let enterShippingZipcode = FormRenderer.makeFieldInfo(
  ~label="Zipcode",
  ~name="shipping.address.zip",
  ~placeholder="Enter your zipcode",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) => {
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your zipcode",
    )
  },
)

let selectCountryPhoneCodeFieldForShipping = FormRenderer.makeFieldInfo(
  ~label="Phone Number",
  ~name="shipping.phone.country_code",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=Country.country->Array.map((item): SelectBox.dropdownOption => {
      label: `${item.flag} ${item.phoneCode}`,
      value: item.phoneCode,
    }),
    ~buttonText="Select Country Code",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
)

let enterShippingPhoneNumber = {
  FormRenderer.makeFieldInfo(
    ~label="",
    ~name="shipping.phone.number",
    ~customInput=InputFields.numericTextInput(
      ~isDisabled=false,
      ~customStyle="w-full border-nd_gray-200 rounded-lg mt-[20px]",
    ),
  )
}
