open LogicUtils
open PaymentLinkThemeConfiguratorTypes

let defaultStyleId = (Default: PaymentLinkThemeConfiguratorTypes.styleType :> string)
let styleIdMaxLength = 32
let styleIdRegex = RegExp.fromString("^([a-zA-Z0-9_\\s-]+)$")

let makeDropdownOption = (~label, ~value): SelectBox.dropdownOption => {label, value}

let makeDropdownOptions = values =>
  values->Array.map(value => makeDropdownOption(~label=value, ~value))

let showCardTermsOptions: array<SelectBox.dropdownOption> =
  [Always, Auto, Never]
  ->Array.map(item => (item :> string))
  ->makeDropdownOptions

let sdkLayoutOptions: array<SelectBox.dropdownOption> =
  [Accordion, Tabs, SpacedAccordion]
  ->Array.map(item => (item :> string))
  ->makeDropdownOptions

let detailsLayoutOptions: array<SelectBox.dropdownOption> =
  [Layout1, Layout2]
  ->Array.map(item => (item :> string))
  ->makeDropdownOptions

let cssFontWeightOptions: array<SelectBox.dropdownOption> =
  [
    FontWeight100,
    FontWeight200,
    FontWeight300,
    FontWeight400,
    FontWeight500,
    FontWeight600,
    FontWeight700,
    FontWeight800,
    FontWeight900,
  ]
  ->Array.map(item => (item :> string))
  ->makeDropdownOptions

let previewModeMeta = mode =>
  switch mode {
  | Mobile => {key: "mobile", label: "Mobile preview", icon: "mobile"}
  | Web => {key: "web", label: "Web preview", icon: "desktop"}
  }

let previewContentConfig = mode =>
  switch mode {
  | Mobile => {iframeScale: "0.75", iframeWidth: "133%", iframeHeight: "133%"}
  | Web => {iframeScale: "0.78", iframeWidth: "128.2%", iframeHeight: "128.2%"}
  }

let allowedDomainsToArray = allowedDomainsOpt => {
  let domainsStr =
    allowedDomainsOpt->Option.getOr(JSON.Encode.null)->JSON.Decode.string->Option.getOr("")
  let allowedDomains =
    domainsStr
    ->String.split(",")
    ->Array.map(String.trim)
    ->Array.filter(isNonEmptyString)
  allowedDomains->Array.length === 0 ? None : Some(allowedDomains->getJsonFromArrayOfString)
}

let cssRulesKeyToString = rulesKey =>
  switch rulesKey {
  | SdkUiRules => "sdk_ui_rules"
  | PaymentLinkUiRules => "payment_link_ui_rules"
  }

let cssRulesKeyEquals = (left, right) =>
  switch (left, right) {
  | (SdkUiRules, SdkUiRules) => true
  | (PaymentLinkUiRules, PaymentLinkUiRules) => true
  | _ => false
  }

let makeCssFieldName = (~rulesKey, ~selectorKey, ~property) =>
  `${rulesKey->cssRulesKeyToString}__${selectorKey}__${property}`

let cssFieldName = field =>
  makeCssFieldName(
    ~rulesKey=field.rulesKey,
    ~selectorKey=field.selectorKey,
    ~property=field.cssProperty,
  )

let sdkUiRulesKey = SdkUiRules->cssRulesKeyToString
let paymentLinkUiRulesKey = PaymentLinkUiRules->cssRulesKeyToString

let sdkInputSelector = ".Input, .Input:focus, .Input--invalid, .Input--empty"
let sdkInputLogoSelector = ".InputLogo"
let sdkLabelSelector = ".Label"
let plSubmitSelector = "#submit"
let plSubmitNotReadySelector = "#submit.not-ready"
let plPaymentFormWrapSelector = "#payment-form-wrap"
let plHyperCheckoutSdkSelector = ".hyper-checkout-sdk"

let cssField = (
  ~rulesKey,
  ~selectorKey,
  ~selector,
  ~cssProperty,
  ~label,
  ~inputType,
  ~placeholder="",
  ~important=true,
) => {
  rulesKey,
  selectorKey,
  selector,
  cssProperty,
  label,
  inputType,
  placeholder,
  important,
}

