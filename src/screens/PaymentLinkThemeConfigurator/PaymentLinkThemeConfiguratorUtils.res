open LogicUtils
open PaymentLinkThemeConfiguratorTypes

let defaultStyleId = (Default: PaymentLinkThemeConfiguratorTypes.styleType :> string)
let defaultPaymentLinkTheme = "#006DF9"
let styleIdMaxLength = 32
let styleIdRegex = RegExp.fromString("^([a-zA-Z0-9_\\s-]+)$")

let showCardTermsOptions: array<SelectBox.dropdownOption> = [
  Always,
  Auto,
  Never,
]->Array.map(item => {
  let value = (item :> string)
  let option: SelectBox.dropdownOption = {label: value->capitalizeString, value}
  option
})

let sdkLayoutOptions: array<SelectBox.dropdownOption> = [
  {label: "Accordion", value: (Accordion :> string)},
  {label: "Tabs", value: (Tabs :> string)},
  {label: "Spaced Accordion", value: (SpacedAccordion :> string)},
]

let detailsLayoutOptions: array<SelectBox.dropdownOption> = [
  {label: "Layout 1", value: (Layout1 :> string)},
  {label: "Layout 2", value: (Layout2 :> string)},
]

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
  ->SelectBox.makeOptions

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
  allowedDomains->isEmptyArray ? None : Some(allowedDomains->getJsonFromArrayOfString)
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

let roundNumberString = value =>
  value
  ->Float.fromString
  ->Option.map(number => number->Math.round->Float.toInt->Int.toString)
  ->Option.getOr("")

let firstCssNumber: string => string = value => {
  let numberMatches = value->stripCssImportant->String.match(%re("/-?\d+(\.\d+)?/"))

  numberMatches->mapOptionOrDefault("", values =>
    values->getValueFromArray(0, "")->roundNumberString
  )
}

