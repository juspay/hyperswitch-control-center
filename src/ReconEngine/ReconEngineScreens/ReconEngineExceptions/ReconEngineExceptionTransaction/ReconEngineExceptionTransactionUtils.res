open ReconEngineFilterUtils
open ReconEngineTypes
open LogicUtils
open ReconEngineUtils
open ReconEngineTransactionsUtils
open EntriesTableEntity

let getDetailFieldsForTableSections = [
  EntryType,
  Amount,
  Currency,
  Status,
  EntryId,
  OrderID,
  EffectiveAt,
  CreatedAt,
]

let initialDisplayFilters = () => {
  let statusOptions = getGroupedTransactionStatusOptions([
    OverAmount(Mismatch),
    OverAmount(Expected),
    UnderAmount(Mismatch),
    UnderAmount(Expected),
    DataMismatch,
    CurrencyMismatch,
    SplitMismatch,
    PartiallyReconciled,
    Missing,
  ])
  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Transaction Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}

let exceptionTransactionEntryItemToItemMapper = (
  dict
): ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType => {
  {
    entry_key: dict->getString("entry_key", randomString(~length=16)),
    entry_id: dict->getString("entry_id", "-"),
    entry_type: dict->getString("entry_type", "")->getEntryTypeVariantFromString,
    transaction_id: dict->getString("transaction_id", ""),
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
    amount: dict->getFloat("amount", 0.0),
    currency: dict->getString("currency", ""),
    order_id: dict->getString("order_id", ""),
    status: dict->getString("status", "")->getEntryStatusVariantFromString,
    discarded_status: dict->getOptionString("discarded_status"),
    version: dict->getInt("version", 0),
    metadata: dict->getJsonObjectFromDict("metadata"),
    data: dict->getJsonObjectFromDict("data"),
    created_at: dict->getString("created_at", Date.make()->Date.toISOString),
    effective_at: dict->getString("effective_at", ""),
    staging_entry_id: dict->getOptionString("staging_entry_id"),
    transformation_id: dict->getOptionString("transformation_id"),
    transformation_name: dict->getOptionString("transformation_name"),
  }
}

let roundToCurrencyPrecision = (~amount: float, ~currency: string) => {
  open CurrencyUtils

  convertCurrencyFromLowestDenomination(
    ~amount=convertCurrencyToLowestDenomination(~amount, ~currency)->Math.round,
    ~currency,
  )
}

let getBalanceByAccountType = (
  entries: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  accountType: accountTypeVariant,
): (float, string) => {
  let (totalCredits, totalDebits) = entries->Array.reduce((0.0, 0.0), (
    (credits, debits),
    entry,
  ) => {
    switch entry.entry_type {
    | Credit => (credits +. entry.amount, debits)
    | Debit => (credits, debits +. entry.amount)
    | UnknownEntryDirectionType => (credits, debits)
    }
  })

  let balance = switch accountType {
  | Credit => totalCredits -. totalDebits
  | Debit => totalDebits -. totalCredits
  | UnknownAccountTypeVariant => 0.0
  }

  let firstEntry =
    entries->getValueFromArray(0, Dict.make()->exceptionTransactionEntryItemToItemMapper)

  (roundToCurrencyPrecision(~amount=balance, ~currency=firstEntry.currency), firstEntry.currency)
}

let getMismatchedFieldsFromMismatchData = (mismatchData: Js.Json.t) =>
  mismatchData
  ->getDictFromJsonObject
  ->getJsonObjectFromDict("mismatch_data")
  ->getDictFromJsonObject
  ->getMismatchedFieldsFromDict

let getHeadingAndSubHeadingForMismatch = (mismatchData: Js.Json.t): (string, string) => {
  let mismatchType =
    mismatchData
    ->getDictFromJsonObject
    ->getString("mismatch_type", "")
    ->getMismatchTypeVariantFromString
  let mismatchedDataDict =
    mismatchData->getDictFromJsonObject->getJsonObjectFromDict("mismatch_data")

  let expectedAmount =
    mismatchedDataDict
    ->getDictFromJsonObject
    ->getDictfromDict("expected_amount")
    ->getFloat("value", 0.0)

  let actualAmount =
    mismatchedDataDict
    ->getDictFromJsonObject
    ->getDictfromDict("actual_amount")
    ->getFloat("value", 0.0)

  let currency =
    mismatchedDataDict
    ->getDictFromJsonObject
    ->getDictfromDict("expected_amount")
    ->getString("currency", "USD")

  let mismatchAmount = Math.abs(expectedAmount -. actualAmount)
  let mismatchHeading = (mismatchType :> string)->snakeToTitle

  let mismatchedFieldsCountText =
    mismatchData->getMismatchedFieldsFromMismatchData->getMismatchedFieldsCountText

  let mismatchSubHeading = switch mismatchType {
  | AmountMismatch =>
    `There is a ${mismatchHeading} of ${CurrencyFormatUtils.valueFormatter(
        mismatchAmount,
        AmountWithSuffix,
        ~currency,
      )} found between the transaction entries`
  | MetadataMismatch
  | BalanceDirectionMismatch
  | CurrencyMismatch =>
    mismatchedFieldsCountText->isNonEmptyString
      ? mismatchedFieldsCountText
      : `There is a ${mismatchHeading} found between the transaction entries`
  | UnknownMismatchType => "Mismatch details are unavailable."
  }

  (mismatchHeading, mismatchSubHeading)
}

