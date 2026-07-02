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

type webhookPaymentStatus =
  | Succeeded
  | Failed
  | Cancelled
  | CancelledPostCapture
  | Processing
  | PartiallyCapturedAndProcessing
  | RequiresCustomerAction
  | RequiresMerchantAction
  | RequiresCapture
  | PartiallyCaptured
  | PartiallyCapturedAndCapturable
  | PartiallyAuthorizedAndRequiresCapture
  | Conflicted
  | Expired

type webhookRefundStatus =
  | Failure
  | Success

type webhookPayoutStatus =
  | PayoutSuccess
  | PayoutFailed
  | PayoutCancelled
  | Initiated
  | PayoutExpired
  | Reversed