let inputCssFields = [
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Input",
    ~selector=sdkInputSelector,
    ~cssProperty="backgroundColor",
    ~label="Background Color",
    ~inputType=CssColor,
    ~important=true,
  ),
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Input",
    ~selector=sdkInputSelector,
    ~cssProperty="borderRadius",
    ~label="Border Radius",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 28",
  ),
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Input",
    ~selector=sdkInputSelector,
    ~cssProperty="color",
    ~label="Text Color",
    ~inputType=CssColor,
  ),
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Input",
    ~selector=sdkInputSelector,
    ~cssProperty="fontSize",
    ~label="Font Size",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 20",
  ),
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Input",
    ~selector=sdkInputSelector,
    ~cssProperty="height",
    ~label="Height",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 56",
  ),
]

let inputLogoCssFields = [
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="InputLogo",
    ~selector=sdkInputLogoSelector,
    ~cssProperty="color",
    ~label="Color",
    ~inputType=CssColor,
    ~important=true,
  ),
]

let labelCssFields = [
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Label",
    ~selector=sdkLabelSelector,
    ~cssProperty="color",
    ~label="Text Color",
    ~inputType=CssColor,
  ),
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Label",
    ~selector=sdkLabelSelector,
    ~cssProperty="fontSize",
    ~label="Font Size",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 16",
  ),
  cssField(
    ~rulesKey=SdkUiRules,
    ~selectorKey="Label",
    ~selector=sdkLabelSelector,
    ~cssProperty="fontWeight",
    ~label="Font Weight",
    ~inputType=CssFontWeight,
    ~placeholder="e.g. 400",
  ),
]

let submitCssFields = [
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="backgroundColor",
    ~label="Background Color",
    ~inputType=CssColor,
    ~important=true,
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="color",
    ~label="Text Color",
    ~inputType=CssColor,
    ~important=true,
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="borderRadius",
    ~label="Border Radius",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 50",
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="paddingLeft",
    ~label="Left Padding",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 14",
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="paddingRight",
    ~label="Right Padding",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 14",
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="paddingTop",
    ~label="Top Padding",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 14",
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="paddingBottom",
    ~label="Bottom Padding",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 14",
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submit",
    ~selector=plSubmitSelector,
    ~cssProperty="fontSize",
    ~label="Font Size",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 19",
  ),
]

let disabledSubmitCssFields = [
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submitNotReady",
    ~selector=plSubmitNotReadySelector,
    ~cssProperty="backgroundColor",
    ~label="Background Color",
    ~inputType=CssColor,
    ~important=true,
  ),
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="submitNotReady",
    ~selector=plSubmitNotReadySelector,
    ~cssProperty="color",
    ~label="Text Color",
    ~inputType=CssColor,
    ~important=true,
  ),
]

let paymentFormWrapCssFields = [
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="paymentFormWrap",
    ~selector=plPaymentFormWrapSelector,
    ~cssProperty="borderRadius",
    ~label="Border Radius",
    ~inputType=CssPxNumber,
    ~placeholder="e.g. 20",
  ),
]

let checkoutContainerCssFields = [
  cssField(
    ~rulesKey=PaymentLinkUiRules,
    ~selectorKey="hyperCheckoutSdk",
    ~selector=plHyperCheckoutSdkSelector,
    ~cssProperty="backgroundColor",
    ~label="Background Color",
    ~inputType=CssColor,
    ~important=true,
  ),
]

let cssAccordionDefinitions = [
  {title: "Input Fields", fields: inputCssFields},
  {title: "Input Logo", fields: inputLogoCssFields},
  {title: "Labels", fields: labelCssFields},
  {title: "Submit Button", fields: submitCssFields},
  {title: "Disabled Submit Button", fields: disabledSubmitCssFields},
  {title: "Payment Form Wrapper", fields: paymentFormWrapCssFields},
  {title: "Checkout Container", fields: checkoutContainerCssFields},
]

