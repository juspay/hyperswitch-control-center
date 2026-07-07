@unboxed
type operator =
  | @as("equal") Equal
  | @as("not_equal") NotEqual
  | @as("greater_than") GreaterThan
  | @as("less_than") LessThan
  | UnknownOperator(string)

@unboxed
type displayOperator =
  | @as("is") Is
  | @as("is_not") IsNot
  | @as("contains") Contains
  | @as("not_contains") NotContains
  | @as("equal") EqualTo
  | @as("not_equal") NotEqualTo
  | @as("greater_than") GreaterThanOp
  | @as("less_than") LessThanOp
  | UnknownDisplayOperator(string)

type metadataKV = {key: string, value: string}

@tag("type")
type value =
  | @as("number") Number({value: float})
  | @as("enum_variant") EnumOne({value: string})
  | @as("enum_variant_array") EnumMany({value: array<string>})
  | @as("str_value") StrValue({value: string})
  | @as("metadata_variant") MetadataValue({value: metadataKV})

type comparison = {
  lhs: string,
  comparison: operator,
  value: value,
  metadata: JSON.t,
}

type operatorChoice = {
  label: string,
  selectValue: displayOperator,
  comparison: operator,
  valueVariant: value,
}

type statement = {condition: array<comparison>}

type connectorRef = RoutingTypes.connector

type weightedConnector = {
  split: int,
  connector: connectorRef,
}

@tag("type")
type connectorSelection =
  | @as("priority") Priority({data: array<connectorRef>})
  | @as("volume_split") VolumeSplit({data: array<weightedConnector>})

type rule = {
  id: string,
  name: string,
  connectorSelection: connectorSelection,
  statements: array<statement>,
}

type algorithmData = {
  defaultSelection: connectorSelection,
  metadata: JSON.t,
  rules: array<rule>,
}

type algorithm = {
  \"type": string,
  data: algorithmData,
}

type config = {
  name: string,
  description: string,
  algorithm: algorithm,
}
