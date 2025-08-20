type paymentLifeCycle = {
  normalSuccess: int,
  normalFailure: int,
  cancelled: int,
  smartRetriedSuccess: int,
  smartRetriedFailure: int,
  pending: int,
  partialRefunded: int,
  refunded: int,
  disputed: int,
  drop_offs: int,
}

type status =
  | Succeeded
  | Failed
  | Cancelled
  | Processing
  | RequiresCustomerAction
  | RequiresMerchantAction
  | RequiresPaymentMethod
  | RequiresConfirmation
  | RequiresCapture
  | PartiallyCaptured
  | PartiallyCapturedAndCapturable
  | Full_Refunded
  | Partial_Refunded
  | Dispute_Present
  | Null

type query = {
  count: int,
  dispute_status: status,
  first_attempt: int,
  refunds_status: status,
  status: status,
}
