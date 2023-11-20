type dataState<'a> = Loaded('a) | Loading | LoadedError
type metricsType =
  | Latency
  | Volume
  | Rate
  | Amount
  | NegativeRate

type timeObj = {
  apiStartTime: float,
  apiEndTime: float,
}

let timeObj = {
  apiStartTime: 0.,
  apiEndTime: 0.,
}

// type txnmetrics =
//   | TotalVolume
//   | SuccessVolume
//   | SuccessRate
//   | ConflictTxnRate
//   | AverageLatency
//   | AvgTicketSize
//   | TotalAmount

// type txndimension =
//   | PaymentGateway
//   | OrderType
//   | TxnLatency
//   | BusinessRegion
//   | Currency
//   | TicketSize
//   | SsEmi
//   | PgRrrorMessage
//   | TxnFlowType
//   | CardBrand
//   | PreviousTxnStatus
//   | RunDate
//   | Lob
//   | AuthType
//   | PaymentStatus
//   | MerchantId
//   | TxnType
//   | TokenRepeat
//   | EmiType
//   | ActualPaymentStatus
//   | IsTokenBin
//   | EmiBank
//   | StatusSyncSource
//   | Bank
//   | IsTxnConflicted
//   | PaymentMethodType
//   | PaymentMethodSubtype
//   | CardExpMonth
//   | CardExpYear
//   | UsingStoredCard
//   | RunMonth
//   | Card_issuerCountry
//   | PaymentFlow
//   | EmiTenure

// let txnmetrics = [
//   TotalVolume,
//   SuccessVolume,
//   SuccessRate,
//   ConflictTxnRate,
//   AverageLatency,
//   AvgTicketSize,
//   TotalAmount,
// ]

// let txndimension = [
//   Bank,
//   MerchantId,
//   PaymentGateway,
//   PaymentMethodType,
//   OrderType,
//   TxnLatency,
//   BusinessRegion,
//   Currency,
//   TicketSize,
//   SsEmi,
//   PgRrrorMessage,
//   TxnFlowType,
//   CardBrand,
//   PreviousTxnStatus,
//   RunDate,
//   Lob,
//   AuthType,
//   PaymentStatus,
//   TxnType,
//   TokenRepeat,
//   EmiType,
//   ActualPaymentStatus,
//   IsTokenBin,
//   EmiBank,
//   StatusSyncSource,
//   IsTxnConflicted,
//   PaymentMethodSubtype,
//   CardExpMonth,
//   CardExpYear,
//   UsingStoredCard,
//   RunMonth,
//   Card_issuerCountry,
//   PaymentFlow,
//   EmiTenure,
// ]

// type timeFilter = T_ONEDAY | T_SEVENDAY | T_THIRTYDAY | T_SIXTYDAY
// type granularValue = G_ONEMIN | G_FIVEMIN | G_FIFTEENMIN | G_ONEHOUR | G_ONEDAY
// type lastDays = Day(float) | Week(float) | Month(float) | Today | Yesterday
// type sortOrder = ASC | DESC

// let sortOrderMapper = sortOrder => {
//   switch sortOrder {
//   | ASC => "ASC"
//   | DESC => "DESC"
//   }
// }

// let txnMetricsMapper = (metric: txnmetrics) => {
//   switch metric {
//   | TotalVolume => "total_volume"
//   | SuccessVolume => "success_volume"
//   | SuccessRate => "success_rate"
//   | ConflictTxnRate => "conflict_txn_rate"
//   | AverageLatency => "average_latency"
//   | AvgTicketSize => "avg_ticket_size"
//   | TotalAmount => "total_amount"
//   }
// }

// let txnMetricsTypeMapper = (metric: txnmetrics) => {
//   switch metric {
//   | TotalVolume => Volume
//   | SuccessVolume => Volume
//   | SuccessRate => Rate
//   | ConflictTxnRate => Rate
//   | AverageLatency => Latency
//   | AvgTicketSize => Amount
//   | TotalAmount => Amount
//   }
// }

// let txnDimsMapper = (dims: txndimension) => {
//   switch dims {
//   | PaymentGateway => "payment_gateway"
//   | OrderType => "order_type"
//   | TxnLatency => "txn_latency"
//   | BusinessRegion => "business_region"
//   | Currency => "currency"
//   | TicketSize => "ticket_size"
//   | SsEmi => "is_emi"
//   | PgRrrorMessage => "pg_error_message"
//   | TxnFlowType => "txn_flow_type"
//   | CardBrand => "card_brand"
//   | PreviousTxnStatus => "previous_txn_status"
//   | RunDate => "run_date"
//   | Lob => "lob"
//   | AuthType => "auth_type"
//   | PaymentStatus => "payment_status"
//   | MerchantId => "merchant_id"
//   | TxnType => "txn_type"
//   | TokenRepeat => "token_repeat"
//   | EmiType => "emi_type"
//   | ActualPaymentStatus => "actual_payment_status"
//   | IsTokenBin => "is_token_bin"
//   | EmiBank => "emi_bank"
//   | StatusSyncSource => "status_sync_source"
//   | Bank => "bank"
//   | IsTxnConflicted => "is_txn_conflicted"
//   | PaymentMethodType => "payment_method_type"
//   | PaymentMethodSubtype => "payment_method_subtype"
//   | CardExpMonth => "card_exp_month"
//   | CardExpYear => "card_exp_year"
//   | UsingStoredCard => "using_stored_card"
//   | RunMonth => "run_month"
//   | Card_issuerCountry => "card_issuer_country"
//   | PaymentFlow => "payment_flow"
//   | EmiTenure => "emi_tenure"
//   }
// }

let metricsTypeMapper = metricsType => {
  switch metricsType {
  | Latency => "Latency"
  | Volume => "Volume"
  | Rate => "Rate"
  | Amount => "Amount"
  | NegativeRate => "NegativeRate"
  }
}

let metricsTypeMapperOPP = metricsType => {
  switch metricsType {
  | "Latency" => Latency
  | "Volume" => Volume
  | "Rate" => Rate
  | "Amount" => Amount
  | "NegativeRate" => NegativeRate
  | _ =>
    raise(
      Invalid_argument(`invalid values, only Volume, Rate, Amount,NegativeRate is accepted as values`),
    )
  }
}