let cssFieldDefinitions =
  cssAccordionDefinitions->Array.reduce([], (fields, definition) =>
    fields->Array.concat(definition.fields)
  )

let stripCssImportant = value =>
  value->String.replaceRegExp(%re("/\s*!important\s*/gi"), "")->String.trim

let firstCssNumber: string => string = value =>
  switch value->stripCssImportant->String.match(%re("/-?\d+(\.\d+)?/")) {
  | Some(values) =>
    values
    ->Array.get(0)
    ->Option.flatMap(Float.fromString)
    ->Option.map(number => number->Math.round->Float.toInt->Int.toString)
    ->Option.getOr("")
  | None => ""
  }

let cssPaddingSideFromShorthand: (string, string) => string = (value, side) => {
  switch value->stripCssImportant->String.match(%re("/-?\d+(\.\d+)?/g")) {
  | Some(values) if values->Array.length > 0 =>
    let index = switch (side, values->Array.length) {
    | ("top", _) => Some(0)
    | ("right", 1) => Some(0)
    | ("right", _) => Some(1)
    | ("bottom", 1) => Some(0)
    | ("bottom", 2) => Some(0)
    | ("bottom", _) => Some(2)
    | ("left", 1) => Some(0)
    | ("left", 2) => Some(1)
    | ("left", 3) => Some(1)
    | ("left", _) => Some(3)
    | _ => None
    }

    switch index {
    | Some(index) =>
      values
      ->Array.get(index)
      ->Option.flatMap(Float.fromString)
      ->Option.map(number => number->Math.round->Float.toInt->Int.toString)
      ->Option.getOr("")
    | None => ""
    }
  | _ => ""
  }
}

let clampCssColorByte = value =>
  if value < 0 {
    0
  } else if value > 255 {
    255
  } else {
    value
  }

let hexDigit = digit =>
  switch digit {
  | 0 => "0"
  | 1 => "1"
  | 2 => "2"
  | 3 => "3"
  | 4 => "4"
  | 5 => "5"
  | 6 => "6"
  | 7 => "7"
  | 8 => "8"
  | 9 => "9"
  | 10 => "A"
  | 11 => "B"
  | 12 => "C"
  | 13 => "D"
  | 14 => "E"
  | 15 => "F"
  | _ => ""
  }

let byteToHex = value => {
  let clampedValue = value->clampCssColorByte
  `${(clampedValue / 16)->hexDigit}${Int.mod(clampedValue, 16)->hexDigit}`
}

let normalizeCssColorForPicker: string => string = value => {
  let strippedValue = value->stripCssImportant

  if RegExp.test(%re("/^#[0-9a-fA-F]{6}$/"), strippedValue) {
    strippedValue->String.toUpperCase
  } else {
    switch strippedValue->String.match(
      %re("/^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})/i"),
    ) {
    | Some(matches) =>
      switch (
        matches->Array.get(1)->Option.flatMap(value => value->Int.fromString),
        matches->Array.get(2)->Option.flatMap(value => value->Int.fromString),
        matches->Array.get(3)->Option.flatMap(value => value->Int.fromString),
      ) {
      | (Some(red), Some(green), Some(blue)) =>
        `#${red->byteToHex}${green->byteToHex}${blue->byteToHex}`
      | _ => ""
      }
    | None => ""
    }
  }
}

let formatCssValueForForm = (field, value) =>
  switch field.inputType {
  | CssColor => value->normalizeCssColorForPicker
  | CssPxNumber => value->firstCssNumber
  | CssFontWeight => value->firstCssNumber
  | CssText => field.important ? value->stripCssImportant : value
  }

let appendCssImportant = (~important, value) => {
  let trimmed = value->String.trim
  if trimmed->isEmptyString {
    ""
  } else if important {
    `${trimmed->stripCssImportant} !important`
  } else {
    trimmed
  }
}

let formatCssValueForRules = (field, value) => {
  let trimmed = value->String.trim
  let formattedValue = switch field.inputType {
  | CssColor | CssText | CssFontWeight => trimmed
  | CssPxNumber => trimmed->isEmptyString ? "" : `${trimmed}px`
  }
  appendCssImportant(~important=field.important, formattedValue)
}

