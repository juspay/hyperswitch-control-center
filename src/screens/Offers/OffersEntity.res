open LogicUtils
open OffersTypes
open OffersUtils

let defaultColumns: array<colType> = [
  OfferCode,
  Title,
  Status,
  Benefit,
  PaymentMethodType,
  StartEndTime,
  CreatedAt,
  Actions,
]

let allColumns: array<colType> = [
  OfferId,
  OfferCode,
  Title,
  Status,
  Benefit,
  PaymentMethodType,
  CouponBased,
  StartEndTime,
  CreatedAt,
  Priority,
  GroupId,
  BatchId,
  MinOrderAmount,
  EligibilityMode,
  Language,
  Source,
  SourceOfferId,
  ParentOfferId,
  Actions,
]

let getHeading = (colType: colType) =>
  switch colType {
  | OfferId => Table.makeHeaderInfo(~key="offer_id", ~title="Offer ID")
  | OfferCode => Table.makeHeaderInfo(~key="offer_code", ~title="Offer Code")
  | Title => Table.makeHeaderInfo(~key="offer_description.title", ~title="Offer Title")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Benefit => Table.makeHeaderInfo(~key="rule_dsl.benefits[0].type", ~title="Benefit")
  | PaymentMethodType =>
    Table.makeHeaderInfo(
      ~key="rule_dsl.payment_instrument[0].payment_method_type",
      ~title="Payment Method Type",
    )
  | CouponBased => Table.makeHeaderInfo(~key="ui_configs.auto_apply", ~title="Coupon Based")
  | StartEndTime => Table.makeHeaderInfo(~key="start_time", ~title="Start and End Time")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  | Priority => Table.makeHeaderInfo(~key="priority", ~title="Priority")
  | GroupId => Table.makeHeaderInfo(~key="group_id", ~title="Group ID")
  | BatchId => Table.makeHeaderInfo(~key="batch_id", ~title="Batch ID")
  | MinOrderAmount =>
    Table.makeHeaderInfo(~key="rule_dsl.order.min_order_amount", ~title="Min Order Amount")
  | EligibilityMode => Table.makeHeaderInfo(~key="eligibility_mode", ~title="Eligibility Mode")
  | Language => Table.makeHeaderInfo(~key="language", ~title="Language")
  | Source => Table.makeHeaderInfo(~key="source", ~title="Source")
  | SourceOfferId => Table.makeHeaderInfo(~key="source_offer_id", ~title="Source Offer ID")
  | ParentOfferId => Table.makeHeaderInfo(~key="parent_offer_id", ~title="Parent Offer ID")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }

let getCell = (~onStatusToggled, ~onDiscarded, ~hasManageAccess) => (
  offer: offer,
  colType: colType,
): Table.cell =>
  switch colType {
  | OfferId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue={Some(offer.offerId)}
        copyValue={Some(offer.offerId)}
        showTooltip=true
      />,
      "",
    )
  | OfferCode =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue={Some(offer.offerCode)}
        copyValue={Some(offer.offerCode)}
        showTooltip=true
      />,
      "",
    )
  | Title => EllipsisText(offer->offerTitle, "w-48")
  | Status =>
    Label({
      title: offer.status->statusToDisplayName->String.toUpperCase,
      color: offer.status->statusToLabelColor,
    })
  | Benefit => Text(offer->primaryBenefitLabel->displayOrPlaceholder)
  | PaymentMethodType => Text(offer->primaryPaymentMethodLabel->displayOrPlaceholder)
  | CouponBased => Text(offer->isCouponBased->getYesOrNo)
  | StartEndTime => StartEndDate(offer.startTime, offer.endTime)
  | CreatedAt => Date(offer.createdAt)
  | Priority =>
    Text(offer.priority->Option.mapOr(emptyValuePlaceholder, priority => priority->Int.toString))
  | GroupId => Text(offer.groupId->displayOrPlaceholder)
  | BatchId => Text(offer.batchId->displayOrPlaceholder)
  | MinOrderAmount => Text(offer->minOrderAmountLabel->displayOrPlaceholder)
  | EligibilityMode => Text(offer.eligibilityMode->snakeToTitle->displayOrPlaceholder)
  | Language => Text(offer.language->String.toUpperCase->displayOrPlaceholder)
  | Source => Text(offer.source->snakeToTitle->displayOrPlaceholder)
  | SourceOfferId => Text(offer.sourceOfferId->displayOrPlaceholder)
  | ParentOfferId => Text(offer.parentOfferId->displayOrPlaceholder)
  | Actions =>
    CustomCell(
      <RenderIf condition=hasManageAccess>
        <OfferRowActions offer onStatusToggled onDiscarded />
      </RenderIf>,
      "",
    )
  }

