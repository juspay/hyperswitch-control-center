// ============================================================
// Self-Serve Create Request Types
// These types mirror backend API request structs exactly.
// ============================================================

// --- Account ---
type accountCreateRequest = {
  account_name: string,
  account_type: string, // "credit" | "debit"
  currency: string, // ISO 4217 e.g. "USD", "MYR"
  initial_balance: float,
}

// --- Ingestion Config ---
type adyenConfig = {
  hmac_secret: string,
  webhook_basic_auth_username: string,
  webhook_basic_auth_password: string,
  report_basic_auth_username: string,
  report_basic_auth_password: string,
}

type sftpInternalConfig = {file_path: string}

type ingestionConfigVariant =
  | Manual
  | Adyen(adyenConfig)
  | SftpInternal(sftpInternalConfig)

type ingestionConfigCreateRequest = {
  merchant_id: string,
  profile_id: string,
  name: string,
  description: option<string>,
  account_id: string,
  config: ingestionConfigVariant,
  is_active: bool,
}

// --- Transformation Config ---

// Amount unit config
type amountDelimiter = Dot | Comma

type amountUnitType = MinorUnit | MajorUnit(amountDelimiter)

// Validation rules (tagged enums)
type stringValidationRule = MaxLength(int) | MinLength(int)
type stringTransformationRule = ToUpperCase | ToLowerCase | StripPrefix(string) | StripSuffix(string)
type numberValidationRule = NumberMinValue(float) | NumberMaxValue(float)
type minorUnitValidationRule = MinorPositiveOnly | MinorMinValue(int) | MinorMaxValue(int)
type majorUnitValidationRule = MajorPositiveOnly | MajorMinValue(float) | MajorMaxValue(float)

// Date/time
type dateOrder = DayMonthYear | MonthDayYear | YearMonthDay | YearDayMonth

type delimiter = Colon | Slash | Hyphen | DelimiterDot | Space | DelimiterNone

type timeOrder =
  | TwentyFourHourWithSeconds
  | TwentyFourHourWithoutSeconds
  | TwelveHourWithSeconds
  | TwelveHourWithoutSeconds

type dateFormatConfig = {
  order: dateOrder,
  delimiter: delimiter,
}

type timeFormatConfig = {
  order: timeOrder,
  delimiter: delimiter,
  separator_from_date: delimiter,
}

type dateTimeFormat = {
  date_format: dateFormatConfig,
  time_format: option<timeFormatConfig>,
}

// Field types for metadata fields
type fieldTypeVariant =
  | StringFieldType({
      validation_rules: array<stringValidationRule>,
      transformation_rules: array<stringTransformationRule>,
    })
  | NumberFieldType({validation_rules: array<numberValidationRule>})
  | CurrencyFieldType
  | MinorUnitFieldType({validation_rules: array<minorUnitValidationRule>})
  | MajorUnitFieldType({delimiter: amountDelimiter, validation_rules: array<majorUnitValidationRule>})
  | DateTimeFieldType({date_time_format: dateTimeFormat})
  | BalanceDirectionFieldType({credit_values: array<string>, debit_values: array<string>})
  | EnumFieldType({mappings: Dict.t<string>})

// Metadata field schema config
type metadataFieldSchemaConfig = {
  identifier: string,
  field_name: string, // EntryField serialized as string: "metadata.xxx"
  field_type: fieldTypeVariant,
  required: bool,
  description: string,
}

// Required field configs
type currencySchemaConfig = {identifier: string}

type amountSchemaConfig = {
  identifier: string,
  unit_type: amountUnitType,
  validation_rules_minor: array<minorUnitValidationRule>,
  validation_rules_major: array<majorUnitValidationRule>,
}

type effectiveAtSchemaConfig = {
  identifier: string,
  date_time_format: dateTimeFormat,
}

type balanceDirectionSchemaConfig = {
  identifier: string,
  credit_values: array<string>,
  debit_values: array<string>,
}

type orderIdSchemaConfig = {
  identifier: string,
  transformation_rules: array<stringTransformationRule>,
}

// Unique constraint
type uniqueConstraintType = SingleField(string) // EntryField as string

type uniqueConstraint = {
  constraint_type: uniqueConstraintType,
  description: string,
}

// Processing mode
type processingMode = Transaction | Confirmation

// Fields config
type fieldsConfig = {
  currency: currencySchemaConfig,
  amount: amountSchemaConfig,
  effective_at: effectiveAtSchemaConfig,
  balance_direction: balanceDirectionSchemaConfig,
  order_id: orderIdSchemaConfig,
  metadata_fields: array<metadataFieldSchemaConfig>,
}

// Full metadata schema data
type metadataSchemaData = {
  fields: fieldsConfig,
  unique_constraint: uniqueConstraint,
  processing_mode: processingMode,
}

// Transformation config V2
type transformationConfigV2 = {
  merchant_id: string,
  profile_id: string,
  account_id: string,
}