let getCssFormValue = (formValuesDict, fieldName) => {
  switch formValuesDict->Dict.get(fieldName) {
  | Some(value) =>
    switch value->getOptionIntFromJson {
    | Some(intValue) => intValue->Int.toString
    | None => value->getStringFromJson("")
    }
  | None => ""
  }
}

let getStyleSpecificRulesFromProfile = (
  ~paymentLinkConfig: BusinessProfileInterfaceTypes.paymentLinkConfig,
  ~selectedStyleId,
) => {
  let businessSpecificConfigsDict =
    paymentLinkConfig.business_specific_configs->Option.mapOr(Dict.make(), json =>
      json->getDictFromJsonObject
    )
  let styleConfig = businessSpecificConfigsDict->getJsonFromDict(selectedStyleId)
  let styleConfigDict = styleConfig->getDictFromJsonObject

  (styleConfigDict->Dict.get(sdkUiRulesKey), styleConfigDict->Dict.get(paymentLinkUiRulesKey))
}

let flattenRulesForFields = (~formDict, ~rulesKey, ~rulesJson) => {
  switch rulesJson {
  | Some(rules) =>
    let rulesDict = rules->getDictFromJsonObject
    cssFieldDefinitions
    ->Array.filter(field => cssRulesKeyEquals(field.rulesKey, rulesKey))
    ->Array.forEach(field => {
      switch rulesDict->Dict.get(field.selector) {
      | Some(selectorProps) =>
        let propsDict = selectorProps->getDictFromJsonObject
        let value = switch (propsDict->getString(field.cssProperty, ""), field.cssProperty) {
        | (value, _) if value->isNonEmptyString => value
        | (_, "paddingTop") =>
          propsDict->getString("padding", "")->cssPaddingSideFromShorthand("top")
        | (_, "paddingRight") =>
          propsDict->getString("padding", "")->cssPaddingSideFromShorthand("right")
        | (_, "paddingBottom") =>
          propsDict->getString("padding", "")->cssPaddingSideFromShorthand("bottom")
        | (_, "paddingLeft") =>
          propsDict->getString("padding", "")->cssPaddingSideFromShorthand("left")
        | _ => ""
        }
        let formattedValue = formatCssValueForForm(field, value)
        formattedValue->isNonEmptyString
          ? Dict.set(formDict, field->cssFieldName, formattedValue->JSON.Encode.string)
          : ()
      | None => ()
      }
    })
  | None => ()
  }
}

let flattenCssRulesIntoFormValues = (~formValues) => {
  let formDict = formValues->getDictFromJsonObject->Dict.copy
  let fieldSdkRules = formDict->Dict.get(sdkUiRulesKey)
  let fieldPlRules = formDict->Dict.get(paymentLinkUiRulesKey)

  flattenRulesForFields(~formDict, ~rulesKey=SdkUiRules, ~rulesJson=fieldSdkRules)
  flattenRulesForFields(~formDict, ~rulesKey=PaymentLinkUiRules, ~rulesJson=fieldPlRules)

  formDict->JSON.Encode.object
}

let buildCssRulesFromFormValues = (~baseRules: option<JSON.t>, ~rulesKey, formValuesDict) => {
  let rulesDict = switch baseRules {
  | Some(json) => json->getDictFromJsonObject->Dict.copy
  | None => Dict.make()
  }

  cssFieldDefinitions
  ->Array.filter(field => cssRulesKeyEquals(field.rulesKey, rulesKey))
  ->Array.forEach(field => {
    let value = formatCssValueForRules(field, formValuesDict->getCssFormValue(field->cssFieldName))
    if value->isNonEmptyString {
      let selectorProps = switch rulesDict->Dict.get(field.selector) {
      | Some(props) => props->getDictFromJsonObject->Dict.copy
      | None => Dict.make()
      }
      Dict.set(selectorProps, field.cssProperty, value->JSON.Encode.string)
      Dict.set(rulesDict, field.selector, selectorProps->JSON.Encode.object)
    }
  })

  rulesDict->Dict.keysToArray->Array.length === 0 ? None : Some(rulesDict->JSON.Encode.object)
}

