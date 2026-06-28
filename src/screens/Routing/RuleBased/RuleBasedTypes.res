type operator =
  | Equal
  | NotEqual
  | GreaterThan
  | LessThan
  | UnknownOperator(string)

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
  selectValue: string,
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
