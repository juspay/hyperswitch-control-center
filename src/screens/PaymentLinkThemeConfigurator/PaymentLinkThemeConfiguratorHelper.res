open FormRenderer
let makeThemeField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Theme Color",
    ~name="theme",
    ~placeholder="Select Theme Color",
    ~isRequired=false,
    ~customInput=InputFields.colorPickerInput(~defaultValue),
  )
}

let makeLogoField = () => {
  makeFieldInfo(
    ~label="Logo URL",
    ~name="logo",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter logo url",
    ~isRequired=false,
  )
}

let makeBackgroundImageField = () => {
  makeFieldInfo(
    ~label="Background Image URL",
    ~name="background_image",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter background image url",
    ~isRequired=false,
  )
}

let makeSellerNameField = () => {
  makeFieldInfo(
    ~label="Seller Name",
    ~name="seller_name",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter Seller Name",
    ~isRequired=false,
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
    ~isRequired=false,
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
    ~placeholder="Enter Payment Button Text",
    ~isRequired=false,
  )
}

let makeMerchantDescriptionField = () => {
  makeFieldInfo(
    ~label="Merchant Description",
    ~name="merchant_description",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter description of your business",
    ~isRequired=false,
  )
}

let makeReturnUrlField = () => {
  makeFieldInfo(
    ~label="Return URL",
    ~name="return_url",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter return URL",
    ~isRequired=false,
  )
}

let makeMaxItemsVisibleAfterCollapseField = () => {
  makeFieldInfo(
    ~label="Max Items Visible After Collapse",
    ~name="max_items_visible_after_collapse",
    ~customInput=InputFields.numericTextInput(),
    ~placeholder="Enter a number",
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

let makePaymentButtonTextColorField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Payment Button Text Color",
    ~name="payment_button_text_colour",
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
    ~isRequired=false,
  )
}

let makeCustomMessageForCardTermsField = () => {
  makeFieldInfo(
    ~label="Custom Message for Card Terms",
    ~name="custom_message_for_card_terms",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter custom message for card terms",
    ~isRequired=false,
  )
}

let makeShowCardTermsField = () => {
  makeFieldInfo(
    ~label="Show Card Terms",
    ~name="show_card_terms",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
    ~isRequired=false,
  )
}

let makeColorIconCardCvcErrorField = () => {
  makeFieldInfo(
    ~label="Color Icon Card CVC Error",
    ~name="color_icon_card_cvc_error",
    ~customInput=InputFields.textInput(),
    ~placeholder="Enter color for card CVC error",
    ~isRequired=false,
  )
}