let getOffers: JSON.t => array<offer> = json => json->getArrayDataFromJson(itemToObjMapper)

let offersEntity = (~onStatusToggled, ~onDiscarded, ~hasManageAccess) => {
  let getPermittedColumns = columns =>
    hasManageAccess ? columns : columns->Array.filter(colType => colType !== Actions)

  EntityType.makeEntity(
    ~uri="",
    ~getObjects=getOffers,
    ~defaultColumns=defaultColumns->getPermittedColumns,
    ~allColumns=allColumns->getPermittedColumns,
    ~getHeading,
    ~getCell=getCell(~onStatusToggled, ~onDiscarded, ~hasManageAccess),
    ~dataKey="",
    ~getShowLink={
      offer => GlobalVars.appendDashboardPath(~url=`/offers/${offer.offerId}`)
    },
  )
}

let summaryDetailsFields: array<summaryColType> = [
  OfferId,
  OfferCode,
  MerchantId,
  GroupId,
  Priority,
  StartTime,
  EndTime,
  CreatedAt,
  UpdatedAt,
  EligibilityMode,
  ApplicationMode,
  Source,
  Language,
  AccountType,
  CouponBased,
]

let getHeadingForSummary = (colType: summaryColType) =>
  switch colType {
  | OfferId => Table.makeHeaderInfo(~key="offer_id", ~title="Offer ID")
  | OfferCode => Table.makeHeaderInfo(~key="offer_code", ~title="Offer Code")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  | GroupId => Table.makeHeaderInfo(~key="group_id", ~title="Group ID")
  | Priority => Table.makeHeaderInfo(~key="priority", ~title="Priority")
  | StartTime => Table.makeHeaderInfo(~key="start_time", ~title="Start Time")
  | EndTime => Table.makeHeaderInfo(~key="end_time", ~title="End Time")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | UpdatedAt => Table.makeHeaderInfo(~key="updated_at", ~title="Updated At")
  | EligibilityMode => Table.makeHeaderInfo(~key="eligibility_mode", ~title="Eligibility Mode")
  | ApplicationMode => Table.makeHeaderInfo(~key="application_mode", ~title="Application Mode")
  | Source => Table.makeHeaderInfo(~key="source", ~title="Source")
  | Language => Table.makeHeaderInfo(~key="language", ~title="Language")
  | AccountType => Table.makeHeaderInfo(~key="account_type", ~title="Account Type")
  | CouponBased => Table.makeHeaderInfo(~key="ui_configs.auto_apply", ~title="Coupon Based")
  }

let getCellForSummary = (detail: offerDetail, colType: summaryColType): Table.cell => {
  let offer = detail.offer
  switch colType {
  | OfferId => DisplayCopyCell(offer.offerId)
  | OfferCode => DisplayCopyCell(offer.offerCode)
  | MerchantId => DisplayCopyCell(detail.merchantId)
  | GroupId => Text(offer.groupId->displayOrPlaceholder)
  | Priority =>
    Text(offer.priority->Option.mapOr(emptyValuePlaceholder, priority => priority->Int.toString))
  | StartTime => Date(offer.startTime)
  | EndTime => Date(offer.endTime)
  | CreatedAt => Date(offer.createdAt)
  | UpdatedAt => Date(detail.updatedAt)
  | EligibilityMode => Text(offer.eligibilityMode->snakeToTitle->displayOrPlaceholder)
  | ApplicationMode => Text(detail.applicationMode->snakeToTitle->displayOrPlaceholder)
  | Source => Text(offer.source->snakeToTitle->displayOrPlaceholder)
  | Language => Text(offer.language->String.toUpperCase->displayOrPlaceholder)
  | AccountType => Text(offer.accountType->snakeToTitle->displayOrPlaceholder)
  | CouponBased => Text(offer->isCouponBased->getYesOrNo)
  }
}

