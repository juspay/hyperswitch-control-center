open LogicUtils
open OffersTypes

let statusFromString = status =>
  switch status {
  | "DRAFT" => Draft
  | "DETAILS_PENDING" => DetailsPending
  | "NEW" => New
  | "PARTNER_PROCESSING" => PartnerProcessing
  | "PENDING_FOR_APPROVAL" => PendingForApproval
  | "ACTIVE" => Active
  | "PAUSED" => Paused
  | "EXPIRED" => Expired
  | "DISCARDED" => Discarded
  | other => UnknownStatus(other)
  }

let statusToDisplayName = (status: offerStatus) => (status :> string)->snakeToTitle

let statusToLabelColor = (status): TableUtils.labelColor =>
  switch status {
  | Active => LabelGreen
  | Paused => LabelOrange
  | New
  | Draft
  | DetailsPending =>
    LabelBlue
  | PendingForApproval
  | PartnerProcessing =>
    LabelYellow
  | Expired => LabelGray
  | Discarded => LabelRed
  | UnknownStatus(_) => LabelLightGray
  }

let allStatuses = [
  Active,
  Paused,
  New,
  Draft,
  DetailsPending,
  PendingForApproval,
  PartnerProcessing,
  Expired,
  Discarded,
]

let benefitTypeFromString = benefitType =>
  switch benefitType {
  | "CB" => CB
  | "CASHBACK" => Cashback
  | "DISCOUNT" => Discount
  | "MERCHANT_DISCOUNT" => MerchantDiscount
  | "EMI_DISCOUNT" => EmiDiscount
  | "MERCHANT_EMI_DISCOUNT" => MerchantEmiDiscount
  | "EMI_CASHBACK" => EmiCashback
  | other => UnknownBenefitType(other)
  }

let benefitTypeToDisplayName = benefitType =>
  switch benefitType {
  | CB => "CB"
  | Cashback => "Cashback"
  | Discount => "Discount"
  | MerchantDiscount => "Payment Locking via Offer"
  | EmiDiscount => "EMI Discount"
  | MerchantEmiDiscount => "Merchant EMI Discount"
  | EmiCashback => "EMI Cashback"
  | UnknownBenefitType(other) => other->snakeToTitle
  }

let allBenefitTypes = [
  CB,
  Cashback,
  Discount,
  MerchantDiscount,
  EmiDiscount,
  MerchantEmiDiscount,
  EmiCashback,
]

let calculationRuleFromString = calculationRule =>
  switch calculationRule {
  | "PERCENTAGE" => Percentage
  | "ABSOLUTE" => Absolute
  | "FIXED_EFFECTIVE_AMOUNT" => FixedEffectiveAmount
  | other => UnknownCalculationRule(other)
  }

let paymentMethodTypeOptions = [
  "CARD",
  "NB",
  "UPI",
  "WALLET",
  "REWARD",
  "CONSUMER_FINANCE",
  "CASH",
  "MERCHANT_CONTAINER",
  "RTP",
  "OTC",
  "CBDC",
  "VIRTUAL_ACCOUNT",
]

let getOfferDescription = dict => {
  let descriptionDict = dict->getDictfromDict("offer_description")
  {
    title: descriptionDict->getString("title", ""),
    displayTitle: descriptionDict->getString("display_title", ""),
    description: descriptionDict->getString("description", ""),
    shortDescription: descriptionDict->getString("short_description", ""),
    sponsoredBy: descriptionDict->getString("sponsored_by", ""),
    offerLogoUrl: descriptionDict->getString("offer_logo_url", ""),
    tnc: descriptionDict->getJsonObjectFromDict("tnc"),
  }
}

let getUiConfigs = dict => {
  let uiConfigsDict = dict->getDictfromDict("ui_configs")
  {
    autoApply: uiConfigsDict->getStringFromDictAsBool("auto_apply", false),
    shouldValidate: uiConfigsDict->getStringFromDictAsBool("should_validate", false),
    isHidden: uiConfigsDict->getStringFromDictAsBool("is_hidden", false),
    isBanner: uiConfigsDict->getStringFromDictAsBool("is_banner", false),
    offerDisplayPriority: uiConfigsDict->getOptionInt("offer_display_priority"),
    offerLabel: uiConfigsDict->getString("offer_label", ""),
  }
}

