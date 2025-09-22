open FormRenderer
let makeThemeField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Theme Color",
    ~name="theme",
    ~placeholder="",
    ~isRequired=true,
    ~customInput=InputFields.colorPickerInput(~defaultValue),
  )
}

let makeLogoField = () => {
  makeFieldInfo(
    ~label="Logo URL",
    ~name="logo",
    ~customInput=InputFields.textInput(),
    ~placeholder="https://example.com/logo.png",
    ~isRequired=true,
  )
}

let makeSellerNameField = () => {
  makeFieldInfo(
    ~label="Seller Name",
    ~name="seller_name",
    ~customInput=InputFields.textInput(),
    ~placeholder="Your Company Name",
    ~isRequired=true,
  )
}

let makeSdkLayoutField = () => {
  let layoutOptions = ["accordion", "tabs", "spaced_accordion"]->SelectBox.makeOptions

  makeFieldInfo(
    ~label="SDK Layout",
    ~name="sdk_layout",
    ~customInput=InputFields.selectInput(
      ~options=layoutOptions,
      ~buttonText="Select Layout",
      ~deselectDisable=true,
      ~customButtonStyle="!w-full pr-4 pl-2",
      ~fullLength=true,
    ),
    ~isRequired=true,
  )
}

let makeDisplaySdkOnlyField = () => {
  makeFieldInfo(
    ~label="Display SDK Only",
    ~name="display_sdk_only",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makeEnabledSavedPaymentMethodField = () => {
  makeFieldInfo(
    ~label="Enable Saved Payment Methods",
    ~name="enabled_saved_payment_method",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makeHideCardNicknameField = () => {
  makeFieldInfo(
    ~label="Hide Card Nickname Field",
    ~name="hide_card_nickname_field",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makeShowCardFormByDefaultField = () => {
  makeFieldInfo(
    ~label="Show Card Form by Default",
    ~name="show_card_form_by_default",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makePaymentButtonTextField = () => {
  makeFieldInfo(
    ~label="Payment Button Text",
    ~name="payment_button_text",
    ~customInput=InputFields.textInput(),
    ~placeholder="Proceed to Payment",
    ~isRequired=true,
  )
}

let makeMerchantDescriptionField = () => {
  makeFieldInfo(
    ~label="Merchant Description",
    ~name="merchant_description",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter a brief description of your business",
    ~isRequired=false,
  )
}

let makeReturnUrlField = () => {
  makeFieldInfo(
    ~label="Return URL",
    ~name="return_url",
    ~customInput=InputFields.textInput(),
    ~placeholder="https://google.com/",
    ~isRequired=true,
  )
}

let makeMaxItemsVisibleAfterCollapseField = () => {
  makeFieldInfo(
    ~label="Max Items Visible After Collapse",
    ~name="max_items_visible_after_collapse",
    ~customInput=InputFields.numericTextInput(),
    ~placeholder="3",
    ~isRequired=false,
  )
}

let makeBrandingVisibilityField = () => {
  makeFieldInfo(
    ~label="Branding Visibility",
    ~name="branding_visibility",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makeSkipStatusScreenField = () => {
  makeFieldInfo(
    ~label="Skip Status Screen",
    ~name="skip_status_screen",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makePaymentButtonColorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Payment Button Color",
    ~name="payment_button_colour",
    ~placeholder="",
    ~isRequired=false,
    ~customInput=InputFields.colorPickerInput(~defaultValue),
  )
}

let makeIsSetupMandateFlowField = () => {
  makeFieldInfo(
    ~label="Is Setup Mandate Flow",
    ~name="is_setup_mandate_flow",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makeBackgroundColorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Background Colour",
    ~name="background_colour",
    ~placeholder="",
    ~isRequired=false,
    ~customInput=InputFields.colorPickerInput(~defaultValue),
  )
}
