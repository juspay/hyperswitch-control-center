type revenueRecoverySections = [
  | #chooseDataSource
  | #connectProcessor
  | #addAPlatform
  | #reviewDetails
]

type revenueRecoverySubsections = [
  | #selectProcessor
  | #activePaymentMethods
  | #setupWebhookProcessor
  | #selectAPlatform
  | #configureRetries
  | #connectProcessor
  | #setupWebhookPlatform
]
