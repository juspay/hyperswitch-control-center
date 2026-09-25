open LogicUtils
open OffersTypes
open OffersUtils

let allLanguages = [English, Arabic, French, Portuguese, Russian, Ukrainian]

let languageOptions = allLanguages->Array.map((language): SelectBox.dropdownOption => {
  label: language->languageToDisplayName,
  value: (language :> string),
})

let calculationRuleOptions: array<SelectBox.dropdownOption> = [
  {label: "Percentage", value: (Percentage :> string)},
  {label: "Absolute", value: (Absolute :> string)},
]

let currencyOptions = CurrencyUtils.currencyList->Array.map((
  currency
): SelectBox.dropdownOption => {
  let code = currency->CurrencyUtils.getCurrencyCodeStringFromVariant
  {label: code, value: code}
})

let offerFormValuesMapper = (dict): offerFormValues => {
  offerCode: dict->getString("offer_code", ""),
  title: dict->getString("title", ""),
  displayTitle: dict->getString("display_title", ""),
  description: dict->getString("description", ""),
  sponsoredBy: dict->getString("sponsored_by", "")->OffersSponsors.sponsorFromString,
  language: dict->getString("language", "")->languageFromString,
  startTime: dict->getString("start_time", ""),
  endTime: dict->getString("end_time", ""),
  calculationRule: dict->getString("calculation_rule", "")->calculationRuleFromString,
  benefitValue: dict->getFloat("benefit_value", 0.0),
  maxAmount: dict->getOptionFloat("max_amount"),
  currency: dict->getString("currency", ""),
  minOrderAmount: dict->getFloat("min_order_amount", 0.0),
  maxOrderAmount: dict->getOptionFloat("max_order_amount"),
  campaignAmount: dict->getOptionFloat("campaign_amount"),
  campaignCount: dict->getOptionInt("campaign_count"),
  amountPerCard: dict->getOptionFloat("amount_per_card"),
  countPerCard: dict->getOptionInt("count_per_card"),
  cardBins: dict->getStrArrayFromDict("card_bins", []),
}

let maxBinRows = 10000
let binPattern = %re("/^\d{6,9}$/")

let parseBinCsv = content => {
  let bins =
    content
    ->String.split("\n")
    ->Array.map(String.trim)
    ->Array.filter(isNonEmptyString)
  let bins = switch bins->Array.get(0) {
  | Some(header) if header->String.toUpperCase == "CARD_BIN" => bins->Array.sliceToEnd(~start=1)
  | _ => bins
  }

  if bins->isEmptyArray {
    Error("The file has no BINs")
  } else if bins->Array.length > maxBinRows {
    Error(`Upload at most ${maxBinRows->Int.toString} BINs`)
  } else if bins->Array.some(bin => !(binPattern->RegExp.test(bin))) {
    Error("Upload 6 to 9 digit BINs only, one per row")
  } else if bins->removeDuplicate->Array.length !== bins->Array.length {
    Error("The file has duplicate BINs")
  } else {
    Ok(bins)
  }
}

let requiredFieldError = "This field is required"
let positiveValueError = "Enter a value greater than 0"

let firstError = errors => errors->Array.filterMap(error => error)->Array.get(0)

let requiredString = getValue => formValues =>
  getValue(formValues)->isEmptyString ? Some(requiredFieldError) : None

let positiveAmount = getAmount => formValues =>
  getAmount(formValues) <= 0.0 ? Some(positiveValueError) : None

let optionalPositiveAmount = getAmount => formValues =>
  getAmount(formValues)->Option.flatMap(amount => amount <= 0.0 ? Some(positiveValueError) : None)

let optionalPositiveCount = getCount => formValues =>
  getCount(formValues)->Option.flatMap(count => count < 1 ? Some(positiveValueError) : None)

let sponsorRule = (formValues: offerFormValues) =>
  switch formValues.sponsoredBy {
  | UnknownSponsor(_) => Some(requiredFieldError)
  | _ => None
  }

