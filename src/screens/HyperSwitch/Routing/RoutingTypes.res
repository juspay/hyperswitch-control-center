type routingType = SINGLE | PRIORITY | VOLUME_SPLIT | ADVANCED | COST | DEFAULTFALLBACK | NO_ROUTING
type formState = CreateConfig | EditConfig | ViewConfig
type status = ACTIVE | APPROVED | PENDING | REJECTED
type pageState = Preview | Create | Edit
type variantType = Number | Enum_variant | Metadata_value | String_value | UnknownVariant(string)
type logicalOperator = AND | OR | UnknownLogicalOperator(string)
type val = StringArray(array<string>) | String(string) | Int(int)

type historyColType =
  | Name
  | Type
  | ProfileId
  | ProfileName
  | Description
  | Created
  | LastUpdated
  | Status

type colType =
  | Name
  | Description
  | Status
  | ConfigType
  | DateCreated
  | LastUpdated

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

type modalValue = {conType: string, conText: React.element}
type routingValueType = {heading: string, subHeading: string}
type modalObj = (routingType, string) => modalValue

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

type routingOutputType = {override_3ds: string}

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
