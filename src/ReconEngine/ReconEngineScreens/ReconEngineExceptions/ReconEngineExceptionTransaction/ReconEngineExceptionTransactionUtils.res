open ReconEngineFilterUtils
open ReconEngineTypes
open LogicUtils
open ReconEngineUtils
open ReconEngineTransactionsUtils

let initialDisplayFilters = (~creditAccountOptions=[], ~debitAccountOptions=[], ()) => {
  let statusOptions = getGroupedTransactionStatusOptions([
    OverAmount(Mismatch),
    OverAmount(Expected),
    UnderAmount(Mismatch),
    UnderAmount(Expected),
    DataMismatch,
    PartiallyReconciled,
    Expected,
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="source_account",
          ~name="source_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=creditAccountOptions,
            ~buttonText="Select Source Account",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="target_account",
          ~name="target_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=debitAccountOptions,
            ~buttonText="Select Target Account",
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

let getBalanceByAccountType = (
  entries: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  accountType: string,
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

  let balance = switch accountType->String.toLowerCase {
  | "credit" => totalCredits -. totalDebits
  | "debit" => totalDebits -. totalCredits
  | _ => totalCredits +. totalDebits
  }

  let currency = switch entries->Array.get(0) {
  | Some(entry) => entry.currency
  | None => ""
  }

  (balance, currency)
}

let getHeadingAndSubHeadingForMismatch = (
  mismatchData: Js.Json.t,
  ~accountInfoMap: Dict.t<ReconEngineExceptionTransactionTypes.accountInfo>,
): (string, string) => {
  let mismatchType =
    mismatchData
    ->getDictFromJsonObject
    ->getString("mismatch_type", "")
    ->getMismatchTypeVariantFromString
  let mismatchedDataDict =
    mismatchData->getDictFromJsonObject->getJsonObjectFromDict("mismatch_data")
  let accountNames = accountInfoMap->Dict.valuesToArray->Array.map(info => info.account_info_name)

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

  let mismatchSubHeading = switch mismatchType {
  | AmountMismatch =>
    `There is a ${mismatchHeading} of ${currency} ${mismatchAmount->Float.toString} found between the transaction entries`
  | MetadataMismatch =>
    `There is a ${mismatchHeading} found between ${accountNames->Array.joinWith(", ")}`
  | BalanceDirectionMismatch =>
    `There is a ${mismatchHeading} found between ${accountNames->Array.joinWith(", ")}`
  | CurrencyMismatch =>
    `There is a ${mismatchHeading} found between ${accountNames->Array.joinWith(", ")}`
  | UnknownMismatchType => "Mismatch details are unavailable."
  }

  (mismatchHeading, mismatchSubHeading)
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
  }
}

let getSumOfAmountWithCurrency = (
  entries: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
): (float, string) => {
  let totalAmount = entries->Array.reduce(0.0, (acc, entry) => acc +. entry.amount)
  let entry = entries->getValueFromArray(0, Dict.make()->exceptionTransactionEntryItemToItemMapper)
  (totalAmount, entry.currency)
}

let exceptionTransactionProcessingEntryItemToObjMapper = dict => {
  let discardedDataDict =
    dict->getDictfromDict("discarded_data")->processingEntryDiscardedDataItemToObjMapper
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
    status: dict
    ->getString("status", "")
    ->camelToSnake
    ->getProcessingEntryStatusVariantFromString,
    transformation_id: dict->getString("transformation_id", ""),
    transformation_history_id: dict->getString("transformation_history_id", ""),
    order_id: dict->getString("order_id", ""),
    version: dict->getInt("version", 0),
    discarded_status: dict->getOptionString("discarded_status"),
    data: dict->getDictfromDict("data")->processingEntryDataItemToObjMapper,
    discarded_data: discardedDataDict.status != UnknownProcessingEntryStatus
      ? Some(discardedDataDict)
      : None,
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
  let isEffectiveAtChanged =
    currentData->getString("effective_at", "") != initialEntryDetails.effective_at
  let isMetadataChanged = {
    let currentMetadataArray = currentData->getDictfromDict("metadata")->Dict.toArray
    let initialMetadataArray = initialMetadata->Dict.toArray
    currentMetadataArray->Array.length != initialMetadataArray->Array.length ||
      currentMetadataArray->Array.some(((key, value)) => {
        initialMetadata->Dict.get(key)->Option.mapOr(true, initialValue => initialValue != value)
      })
  }
  let isOrderIdChanged = currentData->getString("order_id", "") != initialEntryDetails.order_id

  isAccountChanged ||
  isTransformationConfigChanged ||
  isEntryTypeChanged ||
  isAmountChanged ||
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
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
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

let generateResolutionSummary = (initialEntry: entryType, updatedEntry: entryType): array<
  string,
> => {
  let summary = []

  if initialEntry.account_id != updatedEntry.account_id {
    let message = `Account changed to ${updatedEntry.account_name}.`
    summary->Array.push(message)
  }

  if initialEntry.transformation_id != updatedEntry.transformation_id {
    let message = switch (initialEntry.transformation_id, updatedEntry.transformation_id) {
    | (None, Some(_)) => `Transformation config added.`
    | (Some(_), None) => `Transformation config removed.`
    | (Some(_), Some(_)) => `Transformation config changed.`
    | (None, None) => ""
    }
    if message->isNonEmptyString {
      summary->Array.push(message)
    }
  }

  if initialEntry.currency != updatedEntry.currency {
    let message = `Currency changed to ${updatedEntry.currency} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)
  }

  if (initialEntry.entry_type :> string) != (updatedEntry.entry_type :> string) {
    let message = `Direction changed to ${(updatedEntry.entry_type :> string)->capitalizeString} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)
  }

  if initialEntry.amount != updatedEntry.amount {
    let message = `Amount edited from ${updatedEntry.currency} ${initialEntry.amount->Float.toString} to ${updatedEntry.currency} ${updatedEntry.amount->Float.toString} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)
  }

  if initialEntry.order_id != updatedEntry.order_id {
    let message = `Order ID changed to ${updatedEntry.order_id} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)
  }

  if initialEntry.effective_at != updatedEntry.effective_at {
    let message = `Effective at changed to ${DateTimeUtils.getFormattedDate(
        updatedEntry.effective_at,
        "DD MMMM YYYY, hh:mm A",
      )} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)
  }

  let initialMetadata = initialEntry.metadata->getFilteredMetadataFromEntries->Dict.toArray
  initialMetadata->Array.forEach(((key, initialValue)) => {
    let updatedValueStr =
      updatedEntry.metadata
      ->getFilteredMetadataFromEntries
      ->getString(key, "")

    let initialValueStr = initialValue->getStringFromJson("")
    if initialValueStr != updatedValueStr {
      let message = `Metadata field '${key}' changed from '${initialValueStr}' to '${updatedValueStr}' in ${updatedEntry.account_name} account.`
      summary->Array.push(message)
    }
  })
  summary
}

let generateAllResolutionSummaries = (
  originalEntries: array<entryType>,
  updatedEntries: array<entryType>,
): array<string> => {
  let allSummaryItems = []

  updatedEntries->Array.forEach(updatedEntry => {
    let originalEntry =
      originalEntries->Array.find(entry => entry.entry_id == updatedEntry.entry_id)

    switch originalEntry {
    | Some(original) => {
        let summaryItems = generateResolutionSummary(original, updatedEntry)
        summaryItems->Array.forEach(item => {
          allSummaryItems->Array.push(item)
        })
      }
    | None => {
        let message = `New ${(updatedEntry.entry_type :> string)} entry created with ${updatedEntry.currency} ${updatedEntry.amount->Float.toString} in ${updatedEntry.account_name} account.`
        allSummaryItems->Array.push(message)
      }
    }
  })

  allSummaryItems
}

let getUniqueCurrencyOptionsFromEntries = (entries: array<entryType>): array<
  SelectBox.dropdownOption,
> => {
  let currencySet = Set.make()
  entries->Array.forEach(entry => Set.add(currencySet, entry.currency))
  currencySet
  ->Set.values
  ->Iterator.toArray
  ->Array.map((currency): SelectBox.dropdownOption => {
    label: currency,
    value: currency,
  })
}

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

let mapResolutionActionFromString = (
  str: string,
): ReconEngineExceptionTransactionTypes.resolvingException => {
  open ReconEngineExceptionTransactionTypes
  switch str {
  | "void_transaction" => VoidTransaction
  | "link_staging_entries_to_transaction" => LinkStagingEntriesToTransaction
  | "replace_entries" => EditEntry
  | "create_entries" => CreateNewEntry
  | "force_reconcile" => ForceReconcile
  | _ => NoResolutionActionNeeded
  }
}

let parseResolutionActions = (json: JSON.t): array<
  ReconEngineExceptionTransactionTypes.resolvingException,
> => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getStringFromJson("")->mapResolutionActionFromString)
  ->Array.filter(action => action !== NoResolutionActionNeeded)
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
    entry_key: randomString(~length=16),
    transformation_id: entry.transformation_id,
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
  }
}

let constructManualReconciliationBody = (
  ~updatedEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  ~values,
): JSON.t => {
  let valuesDict = values->getDictFromJsonObject
  let reason = valuesDict->getString("reason", "")

  let entriesJson = updatedEntriesList->Array.map(entry => {
    let backendEntry = entry->getEntryTypeFromExceptionEntryType

    [
      ("account_id", backendEntry.account_id->JSON.Encode.string),
      ("entry_type", (backendEntry.entry_type :> string)->JSON.Encode.string),
      ("amount", backendEntry.amount->JSON.Encode.float),
      ("currency", backendEntry.currency->JSON.Encode.string),
      ("order_id", backendEntry.order_id->JSON.Encode.string),
      ("effective_at", backendEntry.effective_at->JSON.Encode.string),
      ("metadata", backendEntry.metadata),
      (
        "staging_entry_id",
        switch backendEntry.staging_entry_id {
        | Some(id) => id->JSON.Encode.string
        | None => JSON.Encode.null
        },
      ),
      ("data", backendEntry.data),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  })

  [("reason", reason->JSON.Encode.string), ("transaction_entries", entriesJson->JSON.Encode.array)]
  ->Dict.fromArray
  ->JSON.Encode.object
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
      heading: "Force Reconcile",
      description: "This action will mark the transaction as reconciled.",
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
  | ResolvingException(LinkStagingEntriesToTransaction) => {
      heading: "Match with an existing transformed entry",
      description: "Allows you to replace the existing entry with the correct transformed entries",
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
    account_name: formData->getString("account_name", ""),
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
  }
}

let getNewEntry = (
  ~formData,
  ~updatedEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
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
    version: updatedEntriesList->Array.reduce(0, (max, entry) =>
      max > entry.version ? max : entry.version
    ),
    metadata: formData->getJsonObjectFromDict("metadata"),
    data: Dict.fromArray([("status", "pending"->JSON.Encode.string)])->JSON.Encode.object,
    created_at: Date.make()->Date.toISOString,
    effective_at: formData->getString("effective_at", ""),
    staging_entry_id: None,
    entry_key: uniqueId,
    transformation_id: formData->getOptionString("transformation_id"),
  }
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
) => {
  open ReconEngineExceptionTransactionTypes

  groupedEntries
  ->Dict.keysToArray
  ->Array.map(accountId => {
    let accountInfo =
      accountInfoMap
      ->getvalFromDict(accountId)
      ->Option.getOr({account_info_name: "", account_info_type: ""})
    let accountEntries = groupedEntries->getvalFromDict(accountId)->Option.getOr([])

    let (totalAmount, currency) = if accountInfo.account_info_type->isNonEmptyString {
      getBalanceByAccountType(accountEntries, accountInfo.account_info_type)
    } else {
      getSumOfAmountWithCurrency(accountEntries)
    }

    (accountId, accountInfo, accountEntries, totalAmount, currency)
  })
}

let calculateOverallBalance = sectionData => {
  open ReconEngineExceptionTransactionTypes

  let (totalCreditAccounts, totalDebitAccounts) = sectionData->Array.reduce((0.0, 0.0), (
    (creditSum, debitSum),
    (_, accountInfo, _, amount, _),
  ) => {
    if accountInfo.account_info_type->String.toLowerCase == "credit" {
      (creditSum +. amount, debitSum)
    } else if accountInfo.account_info_type->String.toLowerCase == "debit" {
      (creditSum, debitSum +. amount)
    } else {
      (creditSum, debitSum)
    }
  })

  totalCreditAccounts -. totalDebitAccounts
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
      condition: isResolutionAvailable(LinkStagingEntriesToTransaction),
      onClick: () => setExceptionStage(_ => ResolvingException(LinkStagingEntriesToTransaction)),
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
      text: "Force Reconcile",
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
  | ResolvingException(LinkStagingEntriesToTransaction) =>
    Some({
      prompt: "Select entry to replace",
      buttonText: "Continue",
      buttonEnabled: selectedRows->Array.length > 0,
      onClick: () => setActiveModal(_ => Some(LinkStagingEntriesModal)),
    })
  | _ => None
  }
}