let getBenefits = ruleDslDict =>
  ruleDslDict
  ->getArrayFromDict("benefits", [])
  ->getMappedValueFromArrayOfJson(benefitDict => {
    benefitType: benefitDict->getString("type", "")->benefitTypeFromString,
    calculationRule: benefitDict->getString("calculation_rule", "")->calculationRuleFromString,
    value: benefitDict->getFloat("value", 0.0),
    maxAmount: benefitDict->getOptionFloat("max_amount"),
    globalMaxAmount: benefitDict->getOptionFloat("global_max_amount"),
    roundoffRule: benefitDict
    ->getOptionObj("roundoff_rule")
    ->Option.map(ruleDict => {
      roundingFunction: ruleDict->getString("function", ""),
      decimalPlaces: ruleDict->getString("decimal_places", ""),
    }),
    costSharing: benefitDict
    ->getOptionObj("cost_sharing")
    ->Option.map(sharingDict => {
      merchantShare: sharingDict->getFloat("merchant_share", 0.0),
      bankShare: sharingDict->getFloat("bank_share", 0.0),
    }),
    amountInfo: benefitDict->getStrArrayFromDict("amount_info", []),
  })

let getPaymentInstruments = ruleDslDict =>
  ruleDslDict
  ->getArrayFromDict("payment_instrument", [])
  ->getMappedValueFromArrayOfJson(instrumentDict => {
    paymentMethodType: instrumentDict->getString("payment_method_type", ""),
    paymentMethod: instrumentDict->getStrArrayFromDict("payment_method", []),
    cardType: instrumentDict->getStrArrayFromDict("type", []),
    issuer: instrumentDict->getStrArrayFromDict("issuer", []),
    variant: instrumentDict->getStrArrayFromDict("variant", []),
    category: instrumentDict->getStrArrayFromDict("category", []),
    app: instrumentDict->getStrArrayFromDict("app", []),
    cardCountry: instrumentDict->getStrArrayFromDict("card_country", []),
    cardFlowType: instrumentDict->getString("card_flow_type", ""),
    eligibleForTokenization: instrumentDict->getOptionBool("eligible_for_tokenization"),
    isMandate: instrumentDict->getOptionBool("is_mandate"),
  })

let getCurrencyConstraints = orderDict => {
  let currencyJson = orderDict->getJsonObjectFromDict("currency")
  switch currencyJson->JSON.Classify.classify {
  | Array(currencies) =>
    currencies->getMappedValueFromArrayOfJson(currencyDict => {
      name: currencyDict->getString("name", ""),
      minOrderAmount: currencyDict->getString("min_order_amount", ""),
      maxOrderAmount: currencyDict->getString("max_order_amount", ""),
    })
  | String(currency) => [
      {
        name: currency,
        minOrderAmount: orderDict->getString("min_order_amount", ""),
        maxOrderAmount: orderDict->getString("max_order_amount", ""),
      },
    ]
  | _ => []
  }
}

let getOrderConstraint = ruleDslDict => {
  let orderDict = ruleDslDict->getDictfromDict("order")
  {
    currencies: orderDict->getCurrencyConstraints,
    minQuantity: orderDict->getOptionInt("min_quantity"),
    maxQuantity: orderDict->getOptionInt("max_quantity"),
    amountInfo: orderDict->getStrArrayFromDict("amount_info", []),
  }
}

let getCounters = ruleDslDict =>
  ruleDslDict
  ->getArrayFromDict("counters", [])
  ->getMappedValueFromArrayOfJson(counterDict => {
    counterType: counterDict->getStrArrayFromDict("type", []),
    value: counterDict->getString("value", ""),
    operator: counterDict->getString("operator", ""),
    resetFrequencyUnit: counterDict->getString("reset_frequency_unit", ""),
    resetPeriod: counterDict->getString("reset_period", ""),
    valueType: counterDict->getString("value_type", ""),
  })

let getFilterEntries = (filtersDict, key) =>
  filtersDict
  ->getArrayFromDict(key, [])
  ->getMappedValueFromArrayOfJson(entryDict => {
    filterType: entryDict->getString("type", ""),
    values: entryDict->getStrArrayFromDict("list", []),
    isValueUploaded: entryDict->getBool("is_value_uploaded", false),
  })

let getFilters = ruleDslDict => {
  let filtersDict = ruleDslDict->getDictfromDict("filters")
  {
    whitelist: filtersDict->getFilterEntries("whitelist"),
    blacklist: filtersDict->getFilterEntries("blacklist"),
  }
}

