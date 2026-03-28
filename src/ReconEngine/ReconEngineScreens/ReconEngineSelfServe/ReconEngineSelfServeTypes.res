// Self-Serve specific types — only types that don't already exist in ReconEngineTypes.res or ReconEngineRulesTypes.res

type selfServeMode =
  | Guided
  | Expert

type selfServeStep =
  | AccountStep
  | IngestionStep
  | TransformationStep
  | RuleStep
  | CompleteStep

type createdAccount = {
  account_id: string,
  account_name: string,
  account_type: string,
}

type createdIngestion = {
  ingestion_id: string,
  account_id: string,
  name: string,
}

type createdTransformation = {
  transformation_id: string,
  account_id: string,
  ingestion_id: string,
  name: string,
}

type createdRule = {
  rule_id: string,
  rule_name: string,
}

// Wizard state — tracks what has been created so far
type wizardState = {
  accounts: array<createdAccount>,
  ingestions: array<createdIngestion>,
  transformations: array<createdTransformation>,
  rules: array<createdRule>,
}

// Ingestion config data variants for create payload
type ingestionConfigVariant =
  | Manual
  | Adyen
  | SftpInternal

// Date format options
type dateOrder =
  | DayMonthYear
  | MonthDayYear
  | YearMonthDay

type delimiter =
  | Colon
  | Slash
  | Hyphen
  | Dot
  | Comma
  | Space
  | NoDelimiter

type unitType =
  | MajorUnit
  | MinorUnit

type processingMode =
  | Transaction
  | Confirmation

// Metadata field form state
type metadataFieldFormState = {
  identifier: string,
  fieldName: string,
  fieldType: string,
  required: bool,
  description: string,
}

// Transformation form state
type transformationFormState = {
  name: string,
  accountId: string,
  ingestionId: string,
  processingMode: processingMode,
  currencyIdentifier: string,
  amountIdentifier: string,
  amountUnitType: unitType,
  amountDelimiter: delimiter,
  effectiveAtIdentifier: string,
  dateOrder: dateOrder,
  dateDelimiter: delimiter,
  balanceDirectionIdentifier: string,
  creditValues: array<string>,
  debitValues: array<string>,
  orderIdIdentifier: string,
  metadataFields: array<metadataFieldFormState>,
  uniqueConstraintField: string,
  uniqueConstraintDescription: string,
}

// Recon strategy subtype
type oneToOneSubtype =
  | SingleSingle
  | SingleMany
  | ManySingle
  | ManyMany

// Rule form state
type ruleFormState = {
  ruleName: string,
  ruleDescription: string,
  priority: int,
  oneToOneSubtype: oneToOneSubtype,
  sourceAccountId: string,
  targetAccountId: string,
  triggerField: string,
  triggerOperator: string,
  triggerValue: string,
  searchSourceField: string,
  searchTargetField: string,
  matchRules: array<ReconEngineRulesTypes.matchRuleType>,
  groupingField: string,
  agingEnabled: bool,
  agingThresholdDays: int,
}
