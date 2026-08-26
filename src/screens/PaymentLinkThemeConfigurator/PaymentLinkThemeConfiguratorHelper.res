open FormRenderer
open PaymentLinkThemeConfiguratorUtils

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
  makeFieldInfo(~label, ~name, ~placeholder, ~customInput=(~input, ~placeholder as _) =>
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

let makeColorField = (~label, ~name, ~defaultValue=?, ~placeholder="") => {
  makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.colorPickerInput(~defaultValue?, ~showErrorWhenEmpty=false),
  )
}

let makeThemeField = (~defaultValue) =>
  makeColorField(
    ~label="Theme Color",
    ~name="theme",
    ~placeholder="Select Theme Color",
    ~defaultValue,
  )

let makeLogoField = () =>
  makeSanitizedTextField(
    ~label="Logo URL",
    ~name="logo",
    ~placeholder="Enter logo url",
    ~forbiddenCharsRegex=urlForbiddenCharsRegex,
  )

let makeSellerNameField = () =>
  makeSanitizedTextField(
    ~label="Seller Name",
    ~name="seller_name",
    ~placeholder="Enter Seller Name",
    ~forbiddenCharsRegex=nameForbiddenCharsRegex,
  )

let makeSelectField = (~label, ~name, ~options, ~buttonText) =>
  makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.selectInput(
      ~options,
      ~buttonText,
      ~deselectDisable=true,
      ~customButtonStyle="!w-full pr-4 pl-2 !rounded-md",
      ~dropdownCustomWidth="!w-full",
      ~fullLength=true,
    ),
  )

let makeSdkLayoutField = () =>
  makeSelectField(
    ~label="SDK Layout",
    ~name="sdk_layout",
    ~options=sdkLayoutOptions,
    ~buttonText="Select Layout",
  )

let makeDisplaySdkOnlyField = () => {
  makeFieldInfo(
    ~label="Display SDK Only",
    ~name="display_sdk_only",
    ~customInput=InputFields.switchInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makeHideCardNicknameField = () => {
  makeFieldInfo(
    ~label="Hide Card Nickname Field",
    ~name="hide_card_nickname_field",
    ~customInput=InputFields.switchInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
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

let makeBrandingVisibilityField = () => {
  makeFieldInfo(
    ~label="Branding Visibility",
    ~name="branding_visibility",
    ~customInput=InputFields.switchInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let makePaymentButtonColorField = (~defaultValue) =>
  makeColorField(~label="Payment Button Color", ~name="payment_button_colour", ~defaultValue)

let makePaymentButtonTextColorField = (~defaultValue) =>
  makeColorField(
    ~label="Payment Button Text Color",
    ~name="payment_button_text_colour",
    ~defaultValue,
  )

let makeBackgroundColorField = (~defaultValue) =>
  makeColorField(~label="Background Colour", ~name="background_colour", ~defaultValue)

let makeDetailsLayoutField = () =>
  makeSelectField(
    ~label="Details Layout",
    ~name="details_layout",
    ~options=detailsLayoutOptions,
    ~buttonText="Select Details Layout",
  )

let makeCustomMessageForCardTermsField = () =>
  makeSanitizedTextField(
    ~label="Custom Message for Card Terms",
    ~name="custom_message_for_card_terms",
    ~placeholder="Enter custom message for card terms",
  )

let makeColorIconCardCvcErrorField = (~defaultValue) =>
  makeColorField(
    ~label="Color Icon Card CVC Error",
    ~name="color_icon_card_cvc_error",
    ~defaultValue,
  )

let makeShowCardTermsField = () =>
  makeSelectField(
    ~label="Show Card Terms",
    ~name="show_card_terms",
    ~options=showCardTermsOptions,
    ~buttonText="Select Show Card Terms",
  )

let makeCssColorField = (~label, ~name) => makeColorField(~label, ~name)

let makeCssDimensionField = (~label, ~name, ~placeholder) =>
  makeSanitizedTextField(
    ~label,
    ~name,
    ~placeholder,
    ~forbiddenCharsRegex=defaultForbiddenCharsRegex,
  )

let makeCssPxNumberField = (~label, ~name, ~placeholder) =>
  makeFieldInfo(
    ~label=`${label} (px)`,
    ~name,
    ~placeholder,
    ~customInput=InputFields.numericTextInput(
      ~precision=0,
      ~removeLeadingZeroes=true,
      ~maxLength=4,
    ),
  )

let makeCssFontWeightField = (~label, ~name) =>
  makeSelectField(~label, ~name, ~options=cssFontWeightOptions, ~buttonText="Select Font Weight")
