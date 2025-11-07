open FormRenderer
let makeThemeField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Theme Color",
    ~name="theme",
    ~placeholder="Select Theme Color",
    ~customInput=InputFields.colorPickerInput(~defaultValue, ~showErrorWhenEmpty=false),
  )
}

let makeLogoField = () => {
  makeFieldInfo(
    ~label="Logo URL",
    ~name="logo",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter logo url",
  )
}

let makeBackgroundImageField = () => {
  makeFieldInfo(
    ~label="Background Image URL",
    ~name="background_image",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter background image url",
  )
}

let makeSellerNameField = () => {
  makeFieldInfo(
    ~label="Seller Name",
    ~name="seller_name",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter Seller Name",
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

let makePaymentButtonTextField = () => {
  makeFieldInfo(
    ~label="Payment Button Text",
    ~name="payment_button_text",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter Payment Button Text",
  )
}

let makeMerchantDescriptionField = () => {
  makeFieldInfo(
    ~label="Merchant Description",
    ~name="merchant_description",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter description of your business",
  )
}

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

let makeCustomMessageForCardTermsField = () => {
  makeFieldInfo(
    ~label="Custom Message for Card Terms",
    ~name="custom_message_for_card_terms",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter custom message for card terms",
  )
}

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
