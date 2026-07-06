type options = {
  name: string,
  key: string,
}

type vaultStatus =
  | Enable
  | Skip

type validationFieldsV2 =
  | WebhookDetails
  | ReturnUrl
  | AuthenticationConnectorDetails
  | AuthenticationConnectors(array<JSON.t>)
  | ThreeDsRequestorUrl
  | ThreeDsRequestorAppUrl
  | MaxAutoRetries
  | AutoRetry
  | VaultProcessorDetails
  | UnknownValidateFields(string)

@unboxed
type webhookPaymentStatus =
  | @as("succeeded") Succeeded
  | @as("failed") Failed
  | @as("cancelled") Cancelled
  | @as("cancelled_post_capture") CancelledPostCapture
  | @as("processing") Processing
  | @as("partially_captured_and_processing") PartiallyCapturedAndProcessing
  | @as("requires_customer_action") RequiresCustomerAction
  | @as("requires_merchant_action") RequiresMerchantAction
  | @as("requires_capture") RequiresCapture
  | @as("partially_captured") PartiallyCaptured
  | @as("partially_captured_and_capturable") PartiallyCapturedAndCapturable
  | @as("partially_authorized_and_requires_capture") PartiallyAuthorizedAndRequiresCapture
  | @as("conflicted") Conflicted
  | @as("expired") Expired

let webhookPaymentStatusValues = [
  Succeeded,
  Failed,
  Cancelled,
  CancelledPostCapture,
  Processing,
  PartiallyCapturedAndProcessing,
  RequiresCustomerAction,
  RequiresMerchantAction,
  RequiresCapture,
  PartiallyCaptured,
  PartiallyCapturedAndCapturable,
  PartiallyAuthorizedAndRequiresCapture,
  Conflicted,
  Expired,
]

@unboxed
type webhookRefundStatus =
  | @as("failure") Failure
  | @as("success") Success

let webhookRefundStatusValues = [Failure, Success]

@unboxed
type webhookPayoutStatus =
  | @as("success") PayoutSuccess
  | @as("failed") PayoutFailed
  | @as("cancelled") PayoutCancelled
  | @as("initiated") Initiated
  | @as("expired") PayoutExpired
  | @as("reversed") Reversed

let webhookPayoutStatusValues = [
  PayoutSuccess,
  PayoutFailed,
  PayoutCancelled,
  Initiated,
  PayoutExpired,
  Reversed,
]