let getSumOfAmountWithCurrency = (
  entries: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
): (float, string) => {
  let totalAmount = entries->Array.reduce(0.0, (acc, entry) => acc +. entry.amount)
  let entry = entries->getValueFromArray(0, Dict.make()->exceptionTransactionEntryItemToItemMapper)
  (roundToCurrencyPrecision(~amount=totalAmount, ~currency=entry.currency), entry.currency)
}

let exceptionTransactionProcessingEntryItemToObjMapper = (dict): processingEntryType => {
  let discardedDataDict = dict->getDictfromDict("discarded_data")
  let discardedStatusDict = dict->getDictfromDict("detailed_discarded_status")
  let statusDict = dict->getDictfromDict("detailed_status")
  {
    id: dict->getString("id", ""),
    staging_entry_id: dict->getString("staging_entry_id", ""),
    account: dict->getDictfromDict("account")->accountRefItemToObjMapper,
    entry_type: dict->getString("entry_type", ""),
    amount: dict->getFloat("amount", 0.0),
    currency: dict->getString("currency", ""),
    effective_at: dict->getString("effective_at", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
    processing_mode: dict->getString("processing_mode", ""),
    status: statusDict->getString("status", "")->getDomainStagingEntryStatus(statusDict),
    transformation_config: dict
    ->getDictfromDict("transformation_config")
    ->transformationConfigRefTypeMapper,
    transformation_history_id: dict->getString("transformation_history_id", ""),
    order_id: dict->getString("order_id", ""),
    version: dict->getInt("version", 0),
    discarded_status: discardedStatusDict->isEmptyDict
      ? None
      : Some(
          discardedStatusDict
          ->getString("status", "")
          ->getDomainStagingEntryStatus(discardedStatusDict),
        ),
    discarded_data: discardedDataDict->isEmptyDict
      ? None
      : Some(discardedDataDict->processingEntryDiscardedDataItemToObjMapper),
  }
}

let hasFormValuesChanged = (currentValues: JSON.t, initialEntryDetails: entryType): bool => {
  let currentData = currentValues->getDictFromJsonObject
  let initialMetadata = initialEntryDetails.metadata->getFilteredMetadataFromEntries

  let isAccountChanged = currentData->getString("account", "") != initialEntryDetails.account_id
  let isTransformationConfigChanged =
    currentData->getOptionString("transformation_id") != initialEntryDetails.transformation_id
  let isEntryTypeChanged =
    currentData->getString("entry_type", "") != (initialEntryDetails.entry_type :> string)
  let isAmountChanged = currentData->getFloat("amount", 0.0) != initialEntryDetails.amount
  let isCurrencyChanged = currentData->getString("currency", "") != initialEntryDetails.currency
  let isEffectiveAtChanged =
    currentData->getString("effective_at", "") != initialEntryDetails.effective_at

  let isMetadataChanged = {
    let currentMetadata = currentData->getDictfromDict("metadata")
    currentMetadata
    ->Dict.keysToArray
    ->Array.concat(initialMetadata->Dict.keysToArray)
    ->Array.some(key => currentMetadata->getString(key, "") != initialMetadata->getString(key, ""))
  }
  let isOrderIdChanged = currentData->getString("order_id", "") != initialEntryDetails.order_id

  isAccountChanged ||
  isTransformationConfigChanged ||
  isEntryTypeChanged ||
  isAmountChanged ||
  isCurrencyChanged ||
  isEffectiveAtChanged ||
  isMetadataChanged ||
  isOrderIdChanged
}

open ReconEngineExceptionsUtils

let validateEntryDetailsCommon = (
  data: Dict.t<JSON.t>,
  ~metadataSchema: metadataSchemaType,
): Dict.t<JSON.t> => {
  let validationRules = [
    ("account", requiredString("account", "Cannot be empty!")),
    ("transformation_id", requiredString("transformation_id", "Cannot be empty!")),
    ("entry_type", requiredString("entry_type", "Cannot be empty!")),
    ("currency", requiredString("currency", "Cannot be empty!")),
    ("order_id", requiredString("order_id", "Cannot be empty!")),
    ("effective_at", requiredString("effective_at", "Cannot be empty!")),
    ("amount", positiveFloat("amount", "Should be greater than 0!")),
  ]

  let fieldErrors = validateFields(data, validationRules)->getDictFromJsonObject
  if metadataSchema.id->isNonEmptyString {
    let metadataDict = data->getJsonObjectFromDict("metadata")->getDictFromJsonObject

    metadataSchema.schema_data.fields.metadata_fields->Array.forEach(field => {
      let fieldKey = getFieldNameFromMetadataField(field)
      let value = metadataDict->getString(fieldKey, "")
      let error = validateMetadataFieldValue(fieldKey, value, metadataSchema)
      switch error {
      | Some(err) => {
          let errorKey = `metadata.${fieldKey}`
          fieldErrors->Dict.set(errorKey, err->JSON.Encode.string)
        }
      | None => ()
      }
    })
  }

  fieldErrors
}

let validateCreateEntryDetails = (values: JSON.t, ~metadataSchema: metadataSchemaType): JSON.t => {
  let data = values->getDictFromJsonObject
  let fieldErrors = validateEntryDetailsCommon(data, ~metadataSchema)
  fieldErrors->JSON.Encode.object
}

let validateEditEntryDetails = (
  values: JSON.t,
  ~initialEntryDetails: entryType,
  ~metadataSchema: metadataSchemaType,
): JSON.t => {
  let data = values->getDictFromJsonObject
  let fieldErrors = validateEntryDetailsCommon(data, ~metadataSchema)
  let hasChanges = hasFormValuesChanged(values, initialEntryDetails)
  if !hasChanges {
    fieldErrors->Dict.set("No changes", "Please make changes before saving."->JSON.Encode.string)
  }
  fieldErrors->JSON.Encode.object
}

let getInitialValuesForEditEntries = (entryDetails: entryType) => {
  let fields = [
    ("account", entryDetails.account_id->JSON.Encode.string),
    ("entry_type", (entryDetails.entry_type :> string)->JSON.Encode.string),
    ("currency", entryDetails.currency->JSON.Encode.string),
    ("amount", entryDetails.amount->JSON.Encode.float),
    ("order_id", entryDetails.order_id->JSON.Encode.string),
    ("effective_at", entryDetails.effective_at->JSON.Encode.string),
    ("metadata", entryDetails.metadata->getFilteredMetadataFromEntries->JSON.Encode.object),
    (
      "transformation_id",
      switch entryDetails.transformation_id {
      | Some(id) => id->JSON.Encode.string
      | None => JSON.Encode.null
      },
    ),
    (
      "staging_entry_id",
      switch entryDetails.staging_entry_id {
      | Some(id) => id->JSON.Encode.string
      | None => JSON.Encode.null
      },
    ),
  ]
  fields->getJsonFromArrayOfJson
}

let getConvertedEntriesFromStagingEntry = (stagingEntry: processingEntryType) => {
  let uniqueId = randomString(~length=16)
  [
    ("account_id", stagingEntry.account.account_id->JSON.Encode.string),
    ("account_name", stagingEntry.account.account_name->JSON.Encode.string),
    ("entry_id", "-"->JSON.Encode.string),
    ("entry_type", stagingEntry.entry_type->JSON.Encode.string),
    ("currency", stagingEntry.currency->JSON.Encode.string),
    ("amount", stagingEntry.amount->JSON.Encode.float),
    ("order_id", stagingEntry.order_id->JSON.Encode.string),
    ("effective_at", stagingEntry.effective_at->JSON.Encode.string),
    ("metadata", stagingEntry.metadata),
    ("staging_entry_id", stagingEntry.id->JSON.Encode.string),
    ("status", "pending"->JSON.Encode.string),
    ("data", [("status", "pending"->JSON.Encode.string)]->getJsonFromArrayOfJson),
    ("entry_key", uniqueId->JSON.Encode.string),
    (
      "transformation_id",
      stagingEntry.transformation_config.transformation_config_id->JSON.Encode.string,
    ),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let buildLinkableStagingEntriesV2Body = (
  ~sortBy: cursor,
  ~direction: cursorDirection,
  ~searchType: ReconEnginePipelinesTypes.stagingEntrySearchType,
  ~searchText: string,
  ~accountIds: array<string>,
  ~limit=10,
) => {
  let filtersDict = Dict.make()
  filtersDict->setOptionArray(
    "account_ids",
    accountIds->Array.map(JSON.Encode.string)->getNonEmptyArray,
  )
  if searchText->isNonEmptyString {
    filtersDict->Dict.set((searchType :> string), searchText->String.trim->JSON.Encode.string)
  }
  let cursorPayload: ReconEnginePipelinesTypes.stagingEntriesCursorPayload = {
    limit,
    direction,
    order: ReconEnginePipelinesTypes.Desc,
    sortBy,
  }
  [
    ("filters", filtersDict->JSON.Encode.object),
    ("cursor_payload", cursorPayload->Identity.genericTypeToJson),
  ]->getJsonFromArrayOfJson
}

let getInitialValuesForNewEntries = () => {
  let todayDate = Js.Date.make()->Js.Date.toISOString

  let fields = [("effective_at", todayDate->JSON.Encode.string)]
  fields->getJsonFromArrayOfJson
}

let getInnerVariant = (
  stage: ReconEngineExceptionTransactionTypes.exceptionResolutionStage,
): ReconEngineExceptionTransactionTypes.resolvingException =>
  switch stage {
  | ResolvingException(resolvingEx) => resolvingEx
  | ConfirmResolution(resolvingEx) => resolvingEx
  | _ => NoResolutionActionNeeded
  }

let getRuleAccounts = (accounts: array<accountType>, ~ruleAccountIds) =>
  accounts->Array.filter(account => ruleAccountIds->Array.includes(account.account_id))

let getUniqueAccountOptionsFromEntries = (entries: array<entryType>): array<
  SelectBox.dropdownOption,
> => {
  let allAccounts = entries->Array.reduce([], (acc: array<(string, string)>, entry) => {
    Array.concat(acc, [(entry.account_id, entry.account_name)])
  })

  let uniqueAccounts = allAccounts->Array.reduce([], (acc, (accountId, accountName)) => {
    let exists = acc->Array.some(((existingAccountId, _)) => existingAccountId == accountId)
    exists ? acc : [...acc, (accountId, accountName)]
  })

  uniqueAccounts->Array.map(((accountId, accountName)): SelectBox.dropdownOption => {
    label: accountName,
    value: accountId,
  })
}

let mapResolutionActionsFromString = (str: string): array<
  ReconEngineExceptionTransactionTypes.resolvingException,
> => {
  open ReconEngineExceptionTransactionTypes
  switch str {
  | "void_transaction" => [VoidTransaction]
  | "link_staging_entries_to_transaction" => [
      ReplaceStagingEntryToTransaction,
      LinkStagingEntryToTransaction,
    ]
  | "replace_entries" => [EditEntry]
  | "create_entries" => [CreateNewEntry]
  | "force_reconcile" => [ForceReconcile]
  | _ => []
  }
}

let parseResolutionActions = (json: JSON.t): array<
  ReconEngineExceptionTransactionTypes.resolvingException,
> => {
  json
  ->getArrayFromJson([])
  ->Array.flatMap(item => item->getStringFromJson("")->mapResolutionActionsFromString)
}

let getExceptionEntryTypeFromEntryType = (
  entry: entryType,
): ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType => {
  {
    entry_id: entry.entry_id,
    entry_type: entry.entry_type,
    account_id: entry.account_id,
    account_name: entry.account_name,
    transaction_id: entry.transaction_id,
    amount: entry.amount,
    currency: entry.currency,
    status: entry.status,
    order_id: entry.order_id,
    discarded_status: entry.discarded_status,
    metadata: entry.metadata,
    data: entry.data,
    version: entry.version,
    created_at: entry.created_at,
    effective_at: entry.effective_at,
    staging_entry_id: entry.staging_entry_id,
    entry_key: entry.entry_id,
    transformation_id: entry.transformation_id,
    transformation_name: entry.transformation_name,
  }
}

let getEntryTypeFromExceptionEntryType = (
  entry: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
): entryType => {
  {
    entry_id: entry.entry_id,
    entry_type: entry.entry_type,
    account_id: entry.account_id,
    account_name: entry.account_name,
    transaction_id: entry.transaction_id,
    amount: entry.amount,
    currency: entry.currency,
    order_id: entry.order_id,
    status: entry.status,
    discarded_status: entry.discarded_status,
    metadata: entry.metadata,
    data: entry.data,
    version: entry.version,
    created_at: entry.created_at,
    effective_at: entry.effective_at,
    staging_entry_id: entry.staging_entry_id,
    transformation_id: entry.transformation_id,
    transformation_name: entry.transformation_name,
  }
}

let getResolutionModalConfig = (
  exceptionStage: ReconEngineExceptionTransactionTypes.exceptionResolutionStage,
): ReconEngineExceptionsTypes.resolutionConfig => {
  switch exceptionStage {
  | ResolvingException(VoidTransaction) => {
      heading: "Ignore Transaction",
      description: "This will remove the transaction from the current Reconciliation.",
      layout: CenterModal,
      closeOnOutsideClick: true,
    }
  | ResolvingException(ForceReconcile) => {
      heading: "Force Match",
      description: "This action will mark the transaction as matched.",
      layout: CenterModal,
      closeOnOutsideClick: true,
    }
  | ResolvingException(EditEntry) => {
      heading: "Edit Entry",
      description: "Allows you to fix data discrepancies in the selected entry.",
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(MarkAsReceived) => {
      heading: "Mark as Received",
      description: "Allows you to mark that the expected entry has been received.",
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(CreateNewEntry) => {
      heading: "Create New Entry",
      description: "Manually create an entry when data is missing from either accounts",
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(ReplaceStagingEntryToTransaction) => {
      heading: "Match with an existing transformed entry",
      description: "Allows you to replace the existing entry with the correct transformed entries",
      layout: ExpandedSidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(LinkStagingEntryToTransaction) => {
      heading: "Link a transformed entry",
      description: "Allows you to add a new transformed entry to this transaction",
      layout: ExpandedSidePanelModal,
      closeOnOutsideClick: false,
    }
  | _ => {
      heading: "",
      layout: CenterModal,
      closeOnOutsideClick: true,
    }
  }
}

let getUpdatedEntry = (
  ~entryDetails: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
  ~formData,
  ~markAsReceived=false,
): ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType => {
  let isExpected = entryDetails.status == Expected

  let statusString = if markAsReceived {
    "pending"
  } else if isExpected {
    "expected"
  } else {
    "pending"
  }

  {
    entry_id: entryDetails.entry_id,
    entry_type: formData->getString("entry_type", "")->getEntryTypeVariantFromString,
    account_id: formData->getString("account", ""),
    account_name: formData->getString("account_name", entryDetails.account_name),
    transaction_id: entryDetails.transaction_id,
    amount: formData->getFloat("amount", entryDetails.amount),
    currency: formData->getString("currency", ""),
    status: statusString->getEntryStatusVariantFromString,
    order_id: formData->getString("order_id", entryDetails.order_id),
    discarded_status: entryDetails.discarded_status,
    version: entryDetails.version,
    metadata: formData->getJsonObjectFromDict("metadata"),
    data: Dict.fromArray([("status", statusString->JSON.Encode.string)])->JSON.Encode.object,
    created_at: entryDetails.created_at,
    effective_at: formData->getString("effective_at", entryDetails.effective_at),
    staging_entry_id: entryDetails.staging_entry_id,
    entry_key: entryDetails.entry_key,
    transformation_id: formData->getOptionString("transformation_id"),
    transformation_name: entryDetails.transformation_name,
  }
}

let getNewEntry = (
  ~formData,
): ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType => {
  let uniqueId = randomString(~length=16)

  {
    entry_id: "-",
    entry_type: formData->getString("entry_type", "")->getEntryTypeVariantFromString,
    account_id: formData->getString("account", ""),
    account_name: formData->getString("account_name", ""),
    transaction_id: formData->getString("transaction_id", ""),
    amount: formData->getFloat("amount", 0.0),
    currency: formData->getString("currency", ""),
    order_id: formData->getString("order_id", ""),
    status: Pending,
    discarded_status: None,
    version: 0,
    metadata: formData->getJsonObjectFromDict("metadata"),
    data: Dict.fromArray([("status", "pending"->JSON.Encode.string)])->JSON.Encode.object,
    created_at: Date.make()->Date.toISOString,
    effective_at: formData->getString("effective_at", ""),
    staging_entry_id: None,
    entry_key: uniqueId,
    transformation_id: formData->getOptionString("transformation_id"),
    transformation_name: None,
  }
}

let getEntryOverrides = (formData): ReconEngineExceptionTransactionTypes.entryOverrides => {
  entry_type: formData->getString("entry_type", "")->getEntryTypeVariantFromString,
  amount: formData->getFloat("amount", 0.0),
  effective_at: formData->getString("effective_at", "")->toReconTimeString,
  metadata: formData->getJsonObjectFromDict("metadata"),
  order_id: formData->getString("order_id", ""),
  transformation_id: ?formData->getOptionString("transformation_id"),
}

let getStagingEntryOverrides = (
  formData
): ReconEngineExceptionTransactionTypes.stagingEntryOverrides => {
  effective_at: formData->getString("effective_at", "")->toReconTimeString,
  metadata: formData->getJsonObjectFromDict("metadata"),
  order_id: formData->getString("order_id", ""),
}

let getCreateEntryOp = (formData): ReconEngineExceptionTransactionTypes.entryOp => CreateEntry({
  entry: Direct({
    account_id: formData->getString("account", ""),
    entry_type: formData->getString("entry_type", "")->getEntryTypeVariantFromString,
    amount: formData->getFloat("amount", 0.0),
    effective_at: formData->getString("effective_at", "")->toReconTimeString,
    metadata: formData->getJsonObjectFromDict("metadata"),
    order_id: formData->getString("order_id", ""),
    transformation_id: ?formData->getOptionString("transformation_id"),
  }),
})

let getLinkStagingEntryOp = (
  entry: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
): ReconEngineExceptionTransactionTypes.entryOp => CreateWithStagingEntry({
  staging_entry_id: entry.staging_entry_id->Option.getOr(""),
})

let getEditEntryOp = (
  ~change: option<ReconEngineExceptionTransactionTypes.entryChange>,
  ~entryId,
  ~formData,
  ~isMarkReceived,
): ReconEngineExceptionTransactionTypes.entryOp =>
  switch change->Option.map(change => change.op) {
  | Some(CreateEntry(_)) => formData->getCreateEntryOp
  | Some(CreateWithStagingEntry({staging_entry_id})) =>
    CreateWithStagingEntry({staging_entry_id, overrides: formData->getStagingEntryOverrides})
  | Some(ReplaceWithStagingEntry({entry_id, staging_entry_id})) =>
    ReplaceWithStagingEntry({
      entry_id,
      staging_entry_id,
      overrides: formData->getStagingEntryOverrides,
    })
  | Some(MarkReceived(_)) =>
    MarkReceived({entry_id: entryId, overrides: formData->getEntryOverrides})
  | Some(UpdateEntry(_)) | None =>
    isMarkReceived
      ? MarkReceived({entry_id: entryId, overrides: formData->getEntryOverrides})
      : UpdateEntry({entry_id: entryId, overrides: formData->getEntryOverrides})
  }

let addEntryChange = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  change: ReconEngineExceptionTransactionTypes.entryChange,
) => {
  let changes = changes->Dict.copy
  changes->Dict.set(change.entry.entry_key, change)
  changes
}

let removeEntryChange = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~entryKey,
) => {
  let changes = changes->Dict.copy
  changes->deleteNestedKeys([entryKey])
  changes
}

let recordEditedEntry = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~entry: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
  ~formData,
  ~isMarkReceived=false,
) =>
  changes->addEntryChange({
    op: getEditEntryOp(
      ~change=changes->getOptionValFromDict(entry.entry_key),
      ~entryId=entry.entry_id,
      ~formData,
      ~isMarkReceived,
    ),
    entry: getUpdatedEntry(~formData, ~markAsReceived=isMarkReceived, ~entryDetails=entry),
  })

let recordCreatedEntry = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~formData,
) => changes->addEntryChange({op: formData->getCreateEntryOp, entry: getNewEntry(~formData)})

let recordLinkedEntries = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  stagingEntries: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
) =>
  stagingEntries->Array.reduce(changes, (changes, stagingEntry) =>
    changes->addEntryChange({op: stagingEntry->getLinkStagingEntryOp, entry: stagingEntry})
  )

let recordReplacedEntry = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~entry: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
  ~stagingEntry: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
) => {
  let replaceEntry = entryId =>
    changes->addEntryChange({
      op: ReplaceWithStagingEntry({
        entry_id: entryId,
        staging_entry_id: stagingEntry.staging_entry_id->Option.getOr(""),
      }),
      entry: {...stagingEntry, entry_key: entry.entry_key},
    })

  switch changes->getOptionValFromDict(entry.entry_key)->Option.map(change => change.op) {
  | Some(CreateEntry(_)) | Some(CreateWithStagingEntry(_)) =>
    changes->removeEntryChange(~entryKey=entry.entry_key)->recordLinkedEntries([stagingEntry])
  | Some(ReplaceWithStagingEntry({entry_id})) => replaceEntry(entry_id)
  | Some(UpdateEntry(_)) | Some(MarkReceived(_)) | None => replaceEntry(entry.entry_id)
  }
}

let getAddedEntries = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~accountId,
) =>
  changes
  ->Dict.valuesToArray
  ->Array.filterMap(({op, entry}) =>
    switch op {
    | CreateEntry(_) | CreateWithStagingEntry(_) if entry.account_id == accountId => Some(entry)
    | CreateEntry(_)
    | CreateWithStagingEntry(_)
    | UpdateEntry(_)
    | MarkReceived(_)
    | ReplaceWithStagingEntry(_) =>
      None
    }
  )