// Create transformation config request
type createTransformationConfigRequest = {
  ingestion_id: string,
  account_id: string,
  name: string,
  metadata_schema_data: metadataSchemaData,
  config: transformationConfigV2,
  is_active: bool,
}

// --- Recon Rule ---

// Trigger
type basicComparisonOperator = Equals | NotEquals

type triggerCreateType = {
  field: string, // EntryField as string
  operator: basicComparisonOperator,
  value: string,
}

// Search identifier
type searchIdentifierCreateType = {
  source_field: string, // EntryField as string
  target_field: string,
}

// Match rules
type matchRuleCreateType = {
  source_field: string,
  target_field: string,
  operator: string, // "equals"
}

// Tolerance config
type toleranceConfigCreateType = {
  lower_tolerance: int,
  upper_tolerance: int,
  tolerance_account_id: string,
}

// OneToOne source/target types
type oneToOneSingleSingleSourceCreate = {
  account_id: string,
  trigger: triggerCreateType,
}

type oneToOneSingleSingleTargetCreate = {
  account_id: string,
  tolerance_config: option<toleranceConfigCreateType>,
}

type oneToOneSingleManySourceCreate = {
  account_id: string,
  trigger: triggerCreateType,
}

type oneToOneSingleManyTargetCreate = {account_id: string}

type oneToOneManySingleSourceCreate = {
  account_id: string,
  trigger: triggerCreateType,
  grouping_field: string, // EntryField
}

type oneToOneManySingleTargetCreate = {account_id: string}

type oneToOneManyManySourceCreate = {
  account_id: string,
  trigger: triggerCreateType,
  grouping_field: string,
}

type oneToOneManyManyTargetCreate = {account_id: string}

// OneToOne strategy variants
type oneToOneStrategyVariant =
  | SingleSingleCreate({
      search_identifier: searchIdentifierCreateType,
      match_rules: array<matchRuleCreateType>,
      source_account: oneToOneSingleSingleSourceCreate,
      target_account: oneToOneSingleSingleTargetCreate,
    })
  | SingleManyCreate({
      search_identifier: searchIdentifierCreateType,
      match_rules: array<matchRuleCreateType>,
      source_account: oneToOneSingleManySourceCreate,
      target_account: oneToOneSingleManyTargetCreate,
    })
  | ManySingleCreate({
      search_identifier: searchIdentifierCreateType,
      match_rules: array<matchRuleCreateType>,
      source_account: oneToOneManySingleSourceCreate,
      target_account: oneToOneManySingleTargetCreate,
    })
  | ManyManyCreate({
      search_identifier: searchIdentifierCreateType,
      match_rules: array<matchRuleCreateType>,
      source_account: oneToOneManyManySourceCreate,
      target_account: oneToOneManyManyTargetCreate,
    })

// OneToMany target
type oneToManySingleSingleTargetCreate = {
  search_identifier: searchIdentifierCreateType,
  match_rules: array<matchRuleCreateType>,
  account_id: string,
}

type percentageSplitValue = {value: float}

type fixedSplitValue = FixedAmount(int) | FixedRemaining

type oneToManySplitType =
  | PercentageSplit(array<(oneToManySingleSingleTargetCreate, percentageSplitValue)>)
  | FixedSplit(array<(oneToManySingleSingleTargetCreate, fixedSplitValue)>)

type oneToManyStrategyVariant =
  | OneToManySingleSingleCreate({
      source_account: oneToOneSingleSingleSourceCreate, // same shape: account_id + trigger
      target_accounts: oneToManySplitType,
    })

// Top-level strategy
type reconStrategyCreate =
  | OneToOneCreate(oneToOneStrategyVariant)
  | OneToManyCreate(oneToManyStrategyVariant)

// Aging config
type agingConfigCreate = NoAgingCreate | WithThresholdCreate({weekdays: int})

// Create recon rule request
type reconRuleCreateRequest = {
  rule_name: string,
  rule_description: string,
  priority: int,
  strategy: reconStrategyCreate,
  aging_config: agingConfigCreate,
}

// --- Wizard State ---
type selfServeStep =
  | AccountSetup
  | IngestionSetup
  | TransformationSetup
  | RuleSetup
  | Complete

type selfServeMode =
  | GuidedSetup
  | ExpertSetup

type createdAccount = {
  account_id: string,
  account_name: string,
  account_type: string,
  currency: string,
}

type createdIngestion = {
  ingestion_id: string,
  account_id: string,
  name: string,
  config_type: string,
}

type createdTransformation = {
  transformation_id: string,
  ingestion_id: string,
  account_id: string,
  name: string,
  metadata_fields: array<string>, // field names for use in rule builder
}

type selfServeState = {
  accounts: array<createdAccount>,
  ingestions: array<createdIngestion>,
  transformations: array<createdTransformation>,
}