let benefitColumns: array<benefitColType> = [
  BenefitType,
  CalculationRule,
  BenefitValue,
  MaxAmount,
  GlobalMaxAmount,
  RoundoffRule,
  CostSharing,
]

let getHeadingForBenefit = (colType: benefitColType) =>
  switch colType {
  | BenefitType => Table.makeHeaderInfo(~key="type", ~title="Type")
  | CalculationRule => Table.makeHeaderInfo(~key="calculation_rule", ~title="Calculation")
  | BenefitValue => Table.makeHeaderInfo(~key="value", ~title="Value")
  | MaxAmount => Table.makeHeaderInfo(~key="max_amount", ~title="Max Amount")
  | GlobalMaxAmount => Table.makeHeaderInfo(~key="global_max_amount", ~title="Global Max")
  | RoundoffRule => Table.makeHeaderInfo(~key="roundoff_rule", ~title="Roundoff")
  | CostSharing => Table.makeHeaderInfo(~key="cost_sharing", ~title="Cost Sharing")
  }

let getCellForBenefit = (benefit: benefit, colType: benefitColType): Table.cell =>
  switch colType {
  | BenefitType => Text(benefit.benefitType->benefitTypeToDisplayName)
  | CalculationRule => Text((benefit.calculationRule :> string)->snakeToTitle)
  | BenefitValue => Text(benefit->formatBenefitValue)
  | MaxAmount =>
    Text(benefit.maxAmount->Option.mapOr(emptyValuePlaceholder, amount => amount->Float.toString))
  | GlobalMaxAmount =>
    Text(
      benefit.globalMaxAmount->Option.mapOr(emptyValuePlaceholder, amount =>
        amount->Float.toString
      ),
    )
  | RoundoffRule =>
    Text(
      benefit.roundoffRule->Option.mapOr(emptyValuePlaceholder, rule =>
        `${rule.roundingFunction->snakeToTitle} (${rule.decimalPlaces->snakeToTitle})`
      ),
    )
  | CostSharing =>
    Text(
      benefit.costSharing->Option.mapOr(emptyValuePlaceholder, sharing =>
        `Merchant ${sharing.merchantShare->Float.toString} / Bank ${sharing.bankShare->Float.toString}`
      ),
    )
  }

let paymentInstrumentColumns: array<paymentInstrumentColType> = [
  InstrumentPaymentMethodType,
  PaymentMethod,
  CardType,
  Issuer,
  Variant,
  CardFlowType,
  EligibleForTokenization,
  IsMandate,
]

let getHeadingForPaymentInstrument = (colType: paymentInstrumentColType) =>
  switch colType {
  | InstrumentPaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Method Type")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Method")
  | CardType => Table.makeHeaderInfo(~key="card_type", ~title="Card Type")
  | Issuer => Table.makeHeaderInfo(~key="issuer", ~title="Issuer")
  | Variant => Table.makeHeaderInfo(~key="variant", ~title="Variant")
  | CardFlowType => Table.makeHeaderInfo(~key="card_flow_type", ~title="Card Flow")
  | EligibleForTokenization =>
    Table.makeHeaderInfo(~key="eligible_for_tokenization", ~title="Tokenization")
  | IsMandate => Table.makeHeaderInfo(~key="is_mandate", ~title="Mandate")
  }