let applyEntryChanges = (
  entries: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  ~changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~accountId,
  ~isFirstPage,
) =>
  entries
  ->Array.map(entry =>
    changes
    ->getOptionValFromDict(entry.entry_key)
    ->mapOptionOrDefault(entry, change => change.entry)
  )
  ->Array.concat(isFirstPage ? changes->getAddedEntries(~accountId) : [])

let getLinkedStagingEntryIds = (
  changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
) =>
  changes
  ->Dict.valuesToArray
  ->Array.filterMap(({op}) =>
    switch op {
    | CreateWithStagingEntry({staging_entry_id})
    | ReplaceWithStagingEntry({staging_entry_id}) =>
      Some(staging_entry_id)
    | UpdateEntry(_) | MarkReceived(_) | CreateEntry(_) => None
    }
  )
  ->Set.fromArray

let getEntryChangeSummary = ({op, entry}: ReconEngineExceptionTransactionTypes.entryChange) => {
  let amount = `${entry.currency} ${entry.amount->Float.toString}`
  switch op {
  | UpdateEntry(_) =>
    `Entry with order ID ${entry.order_id} updated in ${entry.account_name} account.`
  | MarkReceived(_) =>
    `Expected entry with order ID ${entry.order_id} marked as received in ${entry.account_name} account.`
  | CreateEntry(_) =>
    `New ${(entry.entry_type :> string)} entry of ${amount} with order ID ${entry.order_id} created in ${entry.account_name} account.`
  | CreateWithStagingEntry(_) =>
    `Transformed entry of ${amount} with order ID ${entry.order_id} linked in ${entry.account_name} account.`
  | ReplaceWithStagingEntry(_) =>
    `Entry replaced with transformed entry of ${amount} with order ID ${entry.order_id} in ${entry.account_name} account.`
  }
}

