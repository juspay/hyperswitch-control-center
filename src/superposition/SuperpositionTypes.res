type dimensionEntity =
  | OrganizationId
  | ProcessorMerchantId
  | ProviderMerchantId
  | ProfileID

type keyOwnership = Owned | Managed

type valueKind =
  | BoolValue
  | IntegerValue
  | NumberValue
  | StringValue
  | EnumValue(array<string>)
  | StringListValue(array<string>)
  | JsonValue

type defaultConfig = {
  key: string,
  value: JSON.t,
  schema: Dict.t<JSON.t>,
  description: string,
}

type dimension = {
  name: string,
  position: int,
  schema: Dict.t<JSON.t>,
  description: string,
}

type context = {
  id: string,
  condition: Dict.t<JSON.t>,
  override: Dict.t<JSON.t>,
  weight: float,
  description: string,
  changeReason: string,
  lastModifiedAt: string,
  lastModifiedBy: string,
}

type resolvedEntry = {resolvedValue: JSON.t}

type specialization = {
  context: context,
  extraConditions: Dict.t<JSON.t>,
}

type configRow = {
  key: string,
  description: string,
  kind: valueKind,
  value: JSON.t,
  inheritedValue: JSON.t,
  defaultValue: JSON.t,
  ownership: keyOwnership,
  thisLevelContext: option<context>,
}

type explainStep = {
  stepContextId: string,
  stepCondition: Dict.t<JSON.t>,
  valueBefore: JSON.t,
  valueAfter: JSON.t,
}

type auditLog = {
  auditId: string,
  tableName: string,
  userName: string,
  timestamp: string,
  action: string,
  originalData: option<JSON.t>,
  newData: option<JSON.t>,
}

type auditValueChange = {
  changedKey: string,
  before: option<JSON.t>,
  after: option<JSON.t>,
}

type configsData = {
  defaults: array<defaultConfig>,
  dimensions: array<dimension>,
  contexts: array<context>,
  resolved: option<Dict.t<resolvedEntry>>,
}

// Default: nothing changed it. Updated: it differs from the default because a broader level
// changed it. Custom: set at this level.
type valueStatus =
  | DefaultStatus
  | UpdatedStatus
  | CustomStatus

type keyPath = {
  namespace: string,
  groupPath: array<string>,
  leaf: string,
}

type segmentTab = {
  label: string,
  tabRows: array<configRow>,
  depth: int,
}

type configColType =
  | KeyCol
  | ValueCol
  | StatusCol
  | ActionsCol

type specializationEntry = {
  entryRow: configRow,
  spec: specialization,
  rank: int,
}

type specializationGroup = {
  groupRow: configRow,
  entries: array<specializationEntry>,
}

type specializationColType =
  | RankCol
  | ConditionsCol
  | SpecializedValueCol
  | LastModifiedCol
  | SpecializationActionsCol

type auditColType =
  | TimestampCol
  | AuditActionCol
  | AuditTableCol
  | UserCol
  | ChangedKeysCol
