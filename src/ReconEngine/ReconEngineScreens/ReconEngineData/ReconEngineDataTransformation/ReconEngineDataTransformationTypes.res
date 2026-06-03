@unboxed
type transformationConfigLabel =
  | @as("Transformation ID") TransformationId
  | @as("Ingestion ID") IngestionId
  | @as("Last Transformed At") LastTransformedAt
  | @as("Status") Status

type transformationConfigDataType = {
  label: transformationConfigLabel,
  value: string,
  valueType: [#text | #date | #status],
}

@unboxed
type basicFieldType =
  | @as("currency") Currency
  | @as("amount") Amount
  | @as("effective_at") EffectiveAt
  | @as("balance_direction") BalanceDirection
  | @as("order_id") OrderId
