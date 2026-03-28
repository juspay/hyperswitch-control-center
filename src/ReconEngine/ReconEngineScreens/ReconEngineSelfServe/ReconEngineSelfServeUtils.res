open ReconEngineSelfServeTypes

// Helper to create a controlled SelectBox input for local state
// For single-select (allowMultiSelect=false, the default):
//   - Display: reads value->JSON.Decode.string to find the label
//   - onChange: receives the selected string via %identity cast (BaseRadio path)
// The value must be a JSON string for display, and onChange receives a plain string
let makeControlledSelectInput = (
  ~name: string,
  ~value: string,
  ~setValue: (string => string) => unit,
): ReactFinalForm.fieldRenderPropsInput => {
  name,
  onBlur: _ => (),
  onChange: ev => {
    // For single-select, SelectBox calls onChange with a string via %identity cast
    let selected = ev->Identity.genericTypeToJson->JSON.Decode.string->Option.getOr("")
    setValue(_ => selected)
  },
  onFocus: _ => (),
  value: value->JSON.Encode.string,
  checked: true,
}

// Read-only SelectBox input — for display only
let makeReadOnlySelectInput = (
  ~name: string,
  ~value: string,
): ReactFinalForm.fieldRenderPropsInput => {
  name,
  onBlur: _ => (),
  onChange: _ => (),
  onFocus: _ => (),
  value: value->JSON.Encode.string,
  checked: true,
}

let inputClassName = "w-full px-3 py-2 text-sm border border-nd_gray-200 rounded-lg focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-400 placeholder:text-nd_gray-300"

let innerInputClassName = "w-full px-2.5 py-1.5 text-sm border border-nd_gray-200 rounded-lg focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-400 placeholder:text-nd_gray-300"

let emptyWizardState: wizardState = {
  accounts: [],
  ingestions: [],
  transformations: [],
  rules: [],
}

let stepToString = (step: selfServeStep): string => {
  switch step {
  | AccountStep => "account"
  | IngestionStep => "ingestion"
  | TransformationStep => "transformation"
  | RuleStep => "rule"
  | CompleteStep => "complete"
  }
}

let stepToDisplayName = (step: selfServeStep): string => {
  switch step {
  | AccountStep => "Create Accounts"
  | IngestionStep => "Configure Ingestion"
  | TransformationStep => "Set Up Transformation"
  | RuleStep => "Define Recon Rules"
  | CompleteStep => "Complete"
  }
}

let stepToDescription = (step: selfServeStep): string => {
  switch step {
  | AccountStep => "Create credit and debit accounts to track your financial data sources"
  | IngestionStep => "Configure how data flows into the recon engine from your sources"
  | TransformationStep => "Map your CSV columns to recon engine fields and define the metadata schema"
  | RuleStep => "Define how the engine matches and reconciles entries between accounts"
  | CompleteStep => "Your reconciliation setup is complete"
  }
}

let stepToIndex = (step: selfServeStep): int => {
  switch step {
  | AccountStep => 0
  | IngestionStep => 1
  | TransformationStep => 2
  | RuleStep => 3
  | CompleteStep => 4
  }
}

let indexToStep = (index: int): selfServeStep => {
  switch index {
  | 0 => AccountStep
  | 1 => IngestionStep
  | 2 => TransformationStep
  | 3 => RuleStep
  | _ => CompleteStep
  }
}

// ============================================================
// JSON ENCODERS — for create API payloads
// ============================================================