let getCellForPaymentInstrument = (
  instrument: paymentInstrument,
  colType: paymentInstrumentColType,
): Table.cell => {
  let joinOrPlaceholder = values => values->Array.joinWith(", ")->displayOrPlaceholder
  switch colType {
  | InstrumentPaymentMethodType =>
    Text(instrument.paymentMethodType->snakeToTitle->displayOrPlaceholder)
  | PaymentMethod => Text(instrument.paymentMethod->joinOrPlaceholder)
  | CardType => Text(instrument.cardType->joinOrPlaceholder)
  | Issuer => Text(instrument.issuer->joinOrPlaceholder)
  | Variant => Text(instrument.variant->joinOrPlaceholder)
  | CardFlowType => Text(instrument.cardFlowType->snakeToTitle->displayOrPlaceholder)
  | EligibleForTokenization =>
    Text(instrument.eligibleForTokenization->Option.mapOr(emptyValuePlaceholder, getYesOrNo))
  | IsMandate => Text(instrument.isMandate->Option.mapOr(emptyValuePlaceholder, getYesOrNo))
  }
}

let paymentSummaryFields: array<paymentSummaryColType> = [PaymentChannel, TxnType]

let getHeadingForPaymentSummary = (colType: paymentSummaryColType) =>
  switch colType {
  | PaymentChannel => Table.makeHeaderInfo(~key="payment_channel", ~title="Payment Channel")
  | TxnType => Table.makeHeaderInfo(~key="txn_type", ~title="Transaction Type")
  }

let getCellForPaymentSummary = (ruleDsl: ruleDsl, colType: paymentSummaryColType): Table.cell =>
  switch colType {
  | PaymentChannel =>
    CustomCell(
      <OfferDetailHelper.Chips values=ruleDsl.paymentChannel emptyMessage="All channels" />,
      "",
    )
  | TxnType =>
    CustomCell(
      <OfferDetailHelper.Chips values=ruleDsl.txnType emptyMessage="All transaction types" />,
      "",
    )
  }

let currencyColumns: array<currencyColType> = [
  CurrencyName,
  CurrencyMinOrderAmount,
  CurrencyMaxOrderAmount,
]

let getHeadingForCurrency = (colType: currencyColType) =>
  switch colType {
  | CurrencyName => Table.makeHeaderInfo(~key="name", ~title="Currency")
  | CurrencyMinOrderAmount =>
    Table.makeHeaderInfo(~key="min_order_amount", ~title="Min Order Amount")
  | CurrencyMaxOrderAmount =>
    Table.makeHeaderInfo(~key="max_order_amount", ~title="Max Order Amount")
  }

let getCellForCurrency = (currency: currencyConstraint, colType: currencyColType): Table.cell =>
  switch colType {
  | CurrencyName => Text(currency.name->displayOrPlaceholder)
  | CurrencyMinOrderAmount => Text(currency.minOrderAmount->displayOrPlaceholder)
  | CurrencyMaxOrderAmount => Text(currency.maxOrderAmount->displayOrPlaceholder)
  }

let orderSummaryFields: array<orderSummaryColType> = [MinQuantity, MaxQuantity, OrderAmountInfo]

let getHeadingForOrderSummary = (colType: orderSummaryColType) =>
  switch colType {
  | MinQuantity => Table.makeHeaderInfo(~key="min_quantity", ~title="Min Quantity")
  | MaxQuantity => Table.makeHeaderInfo(~key="max_quantity", ~title="Max Quantity")
  | OrderAmountInfo => Table.makeHeaderInfo(~key="amount_info", ~title="Amount Info")
  }

let getCellForOrderSummary = (order: orderConstraint, colType: orderSummaryColType): Table.cell =>
  switch colType {
  | MinQuantity =>
    Text(order.minQuantity->Option.mapOr(emptyValuePlaceholder, value => value->Int.toString))
  | MaxQuantity =>
    Text(order.maxQuantity->Option.mapOr(emptyValuePlaceholder, value => value->Int.toString))
  | OrderAmountInfo => CustomCell(<OfferDetailHelper.Chips values=order.amountInfo />, "")
  }

let counterColumns: array<counterColType> = [
  CounterDimension,
  CounterValue,
  CounterOperator,
  ResetFrequencyUnit,
  ResetPeriod,
  CounterValueType,
]

