open ReconEngineTypes
open LogicUtils
open ReconEnginePipelinesTypes

let getIngestionCounts = (ingestionHistory: array<ingestionHistoryType>) =>
  ingestionHistory->Array.reduce((0, 0, 0, 0), ((total, processed, failed, processing), item) =>
    switch item.status {
    | Discarded | UnknownIngestionTransformationStatus => (total, processed, failed, processing)
    | Processed => (total + 1, processed + 1, failed, processing)
    | Failed => (total + 1, processed, failed + 1, processing)
    | Processing => (total + 1, processed, failed, processing + 1)
    | Pending => (total + 1, processed, failed, processing)
    }
  )

let getStagingOverviewCounts = (stagingOverviewData: array<accountStagingEntriesOverview>) =>
  stagingOverviewData->Array.reduce((0, 0), ((total, needsManualReview), account) =>
    account.status_breakdown->Array.reduce((total, needsManualReview), (
      (total, needsManualReview),
      statusAmount,
    ) =>
      switch statusAmount.status {
      | Archived | Void | UnknownProcessingEntryStatus => (total, needsManualReview)
      | NeedsManualReview => (total + statusAmount.count, needsManualReview + statusAmount.count)
      | Pending | Processed => (total + statusAmount.count, needsManualReview)
      }
    )
  )

