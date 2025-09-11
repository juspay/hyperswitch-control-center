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
