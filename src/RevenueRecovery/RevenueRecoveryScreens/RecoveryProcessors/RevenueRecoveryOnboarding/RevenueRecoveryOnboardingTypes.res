type revenueRecoverySections = [
  | #chooseDataSource
  | #connectProcessor
  | #addAPlatform
  | #reviewDetails
]

type revenueRecoverySubsections = [
  | #selectProcessor
  | #authenticateProcessor
  | #activePaymentMethods
  | #selectAPlatform
  | #authenticateBilling
  | #processorSetUp
]

type feature = {
  icon: string,
  bgColor: string,
  iconColor: string,
  title: string,
  description: string,
}