let languageRule = (formValues: offerFormValues) =>
  switch formValues.language {
  | UnknownLanguage(_) => Some(requiredFieldError)
  | _ => None
  }

let discountTypeRule = (formValues: offerFormValues) =>
  switch formValues.calculationRule {
  | UnknownCalculationRule(_) => Some(requiredFieldError)
  | _ => None
  }

let benefitValueRule = (formValues: offerFormValues) =>
  firstError([
    positiveAmount(values => values.benefitValue)(formValues),
    switch formValues.calculationRule {
    | Percentage if formValues.benefitValue > 100.0 => Some("Percentage cannot exceed 100")
    | _ => None
    },
  ])

let endTimeRule = (formValues: offerFormValues) =>
  firstError([
    requiredString(values => values.endTime)(formValues),
    formValues.startTime->isNonEmptyString && formValues.endTime <= formValues.startTime
      ? Some("End time must be after the start time")
      : None,
  ])

let maxOrderAmountRule = (formValues: offerFormValues) =>
  firstError([
    optionalPositiveAmount(values => values.maxOrderAmount)(formValues),
    switch formValues.maxOrderAmount {
    | Some(maxAmount) if maxAmount < formValues.minOrderAmount =>
      Some("Maximum amount must be greater than the minimum amount")
    | _ => None
    },
  ])

let offerDetailsRules: array<offerFormRule> = [
  ("offer_code", requiredString(values => values.offerCode)),
  ("title", requiredString(values => values.title)),
  ("sponsored_by", sponsorRule),
  ("language", languageRule),
  ("start_time", requiredString(values => values.startTime)),
  ("end_time", endTimeRule),
  ("calculation_rule", discountTypeRule),
  ("benefit_value", benefitValueRule),
  ("max_amount", optionalPositiveAmount(values => values.maxAmount)),
  ("campaign_amount", optionalPositiveAmount(values => values.campaignAmount)),
  ("campaign_count", optionalPositiveCount(values => values.campaignCount)),
]

let transactionDetailsRules: array<offerFormRule> = [
  ("currency", requiredString(values => values.currency)),
  ("min_order_amount", positiveAmount(values => values.minOrderAmount)),
  ("max_order_amount", maxOrderAmountRule),
]

let paymentDetailsRules: array<offerFormRule> = [
  ("amount_per_card", optionalPositiveAmount(values => values.amountPerCard)),
  ("count_per_card", optionalPositiveCount(values => values.countPerCard)),
]

let validateOfferForm = values => {
  let formValues = values->getDictFromJsonObject->offerFormValuesMapper

  [offerDetailsRules, transactionDetailsRules, paymentDetailsRules]
  ->Array.flat
  ->Array.filterMap(((fieldName, rule)) =>
    rule(formValues)->Option.map(error => (fieldName, error->JSON.Encode.string))
  )
  ->getJsonFromArrayOfJson
}

let buildCounter = (~scope, ~valueType: counterValueType, ~value: JSON.t, ~resetPeriod) =>
  [
    ("type", scope->counterDimensions->getJsonFromArrayOfString),
    ("value_type", (valueType :> string)->JSON.Encode.string),
    ("operator", "MAX"->JSON.Encode.string),
    ("value", value),
    ("reset_period", resetPeriod->JSON.Encode.int),
    ("reset_frequency_unit", "SECOND"->JSON.Encode.string),
  ]->getJsonFromArrayOfJson

let buildAmountCounter = (~scope, ~resetPeriod, amount) =>
  buildCounter(~scope, ~valueType=AmountLimit, ~value=amount->JSON.Encode.float, ~resetPeriod)

let buildCountCounter = (~scope, ~resetPeriod, count) =>
  buildCounter(~scope, ~valueType=CountLimit, ~value=count->JSON.Encode.int, ~resetPeriod)

let offerDurationInSeconds = (~startTime, ~endTime) =>
  ((endTime->Date.fromString->Date.getTime -. startTime->Date.fromString->Date.getTime) /. 1000.0)
    ->Float.toInt

