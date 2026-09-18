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

let defaultStartTime = "2021-12-31T18:30:00Z"
let defaultEndTime = "3000-12-31T18:29:59Z"
let defaultCreatedAtFrom = "2019-08-30T16:46:45.84Z"
let oneDayInMs = 86400000.0

let getDefaultCreatedAtTo = () => (Date.now() +. oneDayInMs)->Date.fromTime->Date.toISOString

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
      ("gte", defaultCreatedAtFrom->JSON.Encode.string),
      ("lte", getDefaultCreatedAtTo()->JSON.Encode.string),
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
  offer.benefit->Option.mapOr(emptyValuePlaceholder, formatBenefitValue)

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