// --- Account Create ---
let encodeAccountCreate = (
  ~accountName: string,
  ~accountType: string,
  ~currency: string,
  ~initialBalance: float,
) => {
  [
    ("account_name", accountName->JSON.Encode.string),
    ("account_type", accountType->JSON.Encode.string),
    ("currency", currency->JSON.Encode.string),
    ("initial_balance", initialBalance->JSON.Encode.float),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

// --- Ingestion Config Create ---
let encodeIngestionConfigCreate = (
  ~merchantId: string,
  ~profileId: string,
  ~name: string,
  ~accountId: string,
  ~configVariant: ingestionConfigVariant,
  ~hmacSecret: string="",
  ~webhookUsername: string="",
  ~webhookPassword: string="",
  ~reportUsername: string="",
  ~reportPassword: string="",
  ~sftpFilePath: string="",
) => {
  // IngestionConfigData is EXTERNALLY tagged: {"manual": null}, {"adyen": {...}}, {"sftp_internal": {...}}
  let configJson = switch configVariant {
  | Manual => [("manual", JSON.Encode.null)]->Dict.fromArray->JSON.Encode.object
  | Adyen =>
    [
      (
        "adyen",
        [
          ("hmac_secret", hmacSecret->JSON.Encode.string),
          ("webhook_basic_auth_username", webhookUsername->JSON.Encode.string),
          ("webhook_basic_auth_password", webhookPassword->JSON.Encode.string),
          ("report_basic_auth_username", reportUsername->JSON.Encode.string),
          ("report_basic_auth_password", reportPassword->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  | SftpInternal =>
    [
      (
        "sftp_internal",
        [("file_path", sftpFilePath->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

  [
    ("merchant_id", merchantId->JSON.Encode.string),
    ("profile_id", profileId->JSON.Encode.string),
    ("name", name->JSON.Encode.string),
    ("account_id", accountId->JSON.Encode.string),
    ("config", configJson),
    ("is_active", true->JSON.Encode.bool),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

// --- Transformation Config V2 Create ---

let delimiterToString = (d: delimiter): string => {
  switch d {
  | Colon => "colon"
  | Slash => "slash"
  | Hyphen => "hyphen"
  | Dot => "dot"
  | Comma => "comma"
  | Space => "space"
  | NoDelimiter => "none"
  }
}

let dateOrderToString = (d: dateOrder): string => {
  switch d {
  | DayMonthYear => "day_month_year"
  | MonthDayYear => "month_day_year"
  | YearMonthDay => "year_month_day"
  }
}

let processingModeToString = (p: processingMode): string => {
  switch p {
  | Transaction => "transaction"
  | Confirmation => "confirmation"
  }
}

let unitTypeToString = (u: unitType): string => {
  switch u {
  | MajorUnit => "major_unit"
  | MinorUnit => "minor_unit"
  }
}

let stringToDelimiter = (s: string): delimiter => {
  switch s {
  | "colon" => Colon
  | "slash" => Slash
  | "hyphen" => Hyphen
  | "dot" => Dot
  | "comma" => Comma
  | "space" => Space
  | _ => NoDelimiter
  }
}

let stringToDateOrder = (s: string): dateOrder => {
  switch s {
  | "day_month_year" => DayMonthYear
  | "month_day_year" => MonthDayYear
  | _ => YearMonthDay
  }
}

let stringToProcessingMode = (s: string): processingMode => {
  switch s {
  | "confirmation" => Confirmation
  | _ => Transaction
  }
}

let stringToUnitType = (s: string): unitType => {
  switch s {
  | "minor_unit" => MinorUnit
  | _ => MajorUnit
  }
}

let stringToIngestionConfigVariant = (s: string): ingestionConfigVariant => {
  switch s {
  | "adyen" => Adyen
  | "sftp_internal" => SftpInternal
  | _ => Manual
  }
}

let encodeAmountConfig = (
  ~identifier: string,
  ~unitType: unitType,
  ~amountDelimiter: delimiter,
) => {
  // AmountSchemaConfig has #[serde(flatten)] on unit_config
  // So identifier + unit_type + delimiter all at same level
  let base = [
    ("identifier", identifier->JSON.Encode.string),
    ("unit_type", unitType->unitTypeToString->JSON.Encode.string),
    ("validation_rules", []->JSON.Encode.array),
  ]

  let withDelimiter = switch unitType {
  | MajorUnit =>
    base->Array.concat([("delimiter", amountDelimiter->delimiterToString->JSON.Encode.string)])
  | MinorUnit => base
  }

  withDelimiter->Dict.fromArray->JSON.Encode.object
}

let encodeDateTimeFormat = (~dateOrd: dateOrder, ~dateDelim: delimiter) => {
  [
    (
      "date_format",
      [
        ("order", dateOrd->dateOrderToString->JSON.Encode.string),
        ("delimiter", dateDelim->delimiterToString->JSON.Encode.string),
      ]
      ->Dict.fromArray
      ->JSON.Encode.object,
    ),
    ("time_format", JSON.Encode.null),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeEffectiveAtConfig = (~identifier: string, ~dateOrd: dateOrder, ~dateDelim: delimiter) => {
  [
    ("identifier", identifier->JSON.Encode.string),
    ("date_time_format", encodeDateTimeFormat(~dateOrd, ~dateDelim)),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeBalanceDirectionConfig = (
  ~identifier: string,
  ~creditValues: array<string>,
  ~debitValues: array<string>,
) => {
  [
    ("identifier", identifier->JSON.Encode.string),
    ("credit_values", creditValues->Array.map(JSON.Encode.string)->JSON.Encode.array),
    ("debit_values", debitValues->Array.map(JSON.Encode.string)->JSON.Encode.array),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeCurrencyConfig = (~identifier: string) => {
  [("identifier", identifier->JSON.Encode.string)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeOrderIdConfig = (~identifier: string) => {
  [("identifier", identifier->JSON.Encode.string), ("transformation_rules", []->JSON.Encode.array)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeMetadataField = (field: metadataFieldFormState) => {
  // MetadataFieldSchemaConfig has #[serde(flatten)] on field_config (FieldType)
  // So field_type tag appears at same level as identifier, field_name, etc.
  [
    ("identifier", field.identifier->JSON.Encode.string),
    ("field_name", field.fieldName->JSON.Encode.string),
    ("field_type", field.fieldType->JSON.Encode.string),
    ("validation_rules", []->JSON.Encode.array),
    ("transformation_rules", []->JSON.Encode.array),
    ("required", field.required->JSON.Encode.bool),
    ("description", field.description->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeUniqueConstraint = (~fieldName: string, ~description: string) => {
  [
    (
      "constraint_type",
      [
        ("unique_constraint_type", "single_field"->JSON.Encode.string),
        ("field_name", fieldName->JSON.Encode.string),
      ]
      ->Dict.fromArray
      ->JSON.Encode.object,
    ),
    ("description", description->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeMetadataSchemaData = (form: transformationFormState) => {
  // MetadataSchemaData is INTERNALLY tagged with schema_type
  // schema_type appears at same level as fields, unique_constraint, processing_mode
  let fieldsJson =
    [
      ("currency", encodeCurrencyConfig(~identifier=form.currencyIdentifier)),
      (
        "amount",
        encodeAmountConfig(
          ~identifier=form.amountIdentifier,
          ~unitType=form.amountUnitType,
          ~amountDelimiter=form.amountDelimiter,
        ),
      ),
      (
        "effective_at",
        encodeEffectiveAtConfig(
          ~identifier=form.effectiveAtIdentifier,
          ~dateOrd=form.dateOrder,
          ~dateDelim=form.dateDelimiter,
        ),
      ),
      (
        "balance_direction",
        encodeBalanceDirectionConfig(
          ~identifier=form.balanceDirectionIdentifier,
          ~creditValues=form.creditValues,
          ~debitValues=form.debitValues,
        ),
      ),
      ("order_id", encodeOrderIdConfig(~identifier=form.orderIdIdentifier)),
      ("metadata_fields", form.metadataFields->Array.map(encodeMetadataField)->JSON.Encode.array),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object

  [
    ("schema_type", "basic_schema_data"->JSON.Encode.string),
    ("processing_mode", form.processingMode->processingModeToString->JSON.Encode.string),
    ("fields", fieldsJson),
    (
      "unique_constraint",
      encodeUniqueConstraint(
        ~fieldName=form.uniqueConstraintField,
        ~description=form.uniqueConstraintDescription,
      ),
    ),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeTransformationConfigCreate = (
  ~form: transformationFormState,
  ~merchantId: string,
  ~profileId: string,
) => {
  let configJson =
    [
      ("merchant_id", merchantId->JSON.Encode.string),
      ("profile_id", profileId->JSON.Encode.string),
      ("account_id", form.accountId->JSON.Encode.string),
      (
        "parsing_config",
        [("file_format", "csv"->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object

  [
    ("ingestion_id", form.ingestionId->JSON.Encode.string),
    ("account_id", form.accountId->JSON.Encode.string),
    ("name", form.name->JSON.Encode.string),
    ("metadata_schema_data", encodeMetadataSchemaData(form)),
    ("config", configJson),
    ("is_active", true->JSON.Encode.bool),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

// --- Recon Rule Create ---

let encodeOperator = (~value: string) => {
  [("operator_version", "v1"->JSON.Encode.string), ("value", value->JSON.Encode.string)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeTrigger = (~field: string, ~operatorValue: string, ~triggerValue: string) => {
  [
    ("trigger_version", "v1"->JSON.Encode.string),
    ("field", field->JSON.Encode.string),
    ("operator", encodeOperator(~value=operatorValue)),
    ("value", triggerValue->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeSearchIdentifier = (~sourceField: string, ~targetField: string) => {
  [
    ("search_version", "v1"->JSON.Encode.string),
    ("source_field", sourceField->JSON.Encode.string),
    ("target_field", targetField->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeMatchRule = (rule: ReconEngineRulesTypes.matchRuleType) => {
  [
    ("source_field", rule.source_field->JSON.Encode.string),
    ("target_field", rule.target_field->JSON.Encode.string),
    ("operator", rule.operator->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeMatchRules = (rules: array<ReconEngineRulesTypes.matchRuleType>) => {
  [
    ("match_version", "v1"->JSON.Encode.string),
    ("rules", rules->Array.map(encodeMatchRule)->JSON.Encode.array),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeAgingConfig = (~enabled: bool, ~thresholdDays: int) => {
  if enabled {
    [
      ("aging_config_type", "with_threshold"->JSON.Encode.string),
      (
        "threshold",
        [
          ("threshold_type", "week_days"->JSON.Encode.string),
          ("value", thresholdDays->Int.toFloat->JSON.Encode.float),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  } else {
    [("aging_config_type", "no_aging"->JSON.Encode.string)]
    ->Dict.fromArray
    ->JSON.Encode.object
  }
}

let oneToOneSubtypeToString = (s: oneToOneSubtype): string => {
  switch s {
  | SingleSingle => "single_single"
  | SingleMany => "single_many"
  | ManySingle => "many_single"
  | ManyMany => "many_many"
  }
}

let encodeReconStrategy = (form: ruleFormState) => {
  // ReconStrategy and OneToOneStrategy are BOTH internally tagged
  // All tags and struct fields flatten to the SAME level
  let sourceAccount = {
    let base = [
      ("account_id", form.sourceAccountId->JSON.Encode.string),
      (
        "trigger",
        encodeTrigger(
          ~field=form.triggerField,
          ~operatorValue=form.triggerOperator,
          ~triggerValue=form.triggerValue,
        ),
      ),
    ]

    let withGrouping = switch form.oneToOneSubtype {
    | ManySingle | ManyMany =>
      base->Array.concat([("grouping_field", form.groupingField->JSON.Encode.string)])
    | _ => base
    }

    withGrouping->Dict.fromArray->JSON.Encode.object
  }

  let targetAccount =
    [("account_id", form.targetAccountId->JSON.Encode.string)]
    ->Dict.fromArray
    ->JSON.Encode.object

  // All fields at same flat level due to internal tagging
  [
    ("recon_strategy_type", "one_to_one"->JSON.Encode.string),
    ("one_to_one_type", form.oneToOneSubtype->oneToOneSubtypeToString->JSON.Encode.string),
    (
      "search_identifier",
      encodeSearchIdentifier(
        ~sourceField=form.searchSourceField,
        ~targetField=form.searchTargetField,
      ),
    ),
    ("match_rules", encodeMatchRules(form.matchRules)),
    ("source_account", sourceAccount),
    ("target_account", targetAccount),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeReconRuleCreate = (form: ruleFormState) => {
  [
    ("rule_name", form.ruleName->JSON.Encode.string),
    ("rule_description", form.ruleDescription->JSON.Encode.string),
    ("priority", form.priority->Int.toFloat->JSON.Encode.float),
    ("strategy", encodeReconStrategy(form)),
    (
      "aging_config",
      encodeAgingConfig(~enabled=form.agingEnabled, ~thresholdDays=form.agingThresholdDays),
    ),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

// --- Dropdown helpers ---

let accountTypeOptions: array<SelectBox.dropdownOption> = [
  {label: "Credit", value: "credit"},
  {label: "Debit", value: "debit"},
]

let processingModeOptions: array<SelectBox.dropdownOption> = [
  {label: "Transaction (creates expected entries)", value: "transaction"},
  {label: "Confirmation (matches existing entries)", value: "confirmation"},
]

let unitTypeOptions: array<SelectBox.dropdownOption> = [
  {label: "Major Unit (e.g. 10.50)", value: "major_unit"},
  {label: "Minor Unit (e.g. 1050)", value: "minor_unit"},
]

let delimiterOptions: array<SelectBox.dropdownOption> = [
  {label: "Dot (.)", value: "dot"},
  {label: "Comma (,)", value: "comma"},
  {label: "Hyphen (-)", value: "hyphen"},
  {label: "Slash (/)", value: "slash"},
  {label: "Colon (:)", value: "colon"},
  {label: "Space ( )", value: "space"},
  {label: "None", value: "none"},
]

let dateOrderOptions: array<SelectBox.dropdownOption> = [
  {label: "YYYY-MM-DD", value: "year_month_day"},
  {label: "DD-MM-YYYY", value: "day_month_year"},
  {label: "MM-DD-YYYY", value: "month_day_year"},
]

let oneToOneSubtypeOptions: array<SelectBox.dropdownOption> = [
  {label: "Single to Single — One source entry matches one target entry", value: "single_single"},
  {label: "Single to Many — One source matches multiple targets", value: "single_many"},
  {label: "Many to Single — Multiple sources match one target", value: "many_single"},
  {label: "Many to Many — Multiple sources match multiple targets", value: "many_many"},
]

let operatorOptions: array<SelectBox.dropdownOption> = [
  {label: "Equals", value: "equals"},
  {label: "Not Equals", value: "not_equals"},
]

let entryFieldOptions: array<SelectBox.dropdownOption> = [
  {label: "Amount", value: "amount"},
  {label: "Currency", value: "currency"},
  {label: "Effective At (Date)", value: "effective_at"},
  {label: "Order ID", value: "order_id"},
  {label: "Entry Type", value: "entry_type"},
]

let metadataFieldTypeOptions: array<SelectBox.dropdownOption> = [
  {label: "String", value: "string"},
  {label: "Number", value: "number"},
  {label: "Currency", value: "currency"},
]

let currencyOptions: array<
  SelectBox.dropdownOption,
> = CurrencyUtils.currencyList->Array.map(currency => {
  let code = currency->CurrencyUtils.getCurrencyCodeStringFromVariant
  {SelectBox.label: code, value: code}
})