let buildSdkUiRulesFromFormValues = (~baseRules, formValuesDict) =>
  buildCssRulesFromFormValues(~baseRules, ~rulesKey=SdkUiRules, formValuesDict)

let buildPaymentLinkUiRulesFromFormValues = (~baseRules, formValuesDict) =>
  buildCssRulesFromFormValues(~baseRules, ~rulesKey=PaymentLinkUiRules, formValuesDict)

let constructBusinessProfileBody = (~paymentLinkConfig, ~styleID) => {
  open BusinessProfileInterfaceUtils

  let paymentLinkConfig = paymentLinkConfig->Option.getOr(paymentLinkConfigMapper(Dict.make()))
  let businessSpecificConfigs =
    paymentLinkConfig.business_specific_configs->Option.getOr(JSON.Encode.null)
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let updatedBusinessSpecificDict = Dict.copy(businessSpecificConfigsDict)
  updatedBusinessSpecificDict->Dict.set(styleID, Dict.make()->JSON.Encode.object)

  {
    ...paymentLinkConfig,
    allowed_domains: paymentLinkConfig.allowed_domains->allowedDomainsToArray,
    business_specific_configs: Some(updatedBusinessSpecificDict->JSON.Encode.object),
  }
}

let constructBusinessProfileBodyFromJson = (~json, ~paymentLinkConfig, ~styleID) => {
  open BusinessProfileInterfaceUtils

  let paymentLinkConfig = paymentLinkConfig->Option.getOr(paymentLinkConfigMapper(Dict.make()))
  let jsonDict = json->getDictFromJsonObject->Dict.copy
  let (styleSdkRules, stylePlRules) = getStyleSpecificRulesFromProfile(
    ~paymentLinkConfig,
    ~selectedStyleId=styleID,
  )
  let styleSdkRules = buildSdkUiRulesFromFormValues(~baseRules=styleSdkRules, jsonDict)
  let stylePlRules = buildPaymentLinkUiRulesFromFormValues(~baseRules=stylePlRules, jsonDict)

  jsonDict->Dict.delete(sdkUiRulesKey)
  jsonDict->Dict.delete(paymentLinkUiRulesKey)
  cssFieldDefinitions->Array.forEach(field => {
    jsonDict->Dict.delete(field->cssFieldName)
  })
  switch styleSdkRules {
  | Some(rules) => jsonDict->Dict.set(sdkUiRulesKey, rules)
  | None => ()
  }
  switch stylePlRules {
  | Some(rules) => jsonDict->Dict.set(paymentLinkUiRulesKey, rules)
  | None => ()
  }
  let updatedJson = jsonDict->JSON.Encode.object

  let businessSpecificConfigs =
    paymentLinkConfig.business_specific_configs->Option.getOr(JSON.Encode.null)
  let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
  let updatedBusinessSpecificDict = Dict.copy(businessSpecificConfigsDict)
  updatedBusinessSpecificDict->Dict.set(styleID, updatedJson)

  {
    ...paymentLinkConfig,
    allowed_domains: paymentLinkConfig.allowed_domains->allowedDomainsToArray,
    business_specific_configs: Some(updatedBusinessSpecificDict->JSON.Encode.object),
  }
}