let getHeadingForCounter = (colType: counterColType) =>
  switch colType {
  | CounterDimension => Table.makeHeaderInfo(~key="counter_type", ~title="Dimension")
  | CounterValue => Table.makeHeaderInfo(~key="value", ~title="Value")
  | CounterOperator => Table.makeHeaderInfo(~key="operator", ~title="Operator")
  | ResetFrequencyUnit => Table.makeHeaderInfo(~key="reset_frequency_unit", ~title="Reset Unit")
  | ResetPeriod => Table.makeHeaderInfo(~key="reset_period", ~title="Reset Period")
  | CounterValueType => Table.makeHeaderInfo(~key="value_type", ~title="Value Type")
  }

let getCellForCounter = (counter: counter, colType: counterColType): Table.cell =>
  switch colType {
  | CounterDimension => Text(counter.counterType->Array.joinWith(", ")->displayOrPlaceholder)
  | CounterValue => Text(counter.value->displayOrPlaceholder)
  | CounterOperator => Text(counter.operator->snakeToTitle->displayOrPlaceholder)
  | ResetFrequencyUnit => Text(counter.resetFrequencyUnit->snakeToTitle->displayOrPlaceholder)
  | ResetPeriod => Text(counter.resetPeriod->displayOrPlaceholder)
  | CounterValueType => Text(counter.valueType->snakeToTitle->displayOrPlaceholder)
  }

let counterInfoColumns: array<counterInfoColType> = [
  CounterName,
  CounterDescription,
  CounterCurrentValue,
  CounterLimit,
  CounterErrorMessage,
]

let getHeadingForCounterInfo = (colType: counterInfoColType) =>
  switch colType {
  | CounterName => Table.makeHeaderInfo(~key="name", ~title="Name")
  | CounterDescription => Table.makeHeaderInfo(~key="description", ~title="Description")
  | CounterCurrentValue => Table.makeHeaderInfo(~key="value", ~title="Value")
  | CounterLimit => Table.makeHeaderInfo(~key="limit", ~title="Limit")
  | CounterErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error")
  }

let getCellForCounterInfo = (info: counterInfo, colType: counterInfoColType): Table.cell =>
  switch colType {
  | CounterName => Text(info.name->displayOrPlaceholder)
  | CounterDescription => Text(info.description->displayOrPlaceholder)
  | CounterCurrentValue => Text(info.value->displayOrPlaceholder)
  | CounterLimit => Text(info.limit->displayOrPlaceholder)
  | CounterErrorMessage => Text(info.errorMessage->displayOrPlaceholder)
  }

let scheduleDetailsFields: array<scheduleColType> = [
  Recurrence,
  DurationUnit,
  DurationAmount,
  ByDay,
  TimeRanges,
  DateWhitelist,
  DateBlacklist,
]

let getHeadingForSchedule = (colType: scheduleColType) =>
  switch colType {
  | Recurrence => Table.makeHeaderInfo(~key="recurrence", ~title="Recurrence")
  | DurationUnit => Table.makeHeaderInfo(~key="duration_unit", ~title="Duration Unit")
  | DurationAmount => Table.makeHeaderInfo(~key="duration_amount", ~title="Duration Amount")
  | ByDay => Table.makeHeaderInfo(~key="recurrence.by_day", ~title="Days")
  | TimeRanges => Table.makeHeaderInfo(~key="time_ranges", ~title="Time Ranges")
  | DateWhitelist => Table.makeHeaderInfo(~key="date_whitelist", ~title="Date Whitelist")
  | DateBlacklist => Table.makeHeaderInfo(~key="date_blacklist", ~title="Date Blacklist")
  }