let constructManualReconciliationBody = (
  ~changes: Dict.t<ReconEngineExceptionTransactionTypes.entryChange>,
  ~values,
) => {
  let request: ReconEngineExceptionTransactionTypes.manualReconciliationRequest = {
    entry_ops: changes->Dict.valuesToArray->Array.map(({op}) => op),
    reason: values->getDictFromJsonObject->getString("reason", ""),
  }
  request->Identity.genericTypeToJson
}

let isMismatchedTransaction = (status: domainTransactionStatus) =>
  switch status {
  | DataMismatch
  | CurrencyMismatch
  | SplitMismatch
  | OverAmount(Mismatch)
  | UnderAmount(Mismatch) => true
  | Posted(Manual)
  | Matched(Force)
  | Matched(Manual)
  | Matched(Auto)
  | Matched(WithTolerance)
  | OverAmount(Expected)
  | UnderAmount(Expected)
  | Archived
  | Void
  | Missing
  | Expected
  | PartiallyReconciled
  | Posted(UnknownDomainTransactionPostedStatus)
  | Matched(UnknownDomainTransactionMatchedStatus)
  | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
  | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
  | UnknownDomainTransactionStatus => false
  }

let addUniqueIdsToEntries = (entries: array<entryType>): array<
  ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
> => {
  entries->Array.map(getExceptionEntryTypeFromEntryType)
}

