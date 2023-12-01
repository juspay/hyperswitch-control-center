type routingType = SINGLE | PRIORITY | VOLUME_SPLIT | ADVANCED | COST | DEFAULTFALLBACK | NO_ROUTING
type modalValue = {conType: string, conText: React.element}
type routingValueType = {heading: string, subHeading: string}
type modalObj = (routingType, string) => modalValue
type colType =
  | Name
  | Description
  | Status
  | ConfigType
  | DateCreated
  | LastUpdated

type status = ACTIVE | APPROVED | PENDING | REJECTED
type configType = RuleBased | CodeBased
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
type variantType = Number | Enum_variant | Metadata_value | String_value | UnknownVariant(string)
type logicalOperator = AND | OR | UnknownLogicalOperator(string)
type val = StringArray(array<string>) | String(string) | Int(int)
type logic = {
  id: string,
  name: string,
  description: string,
  isActiveLogic: bool,
  status: status,
  configType: configType,
  version: string,
  priorityLogic: string,
  priorityLogicRules: string,
  dateCreated: string,
  lastUpdated: string,
}
type response = {
  useCode: bool,
  gatewayPriority: string,
  gatewayPriorityLogic: string,
  logics: array<logic>,
}
type wasmModule = {
  getAllKeys: unit => array<string>,
  getKeyType: string => string,
  getAllConnectors: unit => array<string>,
  getVariantValues: string => array<string>,
}
type gateway = {
  distribution: int,
  disableFallback: bool,
  gateway_name: string,
}
type volumeDistribution = {
  connector: string,
  split: int,
}
type pageState = Preview | Create | Edit
type condition = {
  field: string,
  metadata?: Js.Json.t,
  operator: operator,
  value: val,
  logicalOperator: logicalOperator,
}
type routingOutputType = {override_3ds: string}
type rule = {
  gateways: array<gateway>,
  conditions: array<condition>,
  routingOutput?: routingOutputType,
}
type ruleInfoType = {
  rules: array<rule>,
  default_gateways: array<string>,
}

type gateWAY = {gateways: array<gateway>}
type volumeDistributionType = {volumeBasedDistribution: gateWAY}
type ruleDict = {json: volumeDistributionType}

type historyColType =
  | Name
  | Type
  | ProfileId
  | ProfileName
  | Description
  | Created
  | LastUpdated
  | Status

type historyData = {
  id: string,
  name: string,
  profile_id: string,
  kind: string,
  description: string,
  modified_at: string,
  created_at: string,
}

type value = {"type": Js.Json.t, "value": Js.Json.t}
type payloadCondition = {
  lhs: string,
  comparison: string,
  value: value,
  metadata: Js.Json.t,
}
