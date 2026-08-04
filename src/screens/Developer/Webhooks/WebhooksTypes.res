type tabs = Request | Response

type eventRecipient = Merchant | Connector

type eventClass = Payments | Refunds | Disputes | Mandates | Payouts | Subscriptions

type webhookEventType =
  | PaymentSucceeded
  | PaymentFailed
  | PaymentProcessing
  | PaymentCancelled
  | PaymentCancelledPostCapture
  | PaymentAuthorized
  | PaymentCaptured
  | PaymentExpired
  | ActionRequired
  | SurchargePaymentSucceeded
  | RefundSucceeded
  | RefundFailed
  | SurchargeRefundSucceeded
  | DisputeOpened
  | DisputeExpired
  | DisputeAccepted
  | DisputeCancelled
  | DisputeChallenged
  | DisputeWon
  | DisputeLost
  | MandateActive
  | MandateRevoked
  | PayoutSuccess
  | PayoutFailed
  | PayoutInitiated
  | PayoutProcessing
  | PayoutCancelled
  | PayoutExpired
  | PayoutReversed
  | InvoicePaid

type webhookObject = {
  eventId: string,
  merchantId: string,
  profileId: string,
  objectId: string,
  eventType: string,
  eventClass: string,
  isDeliverySuccessful: bool,
  initialAttemptId: string,
  created: string,
}

type webhook = {
  events: array<webhookObject>,
  total_count: int,
}

type request = {
  body: string,
  headers: JSON.t,
}

type response = {
  body: string,
  errorMessage: option<string>,
  headers: JSON.t,
  statusCode: int,
}

type attemptType = {
  eventId: string,
  merchantId: string,
  profileId: string,
  objectId: string,
  eventType: string,
  eventClass: string,
  isDeliverySuccessful: bool,
  initialAttemptId: string,
  created: string,
  request: request,
  response: response,
  deliveryAttempt: string,
}

type attempts = array<attemptType>

type attemptTable = {
  isDeliverySuccessful: bool,
  deliveryAttempt: string,
  eventId: string,
  created: string,
}
