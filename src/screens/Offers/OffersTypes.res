@unboxed
type offerStatus =
  | @as("DRAFT") Draft
  | @as("DETAILS_PENDING") DetailsPending
  | @as("NEW") New
  | @as("PARTNER_PROCESSING") PartnerProcessing
  | @as("PENDING_FOR_APPROVAL") PendingForApproval
  | @as("ACTIVE") Active
  | @as("PAUSED") Paused
  | @as("EXPIRED") Expired
  | @as("DISCARDED") Discarded
  | UnknownStatus(string)

@unboxed
type benefitType =
  | @as("CB") CB
  | @as("CASHBACK") Cashback
  | @as("DISCOUNT") Discount
  | @as("MERCHANT_DISCOUNT") MerchantDiscount
  | @as("EMI_DISCOUNT") EmiDiscount
  | @as("MERCHANT_EMI_DISCOUNT") MerchantEmiDiscount
  | @as("EMI_CASHBACK") EmiCashback
  | UnknownBenefitType(string)

@unboxed
type calculationRule =
  | @as("PERCENTAGE") Percentage
  | @as("ABSOLUTE") Absolute
  | @as("FIXED_EFFECTIVE_AMOUNT") FixedEffectiveAmount
  | UnknownCalculationRule(string)

type colType =
  | OfferId
  | OfferCode
  | Title
  | Status
  | Benefit
  | PaymentMethodType
  | CouponBased
  | StartEndTime
  | CreatedAt
  | Priority
  | GroupId
  | BatchId
  | MinOrderAmount
  | Source
  | SourceOfferId
  | ParentOfferId
  | EligibilityMode
  | Language
  | Actions

type offerDescription = {
  title: string,
  displayTitle: string,
  description: string,
  shortDescription: string,
  sponsoredBy: string,
  offerLogoUrl: string,
  tnc: JSON.t,
}

type uiConfigs = {
  autoApply: bool,
  shouldValidate: bool,
  isHidden: bool,
  isBanner: bool,
  offerDisplayPriority: option<int>,
  offerLabel: string,
}

type roundOffRule = {
  roundingFunction: string,
  decimalPlaces: string,
}

type costSharing = {
  merchantShare: float,
  bankShare: float,
}

type benefit = {
  benefitType: benefitType,
  calculationRule: calculationRule,
  value: float,
  maxAmount: option<float>,
  globalMaxAmount: option<float>,
  roundoffRule: option<roundOffRule>,
  costSharing: option<costSharing>,
  amountInfo: array<string>,
}

type paymentInstrument = {
  paymentMethodType: string,
  paymentMethod: array<string>,
  cardType: array<string>,
  issuer: array<string>,
  variant: array<string>,
  category: array<string>,
  app: array<string>,
  cardCountry: array<string>,
  cardFlowType: string,
  eligibleForTokenization: option<bool>,
  isMandate: option<bool>,
}

type currencyConstraint = {
  name: string,
  minOrderAmount: string,
  maxOrderAmount: string,
}

type orderConstraint = {
  currencies: array<currencyConstraint>,
  minQuantity: option<int>,
  maxQuantity: option<int>,
  amountInfo: array<string>,
}

type counter = {
  counterType: array<string>,
  value: string,
  operator: string,
  resetFrequencyUnit: string,
  resetPeriod: string,
  valueType: string,
}

type filterEntry = {
  filterType: string,
  values: array<string>,
  isValueUploaded: bool,
}

type filters = {
  whitelist: array<filterEntry>,
  blacklist: array<filterEntry>,
}

type recurrence = {
  frequency: string,
  interval: int,
  byDay: array<string>,
  byDate: array<string>,
}

type timeRange = {
  gte: string,
  lte: string,
}

type schedule = {
  recurrence: option<recurrence>,
  dateWhitelist: array<string>,
  dateBlacklist: array<string>,
  durationUnit: string,
  durationAmount: option<int>,
  timeRanges: array<timeRange>,
}

type ruleDsl = {
  benefits: array<benefit>,
  paymentInstrument: array<paymentInstrument>,
  order: orderConstraint,
  counters: array<counter>,
  filters: filters,
  schedule: option<schedule>,
  paymentChannel: array<string>,
  txnType: array<string>,
  raw: JSON.t,
}

type offer = {
  offerId: string,
  offerCode: string,
  status: offerStatus,
  offerDescription: offerDescription,
  uiConfigs: uiConfigs,
  ruleDsl: ruleDsl,
  groupId: string,
  priority: option<int>,
  createdAt: string,
  startTime: string,
  endTime: string,
  batchId: string,
  parentOfferId: string,
  accountType: string,
  source: string,
  sourceOfferId: string,
  language: string,
  hasMultiCodes: bool,
  eligibilityMode: string,
  metadata: JSON.t,
}

type counterInfo = {
  name: string,
  description: string,
  value: string,
  limit: string,
  errorMessage: string,
}

type tagDetail = {
  id: string,
  name: string,
}

type offerDetail = {
  offer: offer,
  merchantId: string,
  updatedAt: string,
  applicationMode: string,
  counterInfo: array<counterInfo>,
  tags: array<tagDetail>,
  udfs: array<(string, string)>,
}

type offersSummary = {
  totalCount: int,
  count: int,
}

type offersListResponse = {
  summary: offersSummary,
  list: array<offer>,
}

type sortField =
  | @as("GROUP_ID") GroupIdSort
  | @as("STATUS") StatusSort
  | @as("OFFER_CODE") OfferCodeSort
  | @as("PRIORITY") PrioritySort
  | @as("CREATED_AT") CreatedAtSort

type sortOrder = | @as("ASCENDING") Ascending | @as("DESCENDING") Descending

type summaryColType =
  | OfferId
  | OfferCode
  | MerchantId
  | GroupId
  | Priority
  | StartTime
  | EndTime
  | CreatedAt
  | UpdatedAt
  | EligibilityMode
  | ApplicationMode
  | Source
  | Language
  | AccountType
  | CouponBased

type benefitColType =
  | BenefitType
  | CalculationRule
  | BenefitValue
  | MaxAmount
  | GlobalMaxAmount
  | RoundoffRule
  | CostSharing

type paymentInstrumentColType =
  | InstrumentPaymentMethodType
  | PaymentMethod
  | CardType
  | Issuer
  | Variant
  | CardFlowType
  | EligibleForTokenization
  | IsMandate

type paymentSummaryColType =
  | PaymentChannel
  | TxnType

type currencyColType =
  | CurrencyName
  | CurrencyMinOrderAmount
  | CurrencyMaxOrderAmount

type orderSummaryColType =
  | MinQuantity
  | MaxQuantity
  | OrderAmountInfo

type counterColType =
  | CounterDimension
  | CounterValue
  | CounterOperator
  | ResetFrequencyUnit
  | ResetPeriod
  | CounterValueType

type counterInfoColType =
  | CounterName
  | CounterDescription
  | CounterCurrentValue
  | CounterLimit
  | CounterErrorMessage

type scheduleColType =
  | Recurrence
  | DurationUnit
  | DurationAmount
  | ByDay
  | TimeRanges
  | DateWhitelist
  | DateBlacklist

type additionalConfigColType =
  | AutoApply
  | ShouldValidate
  | IsHidden
  | IsBanner
  | OfferDisplayPriority
  | OfferLabel
  | HasMultiCodes
  | BatchId
  | ParentOfferId
  | SourceOfferId
  | SponsoredBy
  | Tags
