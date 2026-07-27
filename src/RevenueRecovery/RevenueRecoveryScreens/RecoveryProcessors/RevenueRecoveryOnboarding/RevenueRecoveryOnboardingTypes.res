type revenueRecoverySections = [
  | #chooseDataSource
  | #connectProcessor
  | #addAPlatform
  | #reviewDetails
]

type revenueRecoverySubsections = [
  | #selectProcessor
  | #activePaymentMethods
  | #selectAPlatform
  | #processorSetUp
]

type feature = {
  icon: string,
  bgColor: string,
  iconColor: string,
  title: string,
  description: string,
}
