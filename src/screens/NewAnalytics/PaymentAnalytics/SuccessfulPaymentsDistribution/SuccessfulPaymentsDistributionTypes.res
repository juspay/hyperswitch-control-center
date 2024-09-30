type queryData = PaymentsSuccessRate | Connector | PaymentMethod

type successfulPaymentsDistributionObject = {
  payments_success_rate: int,
  connector: string,
  payment_method: string,
}