let cssPaddingSideFromShorthand: (string, cssPaddingSide) => string = (value, side) => {
  switch value->stripCssImportant->String.match(%re("/-?\d+(\.\d+)?/g")) {
  | Some(values) if values->isNonEmptyArray =>
    let index = switch (side, values->Array.length) {
    | (PaddingTop, _) => Some(0)
    | (PaddingRight, 1) => Some(0)
    | (PaddingRight, _) => Some(1)
    | (PaddingBottom, 1) => Some(0)
    | (PaddingBottom, 2) => Some(0)
    | (PaddingBottom, _) => Some(2)
    | (PaddingLeft, 1) => Some(0)
    | (PaddingLeft, 2) => Some(1)
    | (PaddingLeft, 3) => Some(1)
    | (PaddingLeft, _) => Some(3)
    }

    index->mapOptionOrDefault("", index => values->getValueFromArray(index, "")->roundNumberString)
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
    strippedValue
    ->String.match(%re("/^rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})/i"))
    ->mapOptionOrDefault("", matches =>
      switch (
        matches->getValueFromArray(1, "")->Int.fromString,
        matches->getValueFromArray(2, "")->Int.fromString,
        matches->getValueFromArray(3, "")->Int.fromString,
      ) {
      | (Some(red), Some(green), Some(blue)) =>
        `#${red->byteToHex}${green->byteToHex}${blue->byteToHex}`
      | _ => ""
      }
    )
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

let getCssFormValueFromJson = value =>
  switch value->getOptionIntFromJson {
  | Some(intValue) => intValue->Int.toString
  | None => value->getStringFromJson("")
  }

let getCssFormValue = (formValuesDict, fieldName) =>
  formValuesDict->getOptionValFromDict(fieldName)->mapOptionOrDefault("", getCssFormValueFromJson)

let cssPaddingSideFromProperty = property =>
  switch property {
  | "paddingTop" => Some(PaddingTop)
  | "paddingRight" => Some(PaddingRight)
  | "paddingBottom" => Some(PaddingBottom)
  | "paddingLeft" => Some(PaddingLeft)
  | _ => None
  }

let getStyleSpecificRulesFromProfile = (
  ~paymentLinkConfig: BusinessProfileInterfaceTypes.paymentLinkConfig,
  ~selectedStyleId,
) => {
  let businessSpecificConfigsDict =
    paymentLinkConfig.business_specific_configs->mapOptionOrDefault(Dict.make(), json =>
      json->getDictFromJsonObject
    )
  let styleConfig = businessSpecificConfigsDict->getJsonFromDict(selectedStyleId)
  let styleConfigDict = styleConfig->getDictFromJsonObject

  (
    styleConfigDict->getOptionValFromDict(sdkUiRulesKey),
    styleConfigDict->getOptionValFromDict(paymentLinkUiRulesKey),
  )
}

let flattenRulesForFields = (~formDict, ~rulesKey, ~rulesJson) => {
  rulesJson->mapOptionOrDefault((), rules => {
    let rulesDict = rules->getDictFromJsonObject
    cssFieldDefinitions
    ->Array.filter(field => cssRulesKeyEquals(field.rulesKey, rulesKey))
    ->Array.forEach(field => {
      rulesDict
      ->getOptionValFromDict(field.selector)
      ->mapOptionOrDefault(
        (),
        selectorProps => {
          let propsDict = selectorProps->getDictFromJsonObject
          let value = switch (propsDict->getString(field.cssProperty, ""), field.cssProperty) {
          | (value, _) if value->isNonEmptyString => value
          | (_, property) =>
            property
            ->cssPaddingSideFromProperty
            ->mapOptionOrDefault(
              "",
              side => propsDict->getString("padding", "")->cssPaddingSideFromShorthand(side),
            )
          }
          let formattedValue = formatCssValueForForm(field, value)
          formattedValue->isNonEmptyString
            ? Dict.set(formDict, field->cssFieldName, formattedValue->JSON.Encode.string)
            : ()
        },
      )
    })
  })
}

let flattenCssRulesIntoFormValues = (~formValues) => {
  let formDict = formValues->getDictFromJsonObject->Dict.copy
  let fieldSdkRules = formDict->getOptionValFromDict(sdkUiRulesKey)
  let fieldPlRules = formDict->getOptionValFromDict(paymentLinkUiRulesKey)

  flattenRulesForFields(~formDict, ~rulesKey=SdkUiRules, ~rulesJson=fieldSdkRules)
  flattenRulesForFields(~formDict, ~rulesKey=PaymentLinkUiRules, ~rulesJson=fieldPlRules)

  formDict->JSON.Encode.object
}

let buildCssRulesFromFormValues = (~baseRules: option<JSON.t>, ~rulesKey, formValuesDict) => {
  let rulesDict =
    baseRules->mapOptionOrDefault(Dict.make(), json => json->getDictFromJsonObject->Dict.copy)

  cssFieldDefinitions
  ->Array.filter(field => cssRulesKeyEquals(field.rulesKey, rulesKey))
  ->Array.forEach(field => {
    formValuesDict
    ->getOptionValFromDict(field->cssFieldName)
    ->mapOptionOrDefault((), formValue => {
      let value = formatCssValueForRules(field, formValue->getCssFormValueFromJson)
      let selectorProps =
        rulesDict
        ->getOptionValFromDict(field.selector)
        ->mapOptionOrDefault(Dict.make(), props => props->getDictFromJsonObject->Dict.copy)

      field.cssProperty
      ->cssPaddingSideFromProperty
      ->mapOptionOrDefault(
        (),
        _ => {
          selectorProps->Dict.delete("padding")
        },
      )

      if value->isNonEmptyString {
        Dict.set(selectorProps, field.cssProperty, value->JSON.Encode.string)
      } else {
        selectorProps->Dict.delete(field.cssProperty)
      }

      if selectorProps->Dict.keysToArray->isEmptyArray {
        rulesDict->Dict.delete(field.selector)
      } else {
        Dict.set(rulesDict, field.selector, selectorProps->JSON.Encode.object)
      }
    })
  })

  rulesDict->Dict.keysToArray->isEmptyArray ? None : Some(rulesDict->JSON.Encode.object)
}

let buildSdkUiRulesFromFormValues = (~baseRules, formValuesDict) =>
  buildCssRulesFromFormValues(~baseRules, ~rulesKey=SdkUiRules, formValuesDict)

let buildPaymentLinkUiRulesFromFormValues = (~baseRules, formValuesDict) =>
  buildCssRulesFromFormValues(~baseRules, ~rulesKey=PaymentLinkUiRules, formValuesDict)

let getThemeValueOrDefault = formValuesDict => {
  let themeValue = formValuesDict->getString("theme", "")
  themeValue->isNonEmptyString ? themeValue : defaultPaymentLinkTheme
}

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
  styleSdkRules->mapOptionOrDefault((), rules => jsonDict->Dict.set(sdkUiRulesKey, rules))
  stylePlRules->mapOptionOrDefault((), rules => jsonDict->Dict.set(paymentLinkUiRulesKey, rules))
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
    theme: formValuesDict->getThemeValueOrDefault,
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