let convertGroupedEntriesToEntryType = (
  groupedEntries: Dict.t<array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>>,
): Dict.t<array<entryType>> => {
  let result = Dict.make()
  groupedEntries
  ->Dict.toArray
  ->Array.forEach(((key, entries)) => {
    result->Dict.set(key, entries->Array.map(getEntryTypeFromExceptionEntryType))
  })
  result
}

let getGroupedEntriesAndAccountMaps = (
  ~accountsData: array<accountType>,
  ~updatedEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
): (
  Dict.t<array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>>,
  Dict.t<ReconEngineExceptionTransactionTypes.accountInfo>,
) => {
  let accountInfoDict: Dict.t<ReconEngineExceptionTransactionTypes.accountInfo> = Dict.make()
  accountsData->Array.forEach(account => {
    accountInfoDict->Dict.set(
      account.account_id,
      {
        account_info_name: account.account_name,
        account_info_type: account.account_type,
      },
    )
  })
  let groupDict = Dict.make()
  updatedEntriesList->Array.forEach(entry => {
    let accountId = entry.account_id
    let existingEntries = groupDict->Dict.get(accountId)->Option.getOr([])
    groupDict->Dict.set(accountId, existingEntries->Array.concat([entry]))
  })

  (groupDict, accountInfoDict)
}

