open FormRenderer
let makeThemeField = (~defaultValue) => {
  makeFieldInfo(
    ~label="Theme Color",
    ~name="theme",
    ~placeholder="",
    ~isRequired=false,
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
  let layoutOptions = ["accordion", "tabs", "spaced_accordn"]->SelectBox.makeOptions

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
