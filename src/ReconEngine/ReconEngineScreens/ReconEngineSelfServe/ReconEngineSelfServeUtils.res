open ReconEngineSelfServeTypes

// ============================================================
// JSON Encoders - produce exact API payloads matching backend
// serde contracts. Every tag, flatten, and rename is handled.
// ============================================================

// --- Helpers ---
let encodeOptionalString = (value: option<string>): JSON.t =>
  switch value {
  | Some(v) => v->JSON.Encode.string
  | None => JSON.Encode.null
  }

let encodeOptionalObject = (value: option<JSON.t>): JSON.t =>
  switch value {
  | Some(v) => v
  | None => JSON.Encode.null
  }

// --- Account ---
let encodeAccountCreateRequest = (req: accountCreateRequest): JSON.t =>
  [
    ("account_name", req.account_name->JSON.Encode.string),
    ("account_type", req.account_type->JSON.Encode.string),
    ("currency", req.currency->JSON.Encode.string),
    ("initial_balance", req.initial_balance->JSON.Encode.float),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Ingestion Config ---
let encodeIngestionConfigData = (config: ingestionConfigVariant): JSON.t =>
  // IngestionConfigData is EXTERNALLY tagged with rename_all = "snake_case"
  switch config {
  | Manual =>
    [("manual", JSON.Encode.null)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | Adyen(adyen) =>
    [
      (
        "adyen",
        [
          ("hmac_secret", adyen.hmac_secret->JSON.Encode.string),
          ("webhook_basic_auth_username", adyen.webhook_basic_auth_username->JSON.Encode.string),
          ("webhook_basic_auth_password", adyen.webhook_basic_auth_password->JSON.Encode.string),
          ("report_basic_auth_username", adyen.report_basic_auth_username->JSON.Encode.string),
          ("report_basic_auth_password", adyen.report_basic_auth_password->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  | SftpInternal(sftp) =>
    [
      (
        "sftp_internal",
        [("file_path", sftp.file_path->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

let encodeIngestionConfigCreateRequest = (req: ingestionConfigCreateRequest): JSON.t => {
  let dict = [
    ("merchant_id", req.merchant_id->JSON.Encode.string),
    ("profile_id", req.profile_id->JSON.Encode.string),
    ("name", req.name->JSON.Encode.string),
    ("account_id", req.account_id->JSON.Encode.string),
    ("config", req.config->encodeIngestionConfigData),
    ("is_active", req.is_active->JSON.Encode.bool),
  ]->Dict.fromArray
  switch req.description {
  | Some(desc) => dict->Dict.set("description", desc->JSON.Encode.string)
  | None => ()
  }
  dict->JSON.Encode.object
}

// --- Delimiter ---
let encodeDelimiter = (d: delimiter): string =>
  switch d {
  | Colon => "colon"
  | Slash => "slash"
  | Hyphen => "hyphen"
  | DelimiterDot => "dot"
  | Space => "space"
  | DelimiterNone => "none"
  }

// --- DateTimeFormat ---
let encodeDateOrder = (order: dateOrder): string =>
  switch order {
  | DayMonthYear => "day_month_year"
  | MonthDayYear => "month_day_year"
  | YearMonthDay => "year_month_day"
  | YearDayMonth => "year_day_month"
  }

let encodeTimeOrder = (order: timeOrder): string =>
  switch order {
  | TwentyFourHourWithSeconds => "twenty_four_hour_with_seconds"
  | TwentyFourHourWithoutSeconds => "twenty_four_hour_without_seconds"
  | TwelveHourWithSeconds => "twelve_hour_with_seconds"
  | TwelveHourWithoutSeconds => "twelve_hour_without_seconds"
  }

let encodeDateFormatConfig = (config: dateFormatConfig): JSON.t =>
  [
    ("order", config.order->encodeDateOrder->JSON.Encode.string),
    ("delimiter", config.delimiter->encodeDelimiter->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

let encodeTimeFormatConfig = (config: timeFormatConfig): JSON.t =>
  [
    ("order", config.order->encodeTimeOrder->JSON.Encode.string),
    ("delimiter", config.delimiter->encodeDelimiter->JSON.Encode.string),
    ("separator_from_date", config.separator_from_date->encodeDelimiter->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

let encodeDateTimeFormat = (dtf: dateTimeFormat): JSON.t =>
  [
    ("date_format", dtf.date_format->encodeDateFormatConfig),
    (
      "time_format",
      switch dtf.time_format {
      | Some(tf) => tf->encodeTimeFormatConfig
      | None => JSON.Encode.null
      },
    ),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Validation / Transformation Rules ---
let encodeStringValidationRule = (rule: stringValidationRule): JSON.t =>
  switch rule {
  | MaxLength(v) =>
    [("validation_rule_type", "max_length"->JSON.Encode.string), ("value", v->JSON.Encode.int)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | MinLength(v) =>
    [("validation_rule_type", "min_length"->JSON.Encode.string), ("value", v->JSON.Encode.int)]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

let encodeStringTransformationRule = (rule: stringTransformationRule): JSON.t =>
  switch rule {
  | ToUpperCase =>
    [("transformation_rule_type", "to_upper_case"->JSON.Encode.string)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | ToLowerCase =>
    [("transformation_rule_type", "to_lower_case"->JSON.Encode.string)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | StripPrefix(prefix) =>
    [
      ("transformation_rule_type", "strip_prefix"->JSON.Encode.string),
      ("prefix", prefix->JSON.Encode.string),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  | StripSuffix(suffix) =>
    [
      ("transformation_rule_type", "strip_suffix"->JSON.Encode.string),
      ("suffix", suffix->JSON.Encode.string),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

let encodeMinorUnitValidationRule = (rule: minorUnitValidationRule): JSON.t =>
  switch rule {
  | MinorPositiveOnly =>
    [("validation_rule_type", "positive_only"->JSON.Encode.string)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | MinorMinValue(v) =>
    [("validation_rule_type", "min_value"->JSON.Encode.string), ("value", v->JSON.Encode.int)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | MinorMaxValue(v) =>
    [("validation_rule_type", "max_value"->JSON.Encode.string), ("value", v->JSON.Encode.int)]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

let encodeMajorUnitValidationRule = (rule: majorUnitValidationRule): JSON.t =>
  switch rule {
  | MajorPositiveOnly =>
    [("validation_rule_type", "positive_only"->JSON.Encode.string)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | MajorMinValue(v) =>
    [("validation_rule_type", "min_value"->JSON.Encode.string), ("value", v->JSON.Encode.float)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | MajorMaxValue(v) =>
    [("validation_rule_type", "max_value"->JSON.Encode.string), ("value", v->JSON.Encode.float)]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

let encodeNumberValidationRule = (rule: numberValidationRule): JSON.t =>
  switch rule {
  | NumberMinValue(v) =>
    [("validation_rule_type", "min_value"->JSON.Encode.string), ("value", v->JSON.Encode.float)]
    ->Dict.fromArray
    ->JSON.Encode.object
  | NumberMaxValue(v) =>
    [("validation_rule_type", "max_value"->JSON.Encode.string), ("value", v->JSON.Encode.float)]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

// --- AmountDelimiter ---
let encodeAmountDelimiter = (d: amountDelimiter): string =>
  switch d {
  | Dot => "dot"
  | Comma => "comma"
  }

// --- FieldType (flattened into MetadataFieldSchemaConfig) ---
let encodeFieldType = (ft: fieldTypeVariant): Dict.t<JSON.t> =>
  switch ft {
  | StringFieldType({validation_rules, transformation_rules}) =>
    [
      ("field_type", "string"->JSON.Encode.string),
      (
        "validation_rules",
        validation_rules->Array.map(encodeStringValidationRule)->JSON.Encode.array,
      ),
      (
        "transformation_rules",
        transformation_rules->Array.map(encodeStringTransformationRule)->JSON.Encode.array,
      ),
    ]->Dict.fromArray
  | NumberFieldType({validation_rules}) =>
    [
      ("field_type", "number"->JSON.Encode.string),
      (
        "validation_rules",
        validation_rules->Array.map(encodeNumberValidationRule)->JSON.Encode.array,
      ),
    ]->Dict.fromArray
  | CurrencyFieldType => [("field_type", "currency"->JSON.Encode.string)]->Dict.fromArray
  | MinorUnitFieldType({validation_rules}) =>
    [
      ("field_type", "minor_unit"->JSON.Encode.string),
      (
        "validation_rules",
        validation_rules->Array.map(encodeMinorUnitValidationRule)->JSON.Encode.array,
      ),
    ]->Dict.fromArray
  | MajorUnitFieldType({delimiter, validation_rules}) =>
    [
      ("field_type", "major_unit"->JSON.Encode.string),
      ("delimiter", delimiter->encodeAmountDelimiter->JSON.Encode.string),
      (
        "validation_rules",
        validation_rules->Array.map(encodeMajorUnitValidationRule)->JSON.Encode.array,
      ),
    ]->Dict.fromArray
  | DateTimeFieldType({date_time_format}) =>
    [
      ("field_type", "date_time"->JSON.Encode.string),
      ("date_time_format", date_time_format->encodeDateTimeFormat),
    ]->Dict.fromArray
  | BalanceDirectionFieldType({credit_values, debit_values}) =>
    [
      ("field_type", "balance_direction"->JSON.Encode.string),
      ("credit_values", credit_values->Array.map(JSON.Encode.string)->JSON.Encode.array),
      ("debit_values", debit_values->Array.map(JSON.Encode.string)->JSON.Encode.array),
    ]->Dict.fromArray
  | EnumFieldType({mappings}) =>
    [
      ("field_type", "enum"->JSON.Encode.string),
      (
        "mappings",
        mappings
        ->Dict.toArray
        ->Array.map(((k, v)) => (k, v->JSON.Encode.string))
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]->Dict.fromArray
  }

// --- MetadataFieldSchemaConfig (with flatten) ---
let encodeMetadataFieldSchemaConfig = (field: metadataFieldSchemaConfig): JSON.t => {
  // Start with the flattened field_type fields
  let dict = field.field_type->encodeFieldType
  // Add the non-flattened fields
  dict->Dict.set("identifier", field.identifier->JSON.Encode.string)
  dict->Dict.set("field_name", field.field_name->JSON.Encode.string)
  dict->Dict.set("required", field.required->JSON.Encode.bool)
  dict->Dict.set("description", field.description->JSON.Encode.string)
  dict->JSON.Encode.object
}

// --- AmountSchemaConfig (with flatten) ---
let encodeAmountSchemaConfig = (config: amountSchemaConfig): JSON.t => {
  let dict = Dict.make()
  dict->Dict.set("identifier", config.identifier->JSON.Encode.string)
  switch config.unit_type {
  | MinorUnit => {
      dict->Dict.set("unit_type", "minor_unit"->JSON.Encode.string)
      dict->Dict.set(
        "validation_rules",
        config.validation_rules_minor->Array.map(encodeMinorUnitValidationRule)->JSON.Encode.array,
      )
    }
  | MajorUnit(delimiter) => {
      dict->Dict.set("unit_type", "major_unit"->JSON.Encode.string)
      dict->Dict.set("delimiter", delimiter->encodeAmountDelimiter->JSON.Encode.string)
      dict->Dict.set(
        "validation_rules",
        config.validation_rules_major->Array.map(encodeMajorUnitValidationRule)->JSON.Encode.array,
      )
    }
  }
  dict->JSON.Encode.object
}

// --- UniqueConstraint ---
let encodeUniqueConstraintType = (ct: uniqueConstraintType): JSON.t =>
  switch ct {
  | SingleField(fieldName) =>
    [
      ("unique_constraint_type", "single_field"->JSON.Encode.string),
      ("field_name", fieldName->JSON.Encode.string),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

let encodeUniqueConstraint = (uc: uniqueConstraint): JSON.t =>
  [
    ("constraint_type", uc.constraint_type->encodeUniqueConstraintType),
    ("description", uc.description->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Processing Mode ---
let encodeProcessingMode = (mode: processingMode): string =>
  switch mode {
  | Transaction => "transaction"
  | Confirmation => "confirmation"
  }

// --- MetadataSchemaData ---
let encodeMetadataSchemaData = (schema: metadataSchemaData): JSON.t => {
  let fields =
    [
      (
        "currency",
        [("identifier", schema.fields.currency.identifier->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
      ("amount", schema.fields.amount->encodeAmountSchemaConfig),
      (
        "effective_at",
        [
          ("identifier", schema.fields.effective_at.identifier->JSON.Encode.string),
          ("date_time_format", schema.fields.effective_at.date_time_format->encodeDateTimeFormat),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
      (
        "balance_direction",
        [
          ("identifier", schema.fields.balance_direction.identifier->JSON.Encode.string),
          (
            "credit_values",
            schema.fields.balance_direction.credit_values
            ->Array.map(JSON.Encode.string)
            ->JSON.Encode.array,
          ),
          (
            "debit_values",
            schema.fields.balance_direction.debit_values
            ->Array.map(JSON.Encode.string)
            ->JSON.Encode.array,
          ),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
      (
        "order_id",
        [
          ("identifier", schema.fields.order_id.identifier->JSON.Encode.string),
          (
            "transformation_rules",
            schema.fields.order_id.transformation_rules
            ->Array.map(encodeStringTransformationRule)
            ->JSON.Encode.array,
          ),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
      (
        "metadata_fields",
        schema.fields.metadata_fields
        ->Array.map(encodeMetadataFieldSchemaConfig)
        ->JSON.Encode.array,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object

  // MetadataSchemaData is tagged with "schema_type": "basic_schema_data"
  [
    ("schema_type", "basic_schema_data"->JSON.Encode.string),
    ("fields", fields),
    ("unique_constraint", schema.unique_constraint->encodeUniqueConstraint),
    ("processing_mode", schema.processing_mode->encodeProcessingMode->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

// --- Transformation Config ---
let encodeCreateTransformationConfigRequest = (req: createTransformationConfigRequest): JSON.t =>
  [
    ("ingestion_id", req.ingestion_id->JSON.Encode.string),
    ("account_id", req.account_id->JSON.Encode.string),
    ("name", req.name->JSON.Encode.string),
    ("metadata_schema_data", req.metadata_schema_data->encodeMetadataSchemaData),
    (
      "config",
      [
        ("merchant_id", req.config.merchant_id->JSON.Encode.string),
        ("profile_id", req.config.profile_id->JSON.Encode.string),
        ("account_id", req.config.account_id->JSON.Encode.string),
        (
          "parsing_config",
          [("file_format", "csv"->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object,
        ),
      ]
      ->Dict.fromArray
      ->JSON.Encode.object,
    ),
    ("is_active", req.is_active->JSON.Encode.bool),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// ============================================================
// Recon Rule Encoders
// ============================================================

// --- Trigger ---
let encodeTriggerCreate = (trigger: triggerCreateType): JSON.t =>
  [
    ("trigger_version", "v1"->JSON.Encode.string),
    ("field", trigger.field->JSON.Encode.string),
    (
      "operator",
      [
        ("operator_version", "v1"->JSON.Encode.string),
        (
          "value",
          (switch trigger.operator {
          | Equals => "equals"
          | NotEquals => "not_equals"
          })->JSON.Encode.string,
        ),
      ]
      ->Dict.fromArray
      ->JSON.Encode.object,
    ),
    ("value", trigger.value->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Search Identifier ---
let encodeSearchIdentifierCreate = (si: searchIdentifierCreateType): JSON.t =>
  [
    ("search_version", "v1"->JSON.Encode.string),
    ("source_field", si.source_field->JSON.Encode.string),
    ("target_field", si.target_field->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Match Rules ---
let encodeMatchRuleCreate = (rule: matchRuleCreateType): JSON.t =>
  [
    ("source_field", rule.source_field->JSON.Encode.string),
    ("target_field", rule.target_field->JSON.Encode.string),
    ("operator", rule.operator->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

let encodeMatchRulesCreate = (rules: array<matchRuleCreateType>): JSON.t =>
  [
    ("match_version", "v1"->JSON.Encode.string),
    ("rules", rules->Array.map(encodeMatchRuleCreate)->JSON.Encode.array),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Tolerance Config ---
let encodeToleranceConfigCreate = (tc: toleranceConfigCreateType): JSON.t =>
  [
    ("tolerance_config_version", "v1"->JSON.Encode.string),
    ("lower_tolerance", tc.lower_tolerance->JSON.Encode.int),
    ("upper_tolerance", tc.upper_tolerance->JSON.Encode.int),
    ("tolerance_account_id", tc.tolerance_account_id->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// --- Strategy ---
let encodeReconStrategyCreate = (strategy: reconStrategyCreate): JSON.t => {
  // All fields go to the SAME level due to internally tagged enums
  let dict = Dict.make()

  switch strategy {
  | OneToOneCreate(variant) => {
      dict->Dict.set("recon_strategy_type", "one_to_one"->JSON.Encode.string)
      switch variant {
      | SingleSingleCreate({search_identifier, match_rules, source_account, target_account}) => {
          dict->Dict.set("one_to_one_type", "single_single"->JSON.Encode.string)
          dict->Dict.set("search_identifier", search_identifier->encodeSearchIdentifierCreate)
          dict->Dict.set("match_rules", match_rules->encodeMatchRulesCreate)
          let sourceDict = [
            ("account_id", source_account.account_id->JSON.Encode.string),
            ("trigger", source_account.trigger->encodeTriggerCreate),
          ]->Dict.fromArray
          dict->Dict.set("source_account", sourceDict->JSON.Encode.object)
          let targetDict = [
            ("account_id", target_account.account_id->JSON.Encode.string),
          ]->Dict.fromArray
          switch target_account.tolerance_config {
          | Some(tc) => targetDict->Dict.set("tolerance_config", tc->encodeToleranceConfigCreate)
          | None => ()
          }
          dict->Dict.set("target_account", targetDict->JSON.Encode.object)
        }
      | SingleManyCreate({search_identifier, match_rules, source_account, target_account}) => {
          dict->Dict.set("one_to_one_type", "single_many"->JSON.Encode.string)
          dict->Dict.set("search_identifier", search_identifier->encodeSearchIdentifierCreate)
          dict->Dict.set("match_rules", match_rules->encodeMatchRulesCreate)
          dict->Dict.set(
            "source_account",
            [
              ("account_id", source_account.account_id->JSON.Encode.string),
              ("trigger", source_account.trigger->encodeTriggerCreate),
            ]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
          dict->Dict.set(
            "target_account",
            [("account_id", target_account.account_id->JSON.Encode.string)]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
        }
      | ManySingleCreate({search_identifier, match_rules, source_account, target_account}) => {
          dict->Dict.set("one_to_one_type", "many_single"->JSON.Encode.string)
          dict->Dict.set("search_identifier", search_identifier->encodeSearchIdentifierCreate)
          dict->Dict.set("match_rules", match_rules->encodeMatchRulesCreate)
          dict->Dict.set(
            "source_account",
            [
              ("account_id", source_account.account_id->JSON.Encode.string),
              ("trigger", source_account.trigger->encodeTriggerCreate),
              ("grouping_field", source_account.grouping_field->JSON.Encode.string),
            ]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
          dict->Dict.set(
            "target_account",
            [("account_id", target_account.account_id->JSON.Encode.string)]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
        }
      | ManyManyCreate({search_identifier, match_rules, source_account, target_account}) => {
          dict->Dict.set("one_to_one_type", "many_many"->JSON.Encode.string)
          dict->Dict.set("search_identifier", search_identifier->encodeSearchIdentifierCreate)
          dict->Dict.set("match_rules", match_rules->encodeMatchRulesCreate)
          dict->Dict.set(
            "source_account",
            [
              ("account_id", source_account.account_id->JSON.Encode.string),
              ("trigger", source_account.trigger->encodeTriggerCreate),
              ("grouping_field", source_account.grouping_field->JSON.Encode.string),
            ]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
          dict->Dict.set(
            "target_account",
            [("account_id", target_account.account_id->JSON.Encode.string)]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
        }
      }
    }
  | OneToManyCreate(variant) => {
      dict->Dict.set("recon_strategy_type", "one_to_many"->JSON.Encode.string)
      switch variant {
      | OneToManySingleSingleCreate({source_account, target_accounts}) => {
          dict->Dict.set("one_to_many_type", "single_single"->JSON.Encode.string)
          dict->Dict.set(
            "source_account",
            [
              ("account_id", source_account.account_id->JSON.Encode.string),
              ("trigger", source_account.trigger->encodeTriggerCreate),
            ]
            ->Dict.fromArray
            ->JSON.Encode.object,
          )
          let targetsDict = Dict.make()
          switch target_accounts {
          | PercentageSplit(targets) => {
              targetsDict->Dict.set("split_type", "percentage"->JSON.Encode.string)
              targetsDict->Dict.set(
                "targets",
                targets
                ->Array.map(((target, split)) =>
                  [
                    [
                      ("account_id", target.account_id->JSON.Encode.string),
                      (
                        "search_identifier",
                        target.search_identifier->encodeSearchIdentifierCreate,
                      ),
                      ("match_rules", target.match_rules->encodeMatchRulesCreate),
                    ]
                    ->Dict.fromArray
                    ->JSON.Encode.object,
                    [("value", split.value->JSON.Encode.float)]
                    ->Dict.fromArray
                    ->JSON.Encode.object,
                  ]->JSON.Encode.array
                )
                ->JSON.Encode.array,
              )
            }
          | FixedSplit(targets) => {
              targetsDict->Dict.set("split_type", "fixed"->JSON.Encode.string)
              targetsDict->Dict.set(
                "targets",
                targets
                ->Array.map(((target, split)) =>
                  [
                    [
                      ("account_id", target.account_id->JSON.Encode.string),
                      (
                        "search_identifier",
                        target.search_identifier->encodeSearchIdentifierCreate,
                      ),
                      ("match_rules", target.match_rules->encodeMatchRulesCreate),
                    ]
                    ->Dict.fromArray
                    ->JSON.Encode.object,
                    switch split {
                    | FixedAmount(v) =>
                      [
                        ("fixed_split_type", "amount"->JSON.Encode.string),
                        ("value", v->JSON.Encode.int),
                      ]
                      ->Dict.fromArray
                      ->JSON.Encode.object
                    | FixedRemaining =>
                      [("fixed_split_type", "remaining"->JSON.Encode.string)]
                      ->Dict.fromArray
                      ->JSON.Encode.object
                    },
                  ]->JSON.Encode.array
                )
                ->JSON.Encode.array,
              )
            }
          }
          dict->Dict.set("target_accounts", targetsDict->JSON.Encode.object)
        }
      }
    }
  }

  dict->JSON.Encode.object
}

// --- Aging Config ---
let encodeAgingConfigCreate = (config: agingConfigCreate): JSON.t =>
  switch config {
  | NoAgingCreate =>
    [("aging_config_type", "no_aging"->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
  | WithThresholdCreate({weekdays}) =>
    [
      ("aging_config_type", "with_threshold"->JSON.Encode.string),
      (
        "threshold",
        [
          ("threshold_type", "week_days"->JSON.Encode.string),
          ("value", weekdays->JSON.Encode.int),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

// --- Recon Rule ---
let encodeReconRuleCreateRequest = (req: reconRuleCreateRequest): JSON.t =>
  [
    ("rule_name", req.rule_name->JSON.Encode.string),
    ("rule_description", req.rule_description->JSON.Encode.string),
    ("priority", req.priority->JSON.Encode.int),
    ("strategy", req.strategy->encodeReconStrategyCreate),
    ("aging_config", req.aging_config->encodeAgingConfigCreate),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

// ============================================================
// Display helpers
// ============================================================

let getStepTitle = (step: selfServeStep): string =>
  switch step {
  | AccountSetup => "Create Accounts"
  | IngestionSetup => "Setup Ingestion"
  | TransformationSetup => "Configure Transformation"
  | RuleSetup => "Define Recon Rules"
  | Complete => "Setup Complete"
  }

let getStepDescription = (step: selfServeStep): string =>
  switch step {
  | AccountSetup => "Create at least two accounts to reconcile between. Each account represents a data source (e.g., payment processor, bank)."
  | IngestionSetup => "Configure how data enters the system for each account. Choose manual upload, webhook, or SFTP."
  | TransformationSetup => "Define how your CSV columns map to reconciliation fields. This tells the system what each column means."
  | RuleSetup => "Set up matching rules that define how transactions from different accounts are matched together."
  | Complete => "Your reconciliation setup is complete. You can now start uploading data."
  }

let getStepNumber = (step: selfServeStep): int =>
  switch step {
  | AccountSetup => 1
  | IngestionSetup => 2
  | TransformationSetup => 3
  | RuleSetup => 4
  | Complete => 5
  }

let getNextStep = (step: selfServeStep): option<selfServeStep> =>
  switch step {
  | AccountSetup => Some(IngestionSetup)
  | IngestionSetup => Some(TransformationSetup)
  | TransformationSetup => Some(RuleSetup)
  | RuleSetup => Some(Complete)
  | Complete => None
  }

let getPrevStep = (step: selfServeStep): option<selfServeStep> =>
  switch step {
  | AccountSetup => None
  | IngestionSetup => Some(AccountSetup)
  | TransformationSetup => Some(IngestionSetup)
  | RuleSetup => Some(TransformationSetup)
  | Complete => Some(RuleSetup)
  }

let isStepComplete = (step: selfServeStep, state: selfServeState): bool =>
  switch step {
  | AccountSetup => state.accounts->Array.length >= 2
  | IngestionSetup =>
    state.ingestions->Array.length >= 2 &&
      state.accounts->Array.every(acc =>
        state.ingestions->Array.some(ing => ing.account_id === acc.account_id)
      )
  | TransformationSetup =>
    state.transformations->Array.length >= 2 &&
      state.ingestions->Array.every(ing =>
        state.transformations->Array.some(t => t.ingestion_id === ing.ingestion_id)
      )
  | RuleSetup => true // Validated by the form itself
  | Complete => true
  }

let getAvailableEntryFields = (state: selfServeState): array<string> => {
  let baseFields = ["amount", "currency", "entry_type", "effective_at", "order_id"]
  let metadataFields =
    state.transformations
    ->Array.flatMap(t => t.metadata_fields)
    ->Array.map(f => `metadata.${f}`)
  Array.concat(baseFields, metadataFields)
}

let emptySelfServeState: selfServeState = {
  accounts: [],
  ingestions: [],
  transformations: [],
}

let commonCurrencies = [
  "USD",
  "EUR",
  "GBP",
  "INR",
  "MYR",
  "SGD",
  "AUD",
  "CAD",
  "JPY",
  "CNY",
  "THB",
  "IDR",
  "PHP",
  "VND",
  "KRW",
  "HKD",
  "TWD",
  "BRL",
  "MXN",
  "AED",
]