let getSchedule = ruleDslDict =>
  ruleDslDict
  ->getOptionObj("schedule")
  ->Option.map(scheduleDict => {
    recurrence: scheduleDict
    ->getOptionObj("recurrence")
    ->Option.map(recurrenceDict => {
      frequency: recurrenceDict->getString("frequency", ""),
      interval: recurrenceDict->getInt("interval", 1),
      byDay: recurrenceDict->getStrArrayFromDict("by_day", []),
      byDate: recurrenceDict->getStrArrayFromDict("by_date", []),
    }),
    dateWhitelist: scheduleDict->getStrArrayFromDict("date_whitelist", []),
    dateBlacklist: scheduleDict->getStrArrayFromDict("date_blacklist", []),
    durationUnit: scheduleDict->getString("duration_unit", ""),
    durationAmount: scheduleDict->getOptionInt("duration_amount"),
    timeRanges: scheduleDict
    ->getArrayFromDict("time_ranges", [])
    ->getMappedValueFromArrayOfJson(rangeDict => {
      gte: rangeDict->getString("gte", ""),
      lte: rangeDict->getString("lte", ""),
    }),
  })

let getRuleDsl = dict => {
  let ruleDslJson = dict->getJsonObjectFromDict("rule_dsl")
  let ruleDslDict = ruleDslJson->getDictFromJsonObject
  {
    benefits: ruleDslDict->getBenefits,
    paymentInstrument: ruleDslDict->getPaymentInstruments,
    order: ruleDslDict->getOrderConstraint,
    counters: ruleDslDict->getCounters,
    filters: ruleDslDict->getFilters,
    schedule: ruleDslDict->getSchedule,
    paymentChannel: ruleDslDict->getStrArrayFromDict("payment_channel", []),
    txnType: ruleDslDict->getStrArrayFromDict("txn_type", []),
    raw: ruleDslJson,
  }
}

let itemToObjMapper = dict => {
  offerId: dict->getString("offer_id", ""),
  offerCode: dict->getString("offer_code", ""),
  status: dict->getString("status", "")->statusFromString,
  offerDescription: dict->getOfferDescription,
  uiConfigs: dict->getUiConfigs,
  ruleDsl: dict->getRuleDsl,
  groupId: dict->getString("group_id", ""),
  priority: dict->getOptionInt("priority"),
  createdAt: dict->getString("created_at", ""),
  startTime: dict->getString("start_time", ""),
  endTime: dict->getString("end_time", ""),
  batchId: dict->getString("batch_id", ""),
  parentOfferId: dict->getString("parent_offer_id", ""),
  accountType: dict->getString("account_type", ""),
  source: dict->getString("source", ""),
  sourceOfferId: dict->getString("source_offer_id", ""),
  language: dict->getString("language", ""),
  hasMultiCodes: dict->getBool("has_multi_codes", false),
  eligibilityMode: dict->getString("eligibility_mode", ""),
  metadata: dict->getJsonObjectFromDict("metadata"),
}

let getCounterInfo = dict =>
  dict
  ->getArrayFromDict("counter_info", [])
  ->getMappedValueFromArrayOfJson(counterDict => {
    name: counterDict->getString("name", ""),
    description: counterDict->getString("description", ""),
    value: counterDict->getString("value", ""),
    limit: counterDict->getString("limit", ""),
    errorMessage: counterDict->getString("error_message", ""),
  })

let getTags = dict =>
  dict
  ->getArrayFromDict("tags", [])
  ->getMappedValueFromArrayOfJson(tagDict => {
    id: tagDict->getString("id", ""),
    name: tagDict->getString("name", ""),
  })

let udfKeys = ["udf1", "udf2", "udf3", "udf4", "udf5", "udf6", "udf7", "udf8", "udf9", "udf10"]

let getUdfs = dict =>
  udfKeys->Array.filterMap(key =>
    dict->getString(key, "")->getNonEmptyString->Option.map(value => (key, value))
  )

let detailItemToObjMapper = dict => {
  offer: dict->itemToObjMapper,
  merchantId: dict->getString("merchant_id", ""),
  updatedAt: dict->getString("updated_at", ""),
  applicationMode: dict->getString("application_mode", ""),
  counterInfo: dict->getCounterInfo,
  tags: dict->getTags,
  udfs: dict->getUdfs,
}

let listResponseMapper = json => {
  let dict = json->getDictFromJsonObject
  let summaryDict = dict->getDictfromDict("summary")
  {
    summary: {
      totalCount: summaryDict->getInt("total_count", 0),
      count: summaryDict->getInt("count", 0),
    },
    list: dict->getArrayFromDict("list", [])->getMappedValueFromArrayOfJson(itemToObjMapper),
  }
}

let defaultStartTime = "2021-12-31T18:30:00Z"
let defaultEndTime = "3000-12-31T18:29:59Z"
let defaultCreatedAtFrom = "2019-08-30T16:46:45.84Z"
let oneDayInMs = 86400000.0

let getDefaultCreatedAtTo = () => (Date.now() +. oneDayInMs)->Date.fromTime->Date.toISOString