let generateWasmPayload = (
  ~paymentDetails,
  ~publishableKey,
  ~formValues,
  ~styleSdkRules,
  ~stylePlRules,
) => {
  let defaultPaymentLinkTheme = "#ffffff"
  let paymentDetailsDict = paymentDetails->getDictFromJsonObject
  let formValuesDict = formValues->getDictFromJsonObject

  let backgroundImage = getString(formValuesDict, "background_image", "")
  let backgroundImageObj = backgroundImage->isNonEmptyString ? Some({url: backgroundImage}) : None

  let currency = getString(paymentDetailsDict, "currency", "USD")
  let amount = paymentDetailsDict->getInt("amount", 0)->Int.toFloat
  let formattedAmount =
    CurrencyUtils.convertCurrencyFromLowestDenomination(~amount, ~currency)->Float.toString

  let getNonEmptyValue = (dict, key, defaultValue) => {
    switch getOptionString(dict, key) {
    | Some(value) if value->isNonEmptyString => value
    | _ => defaultValue
    }
  }

  {
    pub_key: publishableKey,
    amount: formattedAmount,
    currency,
    client_secret: getString(paymentDetailsDict, "client_secret", ""),
    payment_id: getString(paymentDetailsDict, "payment_id", ""),
    status: getString(paymentDetailsDict, "status", "incomplete"),
    session_expiry: getString(paymentDetailsDict, "expires_on", ""),
    merchant_logo: getString(formValuesDict, "logo", ""),
    return_url: getString(formValuesDict, "return_url", "https://google.com"),
    merchant_name: getNonEmptyValue(formValuesDict, "seller_name", "Seller Name"),
    max_items_visible_after_collapse: formValuesDict->getInt("max_items_visible_after_collapse", 3),
    theme: getNonEmptyValue(formValuesDict, "theme", defaultPaymentLinkTheme),
    sdk_layout: getNonEmptyValue(formValuesDict, "sdk_layout", "accordion"),
    display_sdk_only: formValuesDict->getBool("display_sdk_only", false),
    hide_card_nickname_field: formValuesDict->getBool("hide_card_nickname_field", false),
    show_card_form_by_default: formValuesDict->getBool("show_card_form_by_default", true),
    enable_button_only_on_form_ready: formValuesDict->getBool(
      "enable_button_only_on_form_ready",
      true,
    ),
    payment_button_text: getOptionString(formValuesDict, "payment_button_text"),
    merchant_description: getOptionString(formValuesDict, "merchant_description"),
    locale: Some("en"),
    background_image: backgroundImageObj,
    details_layout: getOptionString(formValuesDict, "details_layout"),
    branding_visibility: getOptionBool(formValuesDict, "branding_visibility"),
    skip_status_screen: getOptionBool(formValuesDict, "skip_status_screen"),
    custom_message_for_card_terms: getOptionString(formValuesDict, "custom_message_for_card_terms"),
    payment_button_colour: getOptionString(formValuesDict, "payment_button_colour"),
    payment_button_text_colour: getOptionString(formValuesDict, "payment_button_text_colour"),
    background_colour: getOptionString(formValuesDict, "background_colour"),
    sdk_ui_rules: buildSdkUiRulesFromFormValues(~baseRules=styleSdkRules, formValuesDict),
    payment_link_ui_rules: buildPaymentLinkUiRulesFromFormValues(
      ~baseRules=stylePlRules,
      formValuesDict,
    ),
    payment_form_header_text: getOptionString(formValuesDict, "payment_form_header_text"),
    payment_form_label_type: getOptionString(formValuesDict, "payment_form_label_type"),
    show_card_terms: getOptionString(formValuesDict, "show_card_terms"),
    is_setup_mandate_flow: getOptionBool(formValuesDict, "is_setup_mandate_flow"),
    capture_method: getOptionString(paymentDetailsDict, "capture_method"),
    setup_future_usage_applied: getOptionString(paymentDetailsDict, "setup_future_usage"),
    color_icon_card_cvc_error: getOptionString(formValuesDict, "color_icon_card_cvc_error"),
  }
}

let validateStyleIdForm = (values: JSON.t) => {
  let errors = Dict.make()

  let styleId = values->getDictFromJsonObject->getString("payment_link_config_id", "")->String.trim

  let isDefault = styleId == defaultStyleId
  let errorMessage = if styleId->isEmptyString {
    "Payment Link Config ID name cannot be empty"
  } else if styleId->String.length > styleIdMaxLength {
    "Payment Link Config ID name cannot exceed 32 characters"
  } else if !RegExp.test(styleIdRegex, styleId) {
    "Payment Link Config ID name should not contain special characters"
  } else if isDefault {
    "Payment Link Config ID with this name already exists in this organization"
  } else {
    ""
  }

  if errorMessage->isNonEmptyString {
    Dict.set(errors, "payment_link_config_id", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}