let calculateSectionData = (
  ~groupedEntries: Dict.t<array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>>,
  ~accountInfoMap,
  ~getBalanceByAccountType,
  ~getSumOfAmountWithCurrency,
): array<ReconEngineExceptionTransactionTypes.accountSection> => {
  open ReconEngineExceptionTransactionTypes

  groupedEntries
  ->Dict.keysToArray
  ->Array.map(accountId => {
    let accountInfo =
      accountInfoMap->getValueFromDict(
        accountId,
        {account_info_name: "", account_info_type: UnknownAccountTypeVariant},
      )
    let accountEntries = groupedEntries->getValueFromDict(accountId, [])

    let (accountTotalAmount, accountCurrency) = if (
      accountInfo.account_info_type != UnknownAccountTypeVariant
    ) {
      getBalanceByAccountType(accountEntries, accountInfo.account_info_type)
    } else {
      getSumOfAmountWithCurrency(accountEntries)
    }

    {accountId, accountInfo, accountEntries, accountTotalAmount, accountCurrency}
  })
}

let calculateOverallBalance = (
  sectionData: array<ReconEngineExceptionTransactionTypes.accountSection>,
) => {
  let (totalCreditAccounts, totalDebitAccounts) = sectionData->Array.reduce((0.0, 0.0), (
    (creditSum, debitSum),
    section,
  ) => {
    switch section.accountInfo.account_info_type {
    | Credit => (creditSum +. section.accountTotalAmount, debitSum)
    | Debit => (creditSum, debitSum +. section.accountTotalAmount)
    | UnknownAccountTypeVariant => (creditSum, debitSum)
    }
  })

  let currency =
    sectionData->Array.map(section => section.accountCurrency)->getValueFromArray(0, "")

  roundToCurrencyPrecision(~amount=totalCreditAccounts -. totalDebitAccounts, ~currency)
}

