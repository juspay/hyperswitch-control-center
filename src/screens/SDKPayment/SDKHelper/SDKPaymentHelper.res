open SDKPaymentUtils

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

let enterCustomerId = (~isGuestMode, ~setIsGuestMode) => {
  FormRenderer.makeFieldInfo(
    ~label="Customer ID",
    ~name="customer_id",
    ~customInput=(~input, ~placeholder as _) =>
      InputFields.textInput(
        ~isDisabled=isGuestMode,
        ~customStyle="w-full border-nd_gray-200 rounded-lg",
      )(
        ~input={
          ...input,
          onChange: ev => input.onChange(ev),
        },
        ~placeholder="Enter Customer ID",
      ),
    ~labelRightComponent=<div className="flex items-center gap-2">
      <span className="text-sm text-gray-600"> {"Guest Mode"->React.string} </span>
      <input
        type_="checkbox"
        className="rounded border-gray-300"
        onChange={_ => setIsGuestMode(prev => !prev)}
      />
    </div>,
  )
}

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
  ~name="labels",
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

let selectShowSavedCardField = FormRenderer.makeFieldInfo(
  ~label="Show Saved Card",
  ~name="show_saved_card",
  ~placeholder="",
  ~customInput=InputFields.selectInput(
    ~options=dropDownOptionsForShowSavedCard,
    ~buttonText="Select Option",
    ~deselectDisable=true,
    ~fullLength=true,
    ~textStyle="!font-normal",
  ),
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