let cardInstrument = [("payment_method_type", "CARD"->JSON.Encode.string)]->getJsonFromArrayOfJson

let cardBinFilters = bins =>
  [
    (
      "whitelist",
      [
        [
          ("type", "CARD_BIN"->JSON.Encode.string),
          ("list", bins->getJsonFromArrayOfString),
          ("is_value_uploaded", true->JSON.Encode.bool),
        ]->getJsonFromArrayOfJson,
      ]->JSON.Encode.array,
    ),
  ]->getJsonFromArrayOfJson

let buildCreateBody = (~merchantId, formValues: offerFormValues) => {
  let resetPeriod = offerDurationInSeconds(
    ~startTime=formValues.startTime,
    ~endTime=formValues.endTime,
  )
  let hasCardConfig =
    formValues.amountPerCard->Option.isSome ||
    formValues.countPerCard->Option.isSome ||
    formValues.cardBins->isNonEmptyArray

  let counters =
    [
      formValues.campaignAmount->Option.map(buildAmountCounter(~scope=Campaign, ~resetPeriod, _)),
      formValues.campaignCount->Option.map(buildCountCounter(~scope=Campaign, ~resetPeriod, _)),
      formValues.amountPerCard->Option.map(buildAmountCounter(~scope=PerCard, ~resetPeriod, _)),
      formValues.countPerCard->Option.map(buildCountCounter(~scope=PerCard, ~resetPeriod, _)),
    ]->Array.filterMap(counter => counter)

  let currency =
    [
      ("name", formValues.currency->JSON.Encode.string),
      ("min_order_amount", formValues.minOrderAmount->JSON.Encode.float),
    ]->Dict.fromArray
  currency->setOptionFloat("max_order_amount", formValues.maxOrderAmount)

  let benefit =
    [
      ("type", "DISCOUNT"->JSON.Encode.string),
      ("calculation_rule", (formValues.calculationRule :> string)->JSON.Encode.string),
      ("value", formValues.benefitValue->JSON.Encode.float),
    ]->Dict.fromArray
  benefit->setOptionFloat(
    "max_amount",
    switch formValues.calculationRule {
    | Percentage => formValues.maxAmount
    | _ => None
    },
  )

  let ruleDsl =
    [
      (
        "order",
        [("currency", [currency->JSON.Encode.object]->JSON.Encode.array)]->getJsonFromArrayOfJson,
      ),
      ("benefits", [benefit->JSON.Encode.object]->JSON.Encode.array),
    ]->Dict.fromArray
  ruleDsl->setOptionArray("counters", counters->getNonEmptyArray)
  ruleDsl->setOptionArray("payment_instrument", hasCardConfig ? Some([cardInstrument]) : None)
  ruleDsl->setOptionJson(
    "filters",
    formValues.cardBins->getNonEmptyArray->Option.map(cardBinFilters),
  )

  let description =
    [
      ("title", formValues.title->JSON.Encode.string),
      ("sponsored_by", (formValues.sponsoredBy :> string)->JSON.Encode.string),
    ]->Dict.fromArray
  description->setOptionString("display_title", formValues.displayTitle->getNonEmptyString)
  description->setOptionString("description", formValues.description->getNonEmptyString)

  [
    ("merchant_id", merchantId->JSON.Encode.string),
    ("offer_code", formValues.offerCode->JSON.Encode.string),
    ("offer_description", description->JSON.Encode.object),
    ("language", (formValues.language :> string)->JSON.Encode.string),
    (
      "ui_configs",
      [
        ("auto_apply", "false"->JSON.Encode.string),
        ("should_validate", "true"->JSON.Encode.string),
        ("is_hidden", "false"->JSON.Encode.string),
      ]->getJsonFromArrayOfJson,
    ),
    ("start_time", formValues.startTime->JSON.Encode.string),
    ("end_time", formValues.endTime->JSON.Encode.string),
    ("application_mode", "ORDER"->JSON.Encode.string),
    ("rule_dsl", ruleDsl->JSON.Encode.object),
  ]->getJsonFromArrayOfJson
}
