open LogicUtils
open OffersTypes

let statusFromString = status =>
  switch status {
  | "DRAFT" => Draft
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
  | Draft => LabelBlue
  | Expired => LabelGray
  | Discarded => LabelRed
  | UnknownStatus(_) => LabelLightGray
  }

let allStatuses = [Draft, Active, Paused, Expired, Discarded]

let calculationRuleFromString = calculationRule =>
  switch calculationRule {
  | "PERCENTAGE" => Percentage
  | "ABSOLUTE" => Absolute
  | "FIXED_EFFECTIVE_AMOUNT" => FixedEffectiveAmount
  | other => UnknownCalculationRule(other)
  }

let getOfferDescription = dict => {
  let descriptionDict = dict->getDictfromDict("offer_description")
  {
    title: descriptionDict->getString("title", ""),
    displayTitle: descriptionDict->getString("display_title", ""),
    description: descriptionDict->getString("description", ""),
    sponsoredBy: descriptionDict->getString("sponsored_by", "")->OffersSponsors.sponsorFromString,
  }
}

let getBenefit = dict =>
  dict
  ->getDictfromDict("rule_dsl")
  ->getArrayFromDict("benefits", [])
  ->Array.get(0)
  ->Option.map(benefitJson => {
    let benefitDict = benefitJson->getDictFromJsonObject
    {
      calculationRule: benefitDict->getString("calculation_rule", "")->calculationRuleFromString,
      value: benefitDict->getFloat("value", 0.0),
      maxAmount: benefitDict->getOptionFloat("max_amount"),
    }
  })

let itemToObjMapper = dict => {
  offerId: dict->getString("offer_id", ""),
  offerCode: dict->getString("offer_code", ""),
  status: dict->getString("status", "")->statusFromString,
  offerDescription: dict->getOfferDescription,
  startTime: dict->getString("start_time", ""),
  endTime: dict->getString("end_time", ""),
  benefit: dict->getBenefit,
  createdAt: dict->getString("created_at", ""),
}

let languageFromString = language =>
  switch language {
  | "en" => English
  | "ar" => Arabic
  | "fr" => French
  | "pt" => Portuguese
  | "ru" => Russian
  | "uk" => Ukrainian
  | other => UnknownLanguage(other)
  }

let languageToDisplayName = language =>
  switch language {
  | English => "English"
  | Arabic => "Arabic"
  | French => "French"
  | Portuguese => "Portuguese"
  | Russian => "Russian"
  | Ukrainian => "Ukrainian"
  | UnknownLanguage(other) => other->String.toUpperCase
  }

let counterDimensions = scope =>
  switch scope {
  | Campaign => ["OFFER_ID", "MERCHANT_ID"]
  | PerCard => ["OFFER_ID", "MERCHANT_ID", "CARD_IDENTIFIER"]
  }

let getCounter = (dict, ~scope, ~valueType: counterValueType) =>
  dict
  ->getDictfromDict("rule_dsl")
  ->getArrayFromDict("counters", [])
  ->Array.find(counterJson => {
    let counterDict = counterJson->getDictFromJsonObject
    counterDict->getStrArrayFromDict("type", []) == scope->counterDimensions &&
      counterDict->getString("value_type", "") == (valueType :> string)
  })
  ->Option.map(getDictFromJsonObject)

let getCounterAmount = (dict, ~scope) =>
  dict->getCounter(~scope, ~valueType=AmountLimit)->Option.flatMap(getOptionFloat(_, "value"))

let getCounterCount = (dict, ~scope) =>
  dict->getCounter(~scope, ~valueType=CountLimit)->Option.flatMap(getOptionInt(_, "value"))

let getCurrencies = dict =>
  dict
  ->getDictFromNestedDict("rule_dsl", "order")
  ->getArrayFromDict("currency", [])
  ->getMappedValueFromArrayOfJson(currencyDict => {
    name: currencyDict->getString("name", ""),
    minOrderAmount: currencyDict->getOptionFloat("min_order_amount"),
    maxOrderAmount: currencyDict->getOptionFloat("max_order_amount"),
  })

let getBinListMode = dict => {
  let filtersDict = dict->getDictfromDict("rule_dsl")->getDictfromDict("filters")
  let hasUploadedBins = key =>
    filtersDict
    ->getArrayFromDict(key, [])
    ->Array.some(entryJson => {
      let entryDict = entryJson->getDictFromJsonObject
      entryDict->getString("type", "") == "CARD_BIN" &&
        entryDict->getBool("is_value_uploaded", false)
    })

  if hasUploadedBins("whitelist") {
    Some(Whitelist)
  } else if hasUploadedBins("blacklist") {
    Some(Blacklist)
  } else {
    None
  }
}

let detailItemToObjMapper = dict => {
  offer: dict->itemToObjMapper,
  language: dict->getString("language", "")->languageFromString,
  currencies: dict->getCurrencies,
  campaignAmount: dict->getCounterAmount(~scope=Campaign),
  campaignCount: dict->getCounterCount(~scope=Campaign),
  amountPerCard: dict->getCounterAmount(~scope=PerCard),
  countPerCard: dict->getCounterCount(~scope=PerCard),
  binListMode: dict->getBinListMode,
}

