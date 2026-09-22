@unboxed
type offerStatus =
  | @as("DRAFT") Draft
  | @as("ACTIVE") Active
  | @as("PAUSED") Paused
  | @as("EXPIRED") Expired
  | @as("DISCARDED") Discarded
  | UnknownStatus(string)

@unboxed
type calculationRule =
  | @as("PERCENTAGE") Percentage
  | @as("ABSOLUTE") Absolute
  | @as("FIXED_EFFECTIVE_AMOUNT") FixedEffectiveAmount
  | UnknownCalculationRule(string)

type offerDescription = {
  title: string,
  displayTitle: string,
  description: string,
  sponsoredBy: string,
}

type benefit = {
  calculationRule: calculationRule,
  value: float,
  maxAmount: option<float>,
}

type offer = {
  offerId: string,
  offerCode: string,
  status: offerStatus,
  offerDescription: offerDescription,
  startTime: string,
  endTime: string,
  benefit: option<benefit>,
  createdAt: string,
}

type offersSummary = {totalCount: int}

type offersListResponse = {
  summary: offersSummary,
  list: array<offer>,
}

type colType =
  | OfferId
  | OfferCode
  | Title
  | Status
  | Benefit
  | StartEndTime
  | CreatedAt
  | Actions

@unboxed
type language =
  | @as("en") English
  | @as("ar") Arabic
  | @as("fr") French
  | @as("pt") Portuguese
  | @as("ru") Russian
  | @as("uk") Ukrainian
  | UnknownLanguage(string)

type counterScope =
  | Campaign
  | PerCard

type counterValueType =
  | @as("OFFER_AMOUNT") AmountLimit
  | @as("COUNT") CountLimit

type currencyConstraint = {
  name: string,
  minOrderAmount: option<float>,
  maxOrderAmount: option<float>,
}

@unboxed
type binListMode =
  | @as("Whitelist") Whitelist
  | @as("Blacklist") Blacklist

type offerDetail = {
  offer: offer,
  language: language,
  currencies: array<currencyConstraint>,
  campaignAmount: option<float>,
  campaignCount: option<int>,
  amountPerCard: option<float>,
  countPerCard: option<int>,
  binListMode: option<binListMode>,
}

type offerDetailsColType =
  | Code
  | Id
  | OfferTitle
  | DisplayTitle
  | Description
  | Language
  | Logo
  | ValidFrom
  | ValidTill
  | OfferType
  | OfferAmount
  | MaxDiscountAmount
  | MinTxnAmount
  | MaxTxnAmount
  | CampaignAmount
  | CampaignCount

type paymentDetailsColType =
  | AmountPerCard
  | CountPerCard
  | BinList
  | BinListType
