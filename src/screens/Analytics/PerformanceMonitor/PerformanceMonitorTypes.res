type performance = [#ConnectorPerformance | #PaymentMethodPerormance]
type dimension = [#connector | #payment_method | #payment_method_type | #status | #no_value]

type status = [#charged | #failure]
type metrics = [#payment_count]

type dimensionRecord = {
  dimension: dimension,
  values: array<string>,
}
type dimensions = array<dimensionRecord>
