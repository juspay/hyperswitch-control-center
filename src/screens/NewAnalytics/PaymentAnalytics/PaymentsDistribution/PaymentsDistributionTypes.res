type queryData = PaymentsSuccessRate | Connector

type categories = [#connector]

type paymentsDistributionObject = {
  payments_success_rate: int,
  connector: string,
}
