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
}

type benefit = {
  calculationRule: calculationRule,
  value: float,
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