let getPipelineStatCards = (
  ~ingestionHistory: array<ingestionHistoryType>,
  ~stagingOverviewData: array<accountStagingEntriesOverview>,
): array<ReconEnginePipelinesTypes.pipelineStatCardData> => {
  open ReconEnginePipelinesTypes
  open ReconEngineOverviewSummaryTypes

  let (totalCount, ingestionProcessedCount, failedCount, processingCount) = getIngestionCounts(
    ingestionHistory,
  )
  let (stagingTotalCount, needsManualReviewCount) = getStagingOverviewCounts(stagingOverviewData)

  let processedRate =
    ReconEngineOverviewUtils.getPercentage(
      ~count=ingestionProcessedCount,
      ~total=totalCount,
    )->CurrencyFormatUtils.valueFormatter(Rate)
  let needsManualReviewRate =
    ReconEngineOverviewUtils.getPercentage(
      ~count=needsManualReviewCount,
      ~total=stagingTotalCount,
    )->CurrencyFormatUtils.valueFormatter(Rate)

  let processedStatusValue =
    ReconEngineFilterUtils.getIngestionTransformationHistoryStatusValueFromStatusList([
      Processed,
    ])->Array.joinWith(",")
  let failedStatusValue =
    ReconEngineFilterUtils.getIngestionTransformationHistoryStatusValueFromStatusList([
      Failed,
    ])->Array.joinWith(",")

  [
    {
      pipelineStatCardTitle: IngestionRuns,
      pipelineStatCardValue: Number(totalCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-upload-file" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: CountWithText(processingCount, "processing now"),
      pipelineStatCardType: Info,
      pipelineStatCardClickAction: ClearStatusFilter,
    },
    {
      pipelineStatCardTitle: FailedRuns,
      pipelineStatCardValue: Number(failedCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-alert-triangle-outline" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: DescriptionText(
        failedCount > 0 ? "needs attention" : "all runs clean",
      ),
      pipelineStatCardType: Attention,
      pipelineStatCardClickAction: SetStatusFilter(failedStatusValue),
    },
    {
      pipelineStatCardTitle: ProcessedRuns,
      pipelineStatCardValue: Number(ingestionProcessedCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-check-circle-outline" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: DescriptionText(`${processedRate} of runs`),
      pipelineStatCardType: Info,
      pipelineStatCardClickAction: SetStatusFilter(processedStatusValue),
    },
    {
      pipelineStatCardTitle: NeedsManualReviewEntries,
      pipelineStatCardValue: Number(needsManualReviewCount),
      pipelineStatCardIcon: CustomIcon(
        <Icon name="nd-information-triangle" size=14 className="text-nd_gray-500" />,
      ),
      pipelineStatCardDescription: DescriptionText(
        `${needsManualReviewRate} of transformed entries`,
      ),
      pipelineStatCardType: Attention,
      pipelineStatCardClickAction: NavigateToPath(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/transformed-entries"),
      ),
    },
  ]
}

let ingestionHistorySortOptions: array<ReconEnginePipelinesTypes.ingestionHistorySortOption> = [
  #MostRecent,
  #NeedsAttention,
  #FileName,
]

let ingestionStatusAttentionRank = status =>
  switch status {
  | Failed => 0
  | Processing => 1
  | Pending => 2
  | Processed => 3
  | Discarded | UnknownIngestionTransformationStatus => 4
  }

let sortIngestionHistory = (
  data: array<Nullable.t<ingestionHistoryType>>,
  sortOption: ReconEnginePipelinesTypes.ingestionHistorySortOption,
) => {
  data->Array.toSorted((a, b) => {
    switch (a->getOptionalFromNullable, b->getOptionalFromNullable) {
    | (Some(a), Some(b)) =>
      switch sortOption {
      | #MostRecent => compareLogic(a.created_at, b.created_at)
      | #NeedsAttention =>
        let rankComparison = numericArraySortComparator(
          ingestionStatusAttentionRank(a.status),
          ingestionStatusAttentionRank(b.status),
        )
        rankComparison == 0. ? compareLogic(a.created_at, b.created_at) : rankComparison
      | #FileName =>
        numericArraySortComparator(a.file_name->String.toLowerCase, b.file_name->String.toLowerCase)
      }
    | (Some(_), None) => -1.
    | (None, Some(_)) => 1.
    | (None, None) => 0.
    }
  })
}

let getAccountOptions = (accounts: array<accountType>): array<FilterSelectBox.dropdownOption> => {
  accounts->Array.map(account => {
    FilterSelectBox.label: account.account_name,
    value: account.account_id,
  })
}

let stagingEntrySearchTypeFromString = (str): stagingEntrySearchType => {
  switch str {
  | "order_id" => SearchOrderId
  | "staging_entry_id" => SearchStagingEntryId
  | _ => UnknownStagingEntrySearchType
  }
}

let stagingEntrySearchTypeOptions: array<SearchInput.searchTypeOption> = {
  [SearchStagingEntryId, SearchOrderId]->Array.map((searchType): SearchInput.searchTypeOption => {
    label: (searchType :> string)->snakeToTitle,
    value: (searchType :> string),
  })
}

let getStagingEntriesSortOrder = (sortOb: LoadedTable.sortOb): stagingEntrySortOrder => {
  sortOb.sortKey === "effective_at" && sortOb.sortType === LoadedTable.ASC ? Asc : Desc
}

let buildStagingEntriesV2Body = (
  ~filterValueJson: Dict.t<JSON.t>,
  ~searchType: stagingEntrySearchType,
  ~searchText: string,
  ~sortBy: cursor,
  ~direction: cursorDirection,
  ~order: stagingEntrySortOrder=Desc,
  ~limit=10,
) => {
  let statusFilter = filterValueJson->getStrArrayFromDict("status", [])
  let statusValues =
    statusFilter->isEmptyArray
      ? ReconEngineFilterUtils.getProcessingEntryStatusValueFromStatusList([
          Pending,
          Processed,
          NeedsManualReview,
          Void,
        ])
      : statusFilter

  let entryTypeFilter = filterValueJson->getStrArrayFromDict("entry_type", [])
  let transformationHistoryIds =
    filterValueJson->getStrArrayFromDict("transformation_history_ids", [])

  let filtersDict = Dict.make()
  filtersDict->Dict.set("status", statusValues->getJsonFromArrayOfString)

  if entryTypeFilter->isNonEmptyArray {
    filtersDict->Dict.set("entry_type", entryTypeFilter->getJsonFromArrayOfString)
  }

  if transformationHistoryIds->isNonEmptyArray {
    filtersDict->Dict.set(
      "transformation_history_ids",
      transformationHistoryIds->getJsonFromArrayOfString,
    )
  }

  if searchText->isNonEmptyString {
    filtersDict->Dict.set((searchType :> string), searchText->String.trim->JSON.Encode.string)
  }

  [
    ("filters", filtersDict->JSON.Encode.object),
    (
      "cursor_payload",
      ({limit, direction, order, sortBy}: stagingEntriesCursorPayload)->Identity.genericTypeToJson,
    ),
  ]->getJsonFromArrayOfJson
}

let getPipelineDetailStatCards = (~transformationHistory: array<transformationHistoryType>): array<
  pipelineDetailStatCardData,
> => {
  let totalTransformed =
    transformationHistory->Array.reduce(0, (acc, t) => acc + t.data.transformed_count)
  let totalIgnored = transformationHistory->Array.reduce(0, (acc, t) => acc + t.data.ignored_count)
  let totalErrors =
    transformationHistory->Array.reduce(0, (acc, t) => acc + t.data.errors->Array.length)
  let transformationRuns = transformationHistory->Array.length
  let allTxProcessed =
    transformationRuns > 0 && transformationHistory->Array.every(t => t.status === Processed)
  let txFailedCount = transformationHistory->Array.filter(t => t.status === Failed)->Array.length

  [
    {
      pipelineDetailStatCardLabel: DetailTransformationRuns,
      pipelineDetailStatCardValue: transformationRuns,
      pipelineDetailStatCardDesc: allTxProcessed
        ? "all processed"
        : txFailedCount > 0
        ? `${txFailedCount->Int.toString} failed`
        : "",
      pipelineDetailStatCardType: txFailedCount > 0 ? Attention : Info,
    },
    {
      pipelineDetailStatCardLabel: DetailRowsTransformed,
      pipelineDetailStatCardValue: totalTransformed,
      pipelineDetailStatCardDesc: "",
      pipelineDetailStatCardType: Info,
    },
    {
      pipelineDetailStatCardLabel: DetailRowsIgnored,
      pipelineDetailStatCardValue: totalIgnored,
      pipelineDetailStatCardDesc: totalIgnored > 0 ? "dropped on parse" : "",
      pipelineDetailStatCardType: totalIgnored > 0 ? Attention : Info,
    },
    {
      pipelineDetailStatCardLabel: DetailErrors,
      pipelineDetailStatCardValue: totalErrors,
      pipelineDetailStatCardDesc: totalErrors > 0 ? "" : "no errors",
      pipelineDetailStatCardType: totalErrors > 0 ? Attention : Info,
    },
  ]
}

let initialStagingEntriesFilters = (
  ~transformationOptions: array<FilterSelectBox.dropdownOption>,
) => {
  let entryTypeOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Credit", value: "credit"},
    {label: "Debit", value: "debit"},
  ]
  let statusOptions = ReconEngineFilterUtils.getStagingEntryStatusOptions([
    Processed,
    Pending,
    NeedsManualReview,
    Void,
  ])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="entry_type",
          ~name="entry_type",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=entryTypeOptions,
            ~buttonText="Select Entry Type",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transformation",
          ~name="transformation_history_ids",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=transformationOptions,
            ~buttonText="Select Transformation",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}

let getParsingConfigLabels = (parsingConfig: parsingConfig): (string, string, string) =>
  switch parsingConfig {
  | CsvParsingConfig => ("CSV", "—", "")
  | XlsxParsingConfig({headerRowIndex, sheetSelection}) => (
      "XLSX",
      headerRowIndex->Int.toString,
      switch sheetSelection {
      | ByName(name) => name
      | ByIndex(index) => `Sheet ${index->Int.toString}`
      | UnknownSheetSelection => ""
      },
    )
  | FixedWidthParsingConfig => ("FIXED WIDTH", "—", "")
  | UnknownParsingConfig => ("—", "—", "")
  }

let describeReplaceMode = (mode: replaceMode): string =>
  switch mode {
  | ReplaceAll => "all occurrences"
  | ReplaceSingle({occurrence, fromEnd}) =>
    `occurrence ${occurrence->Int.toString}${fromEnd ? " from end" : ""}`
  | UnknownReplaceMode => "unknown"
  }

let describeStringTransformationRule = (rule: stringTransformationRule): string =>
  switch rule {
  | StrDefaultValue(value) => `Default value (${value})`
  | StrToUpperCase => "Uppercase"
  | StrToLowerCase => "Lowercase"
  | StrStripPrefix(prefix) => `Strip prefix "${prefix}"`
  | StrStripSuffix(suffix) => `Strip suffix "${suffix}"`
  | StrTrim => "Trim"
  | StrJsonExtract(pointer) => `JSON extract (${pointer})`
  | StrRegex({pattern, group}) =>
    `Regex (${pattern}${group->mapOptionOrDefault("", g => `, group ${g->Int.toString}`)})`
  | UnknownStringTransformationRule => "Unknown rule"
  }

let describeCurrencyTransformationRule = (rule: currencyTransformationRule): string =>
  switch rule {
  | CurrencyDefaultValue(currency) => `Default value (${currency})`
  | CurrencyTrim => "Trim"
  | CurrencyJsonExtract(pointer) => `JSON extract (${pointer})`
  | UnknownCurrencyTransformationRule => "Unknown rule"
  }

let describeBalanceDirectionTransformationRule = (
  rule: balanceDirectionTransformationRule,
): string =>
  switch rule {
  | BalanceDirectionDefaultValue(direction) => `Default value (${direction})`
  | BalanceDirectionTrim => "Trim"
  | BalanceDirectionJsonExtract(pointer) => `JSON extract (${pointer})`
  | BalanceDirectionStartsWith({prefix, thenValue, otherwise}) =>
    `Starts with "${prefix}" → ${thenValue}, else ${otherwise}`
  | UnknownBalanceDirectionTransformationRule => "Unknown rule"
  }

let describeNumberTransformationRule = (rule: numberTransformationRule): string =>
  switch rule {
  | NumberTrim => "Trim"
  | NumberJsonExtract(pointer) => `JSON extract (${pointer})`
  | UnknownNumberTransformationRule => "Unknown rule"
  }

let describeMinorUnitTransformationRule = (rule: minorUnitTransformationRule): string =>
  switch rule {
  | MinorUnitTrim => "Trim"
  | MinorUnitJsonExtract(pointer) => `JSON extract (${pointer})`
  | MinorUnitAbsolute => "Absolute value"
  | UnknownMinorUnitTransformationRule => "Unknown rule"
  }

let describeMajorUnitTransformationRule = (rule: majorUnitTransformationRule): string =>
  switch rule {
  | MajorUnitTrim => "Trim"
  | MajorUnitJsonExtract(pointer) => `JSON extract (${pointer})`
  | MajorUnitNegate => "Negate"
  | MajorUnitAbsolute => "Absolute value"
  | MajorUnitReplaceChar({fromChar, toChar, mode}) =>
    `Replace "${fromChar}" with "${toChar->Option.getOr("")}" (${mode->describeReplaceMode})`
  | UnknownMajorUnitTransformationRule => "Unknown rule"
  }

let describeDateTimeTransformationRule = (rule: dateTimeTransformationRule): string =>
  switch rule {
  | DateTimeTrim => "Trim"
  | DateTimeJsonExtract(pointer) => `JSON extract (${pointer})`
  | UnknownDateTimeTransformationRule => "Unknown rule"
  }

let describeEnumTransformationRule = (rule: enumTransformationRule): string =>
  switch rule {
  | EnumTrim => "Trim"
  | EnumJsonExtract(pointer) => `JSON extract (${pointer})`
  | UnknownEnumTransformationRule => "Unknown rule"
  }

let describeStringValidationRule = (rule: stringValidationRule): string =>
  switch rule {
  | MaxLength(value) => `Max length (${value->Int.toString})`
  | MinLength(value) => `Min length (${value->Int.toString})`
  | UnknownStringValidationRule => "Unknown rule"
  }

let describeNumberValidationRule = (rule: numberValidationRule): string =>
  switch rule {
  | MinValue(value) => `Min value (${value->Float.toString})`
  | MaxValue(value) => `Max value (${value->Float.toString})`
  | UnknownNumberValidationRule => "Unknown rule"
  }

let describeMinorUnitValidationRule = (rule: minorUnitValidationRule): string =>
  switch rule {
  | PositiveOnly => "Positive only"
  | MinValueMinorUnit(value) => `Min value (${value->Int.toString})`
  | MaxValueMinorUnit(value) => `Max value (${value->Int.toString})`
  | UnknownMinorUnitValidationRule => "Unknown rule"
  }

let describeMajorUnitValidationRule = (rule: majorUnitValidationRule): string =>
  switch rule {
  | PositiveOnlyMajorUnit => "Positive only"
  | MinValueMajorUnit(value) => `Min value (${value->Float.toString})`
  | MaxValueMajorUnit(value) => `Max value (${value->Float.toString})`
  | UnknownMajorUnitValidationRule => "Unknown rule"
  }

let describeDateTimeDuration = (duration: dateTimeDuration): string =>
  `${duration.value->Int.toString} ${(duration.unit :> string)}`

let describeDateTimePostParseRule = (rule: dateTimePostParseRule): string =>
  switch rule {
  | PostParseTruncate(precision) => `Truncate (${(precision :> string)->snakeToTitle})`
  | PostParseAddDuration(duration) => `Add ${duration->describeDateTimeDuration}`
  | PostParseSubtractDuration(duration) => `Subtract ${duration->describeDateTimeDuration}`
  | UnknownDateTimePostParseRule => "Unknown rule"
  }

let describeAmountDelimiter = (delimiter: amountDelimiter): string =>
  switch delimiter {
  | DelimiterDot => `Decimal delimiter "."`
  | DelimiterComma => `Decimal delimiter ","`
  | UnknownAmountDelimiter => "Unknown delimiter"
  }

let describeBalanceDirectionValues = (
  ~creditValues: array<string>,
  ~debitValues: array<string>,
): array<string> => {
  let creditDesc =
    creditValues->isNonEmptyArray ? [`Credit values: ${creditValues->Array.joinWith(", ")}`] : []
  let debitDesc =
    debitValues->isNonEmptyArray ? [`Debit values: ${debitValues->Array.joinWith(", ")}`] : []
  creditDesc->Array.concat(debitDesc)
}

let describeEnumMappings = (mappings: Dict.t<string>): array<string> =>
  mappings->Dict.toArray->Array.map(((key, value)) => `${key} → ${value}`)

let fieldRulesTypeLabel = (rules: fieldRules): string =>
  switch rules {
  | StringRules(_) => "string"
  | NumberRules(_) => "number"
  | CurrencyRules(_) => "currency"
  | MinorUnitRules(_) => "amount · minor unit"
  | MajorUnitRules(_) => "amount · major unit"
  | DateTimeRules(_) => "date / time"
  | BalanceDirectionRules(_) => "balance direction"
  | EnumRules(_) => "enum"
  | UnknownFieldRules => "unknown"
  }

let describeFieldRules = (rules: fieldRules): (array<string>, array<string>, array<string>) =>
  switch rules {
  | StringRules({validation, transformation}) => (
      transformation->Array.map(describeStringTransformationRule),
      validation->Array.map(describeStringValidationRule),
      [],
    )
  | NumberRules({validation, transformation}) => (
      transformation->Array.map(describeNumberTransformationRule),
      validation->Array.map(describeNumberValidationRule),
      [],
    )
  | CurrencyRules({transformation}) => (
      transformation->Array.map(describeCurrencyTransformationRule),
      [],
      [],
    )
  | MinorUnitRules({validation, transformation}) => (
      transformation->Array.map(describeMinorUnitTransformationRule),
      validation->Array.map(describeMinorUnitValidationRule),
      [],
    )
  | MajorUnitRules({delimiter, validation, transformation}) => (
      [delimiter->describeAmountDelimiter]->Array.concat(
        transformation->Array.map(describeMajorUnitTransformationRule),
      ),
      validation->Array.map(describeMajorUnitValidationRule),
      [],
    )
  | DateTimeRules({transformation, postParse}) => (
      transformation->Array.map(describeDateTimeTransformationRule),
      [],
      postParse->Array.map(describeDateTimePostParseRule),
    )
  | BalanceDirectionRules({creditValues, debitValues, transformation}) => (
      describeBalanceDirectionValues(~creditValues, ~debitValues)->Array.concat(
        transformation->Array.map(describeBalanceDirectionTransformationRule),
      ),
      [],
      [],
    )
  | EnumRules({mappings, transformation}) => (
      mappings
      ->describeEnumMappings
      ->Array.concat(transformation->Array.map(describeEnumTransformationRule)),
      [],
      [],
    )
  | UnknownFieldRules => ([], [], [])
  }

let describeSkipConditionOperator = (operator: skipConditionOperator): string =>
  switch operator {
  | Equals => "="
  | NotEquals => "≠"
  | Contains => "contains"
  | NotContains => "does not contain"
  | StartsWith => "starts with"
  | NotStartsWith => "does not start with"
  | EndsWith => "ends with"
  | NotEndsWith => "does not end with"
  | UnknownSkipConditionOperator => "unknown"
  }

let describeSkipConditionEntry = (condition: skipCondition): string =>
  `${condition.identifier} ${condition.operator->describeSkipConditionOperator} "${condition.value}"`

let describeSkipConfig = (skipConfig: skipConfig): string => {
  switch skipConfig {
  | RowSkipConfig({lineNumber}) => `Skip line ${lineNumber->Int.toString}`
  | ConditionalSkipConfig({conditions}) =>
    `Skip rows where ${conditions
      ->Array.map(describeSkipConditionEntry)
      ->Array.joinWith(" AND ")}`
  }
}

let formatDuration = (startIso: string, endIso: string): string => {
  if startIso->isNonEmptyString && endIso->isNonEmptyString {
    let rawMs = (endIso->DayJs.getDayJsForString).diff(startIso, "millisecond")
    let totalMs = rawMs < 0 ? 0 : rawMs
    let totalSeconds = totalMs / 1000
    if totalMs < 1000 {
      `${totalMs->Int.toString}ms`
    } else if totalSeconds < 60 {
      `${totalSeconds->Int.toString}s`
    } else if totalSeconds < 3600 {
      let minutes = totalSeconds / 60
      let seconds = totalSeconds - minutes * 60
      `${minutes->Int.toString}m ${seconds->Int.toString}s`
    } else {
      let hours = totalSeconds / 3600
      let minutes = (totalSeconds - hours * 3600) / 60
      `${hours->Int.toString}h ${minutes->Int.toString}m`
    }
  } else {
    "—"
  }
}

let isReportDownloadable = (status: ingestionTransformationStatusType): bool =>
  switch status {
  | Processed => true
  | _ => false
  }

let reportFormatFileType = (format: reportFormat): string =>
  switch format {
  | Csv => "text/csv"
  }

let getTransformationReportFileName = (
  ~transformation: transformationHistoryType,
  ~format: reportFormat,
): string => {
  let name =
    transformation.transformation_name->isNonEmptyString
      ? transformation.transformation_name
      : transformation.transformation_history_id
  let sanitizedName = name->String.replaceRegExp(%re("/[^a-zA-Z0-9-_]+/g"), "_")
  `${sanitizedName}_report.${(format :> string)}`
}

let entryFieldTarget = (field: entryField): string =>
  switch field {
  | Metadata(key) => `metadata.${key}`
  | String => ""
  }

let metadataFieldLabel = (field: metadataFieldType): string =>
  field.description->isNonEmptyString
    ? field.description
    : switch field.field_name {
      | Metadata(key) => key->snakeToTitle
      | String => "Field"
      }

let getDisplayFields = (fields: schemaFieldsType): array<displayField> => {
  let mainFields = fields.main_fields->Array.map((field): displayField => {
    label: field.field_name->snakeToTitle,
    target: field.field_name,
    fieldIdentifier: field.identifier,
    isRequired: true,
    typeLabel: field.rules->fieldRulesTypeLabel,
    ruleSet: field.rules,
  })
  let metadataFields = fields.metadata_fields->Array.map((field): displayField => {
    label: field->metadataFieldLabel,
    target: field.field_name->entryFieldTarget,
    fieldIdentifier: field.identifier,
    isRequired: field.required,
    typeLabel: field.rules->fieldRulesTypeLabel,
    ruleSet: field.rules,
  })
  mainFields->Array.concat(metadataFields)
}

let initialPipelinesTableFilters = (~accountOptions: array<FilterSelectBox.dropdownOption>) => {
  let statusOptions = ReconEngineDataSourcesUtils.getStatusOptions([
    Pending,
    Processing,
    Processed,
    Failed,
  ])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="account",
          ~name="account_id",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=accountOptions,
            ~buttonText="Select Account",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