let getFixEntriesButtons = (
  ~isResolutionAvailable,
  ~showMarkAsReceivedButton,
  ~setExceptionStage,
  ~setActiveModal,
): array<ReconEngineExceptionsTypes.buttonConfig> => {
  open ReconEngineExceptionTransactionTypes
  [
    {
      text: "Edit entry",
      icon: "nd-pencil-edit-box",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(EditEntry),
      onClick: () => setExceptionStage(_ => ResolvingException(EditEntry)),
      buttonType: Secondary,
    },
    {
      text: "Mark as received",
      icon: "nd-check-circle-outline",
      iconClass: "text-nd_gray-600",
      condition: showMarkAsReceivedButton,
      onClick: () => setExceptionStage(_ => ResolvingException(MarkAsReceived)),
      buttonType: Secondary,
    },
    {
      text: "Create new entry",
      icon: "nd-plus",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(CreateNewEntry),
      onClick: () => {
        setExceptionStage(_ => ResolvingException(CreateNewEntry))
        setActiveModal(_ => Some(CreateEntryModal))
      },
      buttonType: Secondary,
    },
    {
      text: "Replace Entry",
      icon: "nd-swap-arrow-horizontal",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(ReplaceStagingEntryToTransaction),
      onClick: () => setExceptionStage(_ => ResolvingException(ReplaceStagingEntryToTransaction)),
      buttonType: Secondary,
    },
    {
      text: "Link Entry",
      icon: "nd-permalink",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(LinkStagingEntryToTransaction),
      onClick: () => {
        setExceptionStage(_ => ResolvingException(LinkStagingEntryToTransaction))
        setActiveModal(_ => Some(LinkStagingEntriesModal))
      },
      buttonType: Secondary,
    },
  ]
}

