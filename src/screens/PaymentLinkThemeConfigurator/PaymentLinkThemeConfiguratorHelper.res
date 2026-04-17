open FormRenderer

let defaultForbiddenCharsRegex = %re("/[<>{}|\\`]/g")
let nameForbiddenCharsRegex = %re("/[<>{}|\\`=;*@^~]/g")
let urlForbiddenCharsRegex = %re("/[<>{}|\\`\"'\s]/g")

let sanitizeTextInput = (~regex=defaultForbiddenCharsRegex, value) =>
  value->String.replaceRegExp(regex, "")

let makeSanitizedTextField = (
  ~label,
  ~name,
  ~placeholder,
  ~forbiddenCharsRegex=defaultForbiddenCharsRegex,
) =>
  makeFieldInfo(~label, ~name, ~customInput=(~input, ~placeholder as _) =>
    InputFields.textInput()(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trimStart
          ->sanitizeTextInput(~regex=forbiddenCharsRegex)
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder,
    )
  )

let makeThemeField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Theme Color",
    ~name="theme",
    ~placeholder="Select Theme Color",
    ~customInput=InputFields.colorPickerInput(~defaultValue, ~showErrorWhenEmpty=false),
  )
}

let makeLogoField = () =>
  makeSanitizedTextField(
    ~label="Logo URL",
    ~name="logo",
    ~placeholder="Enter logo url",
    ~forbiddenCharsRegex=urlForbiddenCharsRegex,
  )

let makeBackgroundImageField = () => {
  makeFieldInfo(
    ~label="Background Image URL",
    ~name="background_image.url",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter background image url",
  )
}

let makeSellerNameField = () =>
  makeSanitizedTextField(
    ~label="Seller Name",
    ~name="seller_name",
    ~placeholder="Enter Seller Name",
    ~forbiddenCharsRegex=nameForbiddenCharsRegex,
  )

let makeSdkLayoutField = () => {
  let layoutOptions = ["accordion", "tabs", "spaced_accordion"]->SelectBox.makeOptions

  makeFieldInfo(
    ~label="SDK Layout",
    ~name="sdk_layout",
    ~customInput=InputFields.selectInput(
      ~options=layoutOptions,
      ~buttonText="Select Layout",
      ~deselectDisable=true,
      ~customButtonStyle="!w-full pr-4 pl-2 !rounded-md",
      ~fullLength=true,
    ),
  )
}