let listResponseMapper = json => {
  let dict = json->getDictFromJsonObject
  let summaryDict = dict->getDictfromDict("summary")
  {
    summary: {
      totalCount: summaryDict->getInt("total_count", 0),
    },
    list: dict->getArrayFromDict("list", [])->getMappedValueFromArrayOfJson(itemToObjMapper),
  }
}

let buildListBody = (
  ~merchantId,
  ~limit,
  ~offset,
  ~offerCode="",
  ~filterValueJson: Dict.t<JSON.t>=Dict.make(),
) => {
  let sortOffers =
    [
      ("order", "DESCENDING"->JSON.Encode.string),
      ("field", "CREATED_AT"->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  let createdAt =
    [
      ("gte", "2019-08-30T16:46:45.84Z"->JSON.Encode.string),
      ("lte", (Date.now() +. 86400000.0)->Date.fromTime->Date.toISOString->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  let body =
    [
      ("merchant_id", merchantId->JSON.Encode.string),
      ("start_time", "2021-12-31T18:30:00Z"->JSON.Encode.string),
      ("end_time", "3000-12-31T18:29:59Z"->JSON.Encode.string),
      ("created_at", createdAt),
      ("sort_offers", sortOffers),
      ("limit", limit->JSON.Encode.int),
      ("offset", offset->JSON.Encode.int),
    ]->Dict.fromArray

  body->setOptionJson(
    "status",
    filterValueJson
    ->getStrArrayFromDict("status", [])
    ->getNonEmptyArray
    ->Option.map(getJsonFromArrayOfString),
  )
  body->setOptionJson(
    "offer_code",
    offerCode->getNonEmptyString->Option.map(code => [code]->getJsonFromArrayOfString),
  )

  body->JSON.Encode.object
}

let buildDetailBody = offerId =>
  [("offer_ids", [offerId]->getJsonFromArrayOfString)]->getJsonFromArrayOfJson

let buildStatusUpdateBody = (~status: offerStatus) =>
  [("status", (status :> string)->JSON.Encode.string)]->getJsonFromArrayOfJson

let buildDeleteBody = (~merchantId) =>
  [("merchant_id", merchantId->JSON.Encode.string)]->getJsonFromArrayOfJson

let emptyValuePlaceholder = "--"

let displayOrPlaceholder = value => value->isNonEmptyString ? value : emptyValuePlaceholder

let offerTitle = (offer: offer) =>
  offer.offerDescription.title->isNonEmptyString
    ? offer.offerDescription.title
    : offer.offerDescription.displayTitle

let formatBenefitValue = (benefit: benefit) =>
  switch benefit.calculationRule {
  | Percentage => `${benefit.value->Float.toString}% off`
  | _ => `${benefit.value->Float.toString} off`
  }

let benefitLabel = (offer: offer) =>
  offer.benefit->mapOptionOrDefault(emptyValuePlaceholder, formatBenefitValue)

let canPauseOrActivate = (offer: offer) =>
  switch offer.status {
  | Active | Paused => true
  | _ => false
  }

let canDelete = (offer: offer) =>
  switch offer.status {
  | Discarded => false
  | _ => true
  }

let nextStatusOnToggle = (offer: offer) =>
  switch offer.status {
  | Active => Paused
  | _ => Active
  }

let amountWithCurrency = (~amount: float, ~currency) =>
  `${amount->Float.toString} ${currency}`->String.trim

let primaryCurrency = (detail: offerDetail) =>
  detail.currencies->Array.get(0)->mapOptionOrDefault("", currency => currency.name)

let currencyRangeLabel = (detail: offerDetail, ~getAmount) =>
  detail.currencies
  ->Array.filterMap(currency =>
    currency->getAmount->Option.map(amount => amountWithCurrency(~amount, ~currency=currency.name))
  )
  ->Array.joinWith(", ")
  ->displayOrPlaceholder

let optionalAmountLabel = (detail: offerDetail, amount) =>
  amount->mapOptionOrDefault(emptyValuePlaceholder, amount =>
    amountWithCurrency(~amount, ~currency=detail->primaryCurrency)
  )

let optionalCountLabel = count => count->mapOptionOrDefault(emptyValuePlaceholder, Int.toString)

let offerAmountLabel = (detail: offerDetail) =>
  switch detail.offer.benefit {
  | Some({calculationRule: Percentage, value}) => `${value->Float.toString}%`
  | Some({value}) => detail->optionalAmountLabel(Some(value))
  | None => emptyValuePlaceholder
  }

let maxDiscountAmountLabel = (detail: offerDetail) =>
  detail->optionalAmountLabel(detail.offer.benefit->Option.flatMap(benefit => benefit.maxAmount))

let binListModeToDisplayName = (binListMode: OffersTypes.binListMode) => (binListMode :> string)