let getMainResolutionButtons = (~isResolutionAvailable, ~setExceptionStage, ~setActiveModal): array<
  ReconEngineExceptionsTypes.buttonConfig,
> => {
  open ReconEngineExceptionTransactionTypes
  [
    {
      text: "Force Match",
      icon: "nd-check-circle-outline",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(ForceReconcile),
      onClick: () => {
        setExceptionStage(_ => ResolvingException(ForceReconcile))
        setActiveModal(_ => Some(ForceReconcileModal))
      },
      buttonType: Secondary,
    },
    {
      text: "Ignore Transaction",
      icon: "nd-delete-dustbin-02",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(VoidTransaction),
      onClick: () => {
        setExceptionStage(_ => ResolvingException(VoidTransaction))
        setActiveModal(_ => Some(IgnoreTransactionModal))
      },
      buttonType: Secondary,
    },
  ]
}

let getBottomBarConfig = (~exceptionStage, ~selectedRows, ~setActiveModal) => {
  open ReconEngineExceptionsTypes
  open ReconEngineExceptionTransactionTypes
  switch exceptionStage {
  | ResolvingException(EditEntry) =>
    Some({
      prompt: "Select entry to edit",
      buttonText: "Edit entry",
      buttonEnabled: selectedRows->Array.length > 0,
      onClick: () => setActiveModal(_ => Some(EditEntryModal)),
    })
  | ResolvingException(MarkAsReceived) =>
    Some({
      prompt: "Select entry to resolve",
      buttonText: "Continue",
      buttonEnabled: selectedRows->Array.length > 0,
      onClick: () => setActiveModal(_ => Some(MarkAsReceivedModal)),
    })
  | ResolvingException(ReplaceStagingEntryToTransaction) =>
    Some({
      prompt: "Select entry to replace",
      buttonText: "Continue",
      buttonEnabled: selectedRows->Array.length > 0,
      onClick: () => setActiveModal(_ => Some(LinkStagingEntriesModal)),
    })
  | _ => None
  }
}