let makeDisplaySdkOnlyField = () => {
  makeFieldInfo(
    ~label="Display SDK Only",
    ~name="display_sdk_only",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeEnabledSavedPaymentMethodField = () => {
  makeFieldInfo(
    ~label="Enable Saved Payment Methods",
    ~name="enabled_saved_payment_method",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeHideCardNicknameField = () => {
  makeFieldInfo(
    ~label="Hide Card Nickname Field",
    ~name="hide_card_nickname_field",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeShowCardFormByDefaultField = () => {
  makeFieldInfo(
    ~label="Show Card Form by Default",
    ~name="show_card_form_by_default",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makePaymentButtonTextField = () =>
  makeSanitizedTextField(
    ~label="Payment Button Text",
    ~name="payment_button_text",
    ~placeholder="Enter Payment Button Text",
    ~forbiddenCharsRegex=nameForbiddenCharsRegex,
  )

let makeMerchantDescriptionField = () =>
  makeSanitizedTextField(
    ~label="Merchant Description",
    ~name="merchant_description",
    ~placeholder="Enter description of your business",
  )

let makeReturnUrlField = () => {
  makeFieldInfo(
    ~label="Return URL",
    ~name="return_url",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter return URL",
  )
}

let makeMaxItemsVisibleAfterCollapseField = () => {
  makeFieldInfo(
    ~label="Max Items Visible After Collapse",
    ~name="max_items_visible_after_collapse",
    ~customInput=InputFields.numericTextInput(),
    ~placeholder="Enter a number",
  )
}

let makeBrandingVisibilityField = () => {
  makeFieldInfo(
    ~label="Branding Visibility",
    ~name="branding_visibility",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeSkipStatusScreenField = () => {
  makeFieldInfo(
    ~label="Skip Status Screen",
    ~name="skip_status_screen",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makePaymentButtonColorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Payment Button Color",
    ~name="payment_button_colour",
    ~placeholder="",
    ~customInput=InputFields.colorPickerInput(~defaultValue, ~showErrorWhenEmpty=false),
  )
}

let makePaymentButtonTextColorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Payment Button Text Color",
    ~name="payment_button_text_colour",
    ~placeholder="",
    ~customInput=InputFields.colorPickerInput(~defaultValue, ~showErrorWhenEmpty=false),
  )
}

let makeIsSetupMandateFlowField = () => {
  makeFieldInfo(
    ~label="Is Setup Mandate Flow",
    ~name="is_setup_mandate_flow",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeBackgroundColorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Background Colour",
    ~name="background_colour",
    ~placeholder="",
    ~customInput=InputFields.colorPickerInput(~defaultValue, ~showErrorWhenEmpty=false),
  )
}

let makeDetailsLayoutField = () => {
  let layoutOptions = ["layout1", "layout2"]->SelectBox.makeOptions

  makeFieldInfo(
    ~label="Details Layout",
    ~name="details_layout",
    ~customInput=InputFields.selectInput(
      ~options=layoutOptions,
      ~buttonText="Select Details Layout",
      ~deselectDisable=true,
      ~customButtonStyle="!w-full pr-4 pl-2 !rounded-md",
      ~fullLength=true,
    ),
  )
}

let makeCustomMessageForCardTermsField = () =>
  makeSanitizedTextField(
    ~label="Custom Message for Card Terms",
    ~name="custom_message_for_card_terms",
    ~placeholder="Enter custom message for card terms",
  )

let makeShowCardTermsField = () => {
  makeFieldInfo(
    ~label="Show Card Terms",
    ~name="show_card_terms",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeColorIconCardCvcErrorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Color Icon Card CVC Error",
    ~name="color_icon_card_cvc_error",
    ~placeholder="",
    ~customInput=InputFields.colorPickerInput(~defaultValue, ~showErrorWhenEmpty=false),
  )
}

let makeCurrencyField = () =>
  makeFieldInfo(
    ~label="Currency",
    ~name="country_currency",
    ~placeholder="",
    ~customInput=InputFields.selectInput(
      ~options=SDKPaymentUtils.dropDownOptionsForCountryCurrency,
      ~buttonText="Select Currency",
      ~deselectDisable=true,
      ~fullLength=true,
      ~textStyle="!font-normal",
    ),
  )

let makeAmountField = () => {
  makeFieldInfo(
    ~label="Amount",
    ~name="amount",
    ~customInput=InputFields.numericTextInput(),
    ~placeholder="Enter amount",
  )
}

let makeSelectField = (~label, ~name, ~options, ~buttonText) =>
  makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.selectInput(
      ~options,
      ~buttonText,
      ~deselectDisable=true,
      ~customButtonStyle="!w-full pr-4 pl-2 !rounded-md",
      ~fullLength=true,
    ),
  )

let makeCaptureMethodField = () =>
  makeSelectField(
    ~label="Capture Method",
    ~name="capture_method",
    ~options=PaymentLinkThemeConfiguratorUtils.captureMethodOptions,
    ~buttonText="Select Capture Method",
  )

let makeSetupFutureUsageField = () =>
  makeSelectField(
    ~label="Setup Future Usage",
    ~name="setup_future_usage_applied",
    ~options=PaymentLinkThemeConfiguratorUtils.setupFutureUsageOptions,
    ~buttonText="Select Setup Future Usage",
  )

let makeAuthenticationTypeField = () =>
  makeSelectField(
    ~label="Authentication Type",
    ~name="authentication_type",
    ~options=PaymentLinkThemeConfiguratorUtils.authenticationTypeOptions,
    ~buttonText="Select Authentication Type",
  )

let makeRequestExternal3dsField = () => {
  makeFieldInfo(
    ~label="Request External 3DS Authentication",
    ~name="request_external_three_ds_authentication",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}