let getCellForSchedule = (schedule: schedule, colType: scheduleColType): Table.cell =>
  switch colType {
  | Recurrence =>
    Text(
      schedule.recurrence->Option.mapOr(emptyValuePlaceholder, recurrence =>
        `${recurrence.frequency->snakeToTitle} (every ${recurrence.interval->Int.toString})`
      ),
    )
  | DurationUnit => Text(schedule.durationUnit->snakeToTitle->displayOrPlaceholder)
  | DurationAmount =>
    Text(schedule.durationAmount->Option.mapOr(emptyValuePlaceholder, value => value->Int.toString))
  | ByDay =>
    CustomCell(
      <OfferDetailHelper.Chips
        values={schedule.recurrence->Option.mapOr([], recurrence => recurrence.byDay)}
      />,
      "",
    )
  | TimeRanges =>
    CustomCell(
      <OfferDetailHelper.Chips
        values={schedule.timeRanges->Array.map(range => `${range.gte} - ${range.lte}`)}
      />,
      "",
    )
  | DateWhitelist => CustomCell(<OfferDetailHelper.Chips values=schedule.dateWhitelist />, "")
  | DateBlacklist => CustomCell(<OfferDetailHelper.Chips values=schedule.dateBlacklist />, "")
  }

let additionalConfigFields: array<additionalConfigColType> = [
  AutoApply,
  ShouldValidate,
  IsHidden,
  IsBanner,
  OfferDisplayPriority,
  OfferLabel,
  HasMultiCodes,
  BatchId,
  ParentOfferId,
  SourceOfferId,
  SponsoredBy,
  Tags,
]

let getHeadingForAdditionalConfig = (colType: additionalConfigColType) =>
  switch colType {
  | AutoApply => Table.makeHeaderInfo(~key="ui_configs.auto_apply", ~title="Auto Apply")
  | ShouldValidate =>
    Table.makeHeaderInfo(~key="ui_configs.should_validate", ~title="Should Validate")
  | IsHidden => Table.makeHeaderInfo(~key="ui_configs.is_hidden", ~title="Hidden")
  | IsBanner => Table.makeHeaderInfo(~key="ui_configs.is_banner", ~title="Banner")
  | OfferDisplayPriority =>
    Table.makeHeaderInfo(~key="ui_configs.offer_display_priority", ~title="Display Priority")
  | OfferLabel => Table.makeHeaderInfo(~key="ui_configs.offer_label", ~title="Offer Label")
  | HasMultiCodes => Table.makeHeaderInfo(~key="has_multi_codes", ~title="Has Multiple Codes")
  | BatchId => Table.makeHeaderInfo(~key="batch_id", ~title="Batch ID")
  | ParentOfferId => Table.makeHeaderInfo(~key="parent_offer_id", ~title="Parent Offer ID")
  | SourceOfferId => Table.makeHeaderInfo(~key="source_offer_id", ~title="Source Offer ID")
  | SponsoredBy =>
    Table.makeHeaderInfo(~key="offer_description.sponsored_by", ~title="Sponsored By")
  | Tags => Table.makeHeaderInfo(~key="tags", ~title="Tags")
  }

let getCellForAdditionalConfig = (
  detail: offerDetail,
  colType: additionalConfigColType,
): Table.cell => {
  let offer = detail.offer
  switch colType {
  | AutoApply => Text(offer.uiConfigs.autoApply->getYesOrNo)
  | ShouldValidate => Text(offer.uiConfigs.shouldValidate->getYesOrNo)
  | IsHidden => Text(offer.uiConfigs.isHidden->getYesOrNo)
  | IsBanner => Text(offer.uiConfigs.isBanner->getYesOrNo)
  | OfferDisplayPriority =>
    Text(
      offer.uiConfigs.offerDisplayPriority->Option.mapOr(emptyValuePlaceholder, value =>
        value->Int.toString
      ),
    )
  | OfferLabel => Text(offer.uiConfigs.offerLabel->displayOrPlaceholder)
  | HasMultiCodes => Text(offer.hasMultiCodes->getYesOrNo)
  | BatchId => Text(offer.batchId->displayOrPlaceholder)
  | ParentOfferId => Text(offer.parentOfferId->displayOrPlaceholder)
  | SourceOfferId => Text(offer.sourceOfferId->displayOrPlaceholder)
  | SponsoredBy => Text(offer.offerDescription.sponsoredBy->displayOrPlaceholder)
  | Tags =>
    CustomCell(<OfferDetailHelper.Chips values={detail.tags->Array.map(tag => tag.name)} />, "")
  }
}