let arrayFilterKeys = [
  "status",
  "offer_id",
  "offer_code",
  "group_id",
  "batch_id",
  "benefit_type",
  "payment_method_type",
  "currency",
  "source",
]

let buildListBody = (
  ~merchantId,
  ~limit,
  ~offset,
  ~sortField=CreatedAtSort,
  ~sortOrder=Descending,
  ~filterValueJson: Dict.t<JSON.t>=Dict.make(),
) => {
  let createdAt =
    [
      (
        "gte",
        filterValueJson->getString("created_at.gte", defaultCreatedAtFrom)->JSON.Encode.string,
      ),
      (
        "lte",
        filterValueJson->getString("created_at.lte", getDefaultCreatedAtTo())->JSON.Encode.string,
      ),
    ]->getJsonFromArrayOfJson

  let sortOffers =
    [
      ("order", (sortOrder :> string)->JSON.Encode.string),
      ("field", (sortField :> string)->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  let body =
    [
      ("merchant_id", merchantId->JSON.Encode.string),
      ("start_time", defaultStartTime->JSON.Encode.string),
      ("end_time", defaultEndTime->JSON.Encode.string),
      ("created_at", createdAt),
      ("sort_offers", sortOffers),
      ("limit", limit->JSON.Encode.int),
      ("offset", offset->JSON.Encode.int),
    ]->Dict.fromArray

  arrayFilterKeys->Array.forEach(key =>
    body->setOptionJson(
      key,
      filterValueJson
      ->getStrArrayFromDict(key, [])
      ->getNonEmptyArray
      ->Option.map(getJsonFromArrayOfString),
    )
  )
  body->setOptionString("title", filterValueJson->getString("title", "")->getNonEmptyString)
  body->setOptionString(
    "auto_apply",
    filterValueJson->getString("auto_apply", "")->getNonEmptyString,
  )

  body->JSON.Encode.object
}

let buildDetailBody = (~offerId, ~merchantId) =>
  [
    ("offer_ids", [offerId]->getJsonFromArrayOfString),
    ("merchant_id", merchantId->JSON.Encode.string),
  ]->getJsonFromArrayOfJson

let buildStatusUpdateBody = (~status: offerStatus) =>
  [("status", (status :> string)->JSON.Encode.string)]->getJsonFromArrayOfJson

let buildDeleteBody = (~merchantId) =>
  [("merchant_id", merchantId->JSON.Encode.string)]->getJsonFromArrayOfJson

let isFieldEnabled = (uiConfig: Dict.t<JSON.t>, path) =>
  path
  ->String.split(".")
  ->Array.reduce(Some(uiConfig->JSON.Encode.object), (acc, key) =>
    acc->Option.flatMap(json => json->getDictFromJsonObject->Dict.get(key))
  )
  ->Option.flatMap(JSON.Decode.bool)
  ->Option.getOr(true)

let emptyValuePlaceholder = "--"

let displayOrPlaceholder = value => value->isNonEmptyString ? value : emptyValuePlaceholder

let getYesOrNo = value => value ? "Yes" : "No"

let formatBenefitValue = (benefit: benefit) =>
  switch benefit.calculationRule {
  | Percentage => `${benefit.value->Float.toString}%`
  | _ => benefit.value->Float.toString
  }

let primaryBenefitLabel = (offer: offer) =>
  offer.ruleDsl.benefits
  ->Array.get(0)
  ->Option.mapOr("", benefit => benefit.benefitType->benefitTypeToDisplayName)

let primaryPaymentMethodLabel = (offer: offer) =>
  offer.ruleDsl.paymentInstrument
  ->Array.get(0)
  ->Option.mapOr("", instrument => instrument.paymentMethodType->snakeToTitle)

let minOrderAmountLabel = (offer: offer) =>
  switch offer.ruleDsl.order.currencies->Array.get(0) {
  | Some(currency) if currency.minOrderAmount->isNonEmptyString =>
    `${currency.name} ${currency.minOrderAmount}`
  | _ => ""
  }

let offerTitle = (offer: offer) =>
  offer.offerDescription.title->isNonEmptyString
    ? offer.offerDescription.title
    : offer.offerDescription.displayTitle

let isCouponBased = (offer: offer) => !offer.uiConfigs.autoApply

let canPauseOrActivate = (offer: offer) =>
  switch offer.status {
  | Active | Paused => true
  | _ => false
  }

let canDiscard = (offer: offer) =>
  switch offer.status {
  | Discarded | Expired => false
  | _ => true
  }

let nextStatusOnToggle = (offer: offer) =>
  switch offer.status {
  | Active => Paused
  | _ => Active
  }
