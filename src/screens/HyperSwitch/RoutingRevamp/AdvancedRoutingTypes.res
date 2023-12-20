type routing = SINGLE | PRIORITY | VOLUME_SPLIT | ADVANCED | COST | DEFAULTFALLBACK | NO_ROUTING
type variantType = Number | Enum_variant | Metadata_value | String_value | UnknownVariant(string)
type pageState = Preview | Create | Edit
type formState = CreateConfig | EditConfig | EditReplica | ViewConfig

type operator =
  | IS
  | IS_NOT
  | GREATER_THAN
  | LESS_THAN
  | EQUAL_TO
  | CONTAINS
  | NOT_CONTAINS
  | NOT_EQUAL_TO
  | UnknownOperator(string)

type connector = {
  connector: string,
  merchant_connector_id: string,
}

type volumeSplitConnectorSelectionData = {
  split: int,
  connector: connector,
}

type priorityConnectorSelectionData = {connector: connector}

type connectorSelectionData =
  | VolumeObject(volumeSplitConnectorSelectionData)
  | PriorityObject(connector)

type value = {\"type": string, value: Js.Json.t}

type surchargeDetailsSurchargePropertyValueType = {percentage?: float, amount?: float}

type surchargeDetailsSurchargePropertyType = {
  \"type": string,
  value: surchargeDetailsSurchargePropertyValueType,
}

type surchargeDetailsType = {
  surcharge: surchargeDetailsSurchargePropertyType,
  tax_on_surcharge: surchargeDetailsSurchargePropertyValueType,
}

type connectorSelection = {
  \"type"?: string,
  data?: array<connectorSelectionData>,
  override_3ds?: string,
  surcharge_details?: Js.nullable<surchargeDetailsType>,
}

type statement = {
  lhs: string,
  comparison: string,
  value: value,
  logical?: string,
  metadata?: Js.Json.t,
}

type rule = {
  name: string,
  connectorSelection: connectorSelection,
  statements: array<statement>,
}

type algorithmData = {
  defaultSelection: connectorSelection,
  rules: array<rule>,
  metadata: Js.Json.t,
}

type algorithm = {data: algorithmData, \"type"?: string}

type advancedRouting = {
  name: string,
  description: string,
  algorithm: algorithm,
}

type modalValue = {conType: string, conText: React.element}

type statementSendType = {condition: array<statement>}
