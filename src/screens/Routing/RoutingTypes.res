type routingType = VOLUME_SPLIT | ADVANCED | DEFAULTFALLBACK | NO_ROUTING
type formState = CreateConfig | EditConfig | ViewConfig | EditReplica
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
  getAllPayoutKeys: unit => array<string>,
  getKeyType: string => string,
  getAllConnectors: unit => array<string>,
  getVariantValues: string => array<string>,
  getPayoutVariantValues: string => array<string>,
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

type value = {\"type": string, value: JSON.t}

type filterType =
  PaymentConnector | FRMPlayer | PayoutProcessor | PMAuthenticationProcessor | TaxProcessor

type workFlowTypes = Routing | PayoutRouting | ThreedsRouting | SurchargeRouting

type statement = {
  lhs: string,
  comparison: string,
  value: value,
  logical?: string,
  metadata?: JSON.t,
}

type connector = {
  connector: string,
  merchant_connector_id: string,
}

type volumeSplitConnectorSelectionData = {
  split: int,
  connector: connector,
}

type connectorSelectionData =
  | VolumeObject(volumeSplitConnectorSelectionData)
  | PriorityObject(connector)

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

type rule = {
  name: string,
  connectorSelection: connectorSelection,
  statements: array<statement>,
}

type algorithmData = {
  defaultSelection: connectorSelection,
  rules: array<rule>,
  metadata: JSON.t,
}

type algorithm = {data: algorithmData, \"type"?: string}

type advancedRouting = {
  name: string,
  description: string,
  algorithm: algorithm,
}

type statementSendType = {condition: array<statement>}

type advancedRoutingType = {
  name: string,
  description: string,
  algorithm: algorithmData,
}
