open ReconEngineFilterUtils
open ReconEngineTypes
open LogicUtils
open ReconEngineUtils
open ReconEngineTransactionsUtils
open ReconEngineExceptionTransactionTypes

let initialDisplayFilters = (~creditAccountOptions=[], ~debitAccountOptions=[], ()) => {
  let statusOptions = getTransactionStatusOptions([Expected, Mismatched, PartiallyReconciled])
  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="transaction_status",
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

let getSumOfAmountWithCurrency = (entries: array<entryType>): (float, string) => {
  let totalAmount = entries->Array.reduce(0.0, (acc, entry) => acc +. entry.amount)
  let entry = entries->getValueFromArray(0, Dict.make()->entryItemToObjMapper)
  (totalAmount, entry.currency)
}

let getBalanceByAccountType = (entries: array<entryType>, accountType: string): (float, string) => {
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
  ~accountInfoMap: Dict.t<accountInfo>,
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

let validateReasonField = (values: JSON.t) => {
  let data = values->getDictFromJsonObject
  let errors = Dict.make()

  let errorMessage = if data->getString("reason", "")->isEmptyString {
    "Reason cannot be empty!"
  } else {
    ""
  }
  if errorMessage->isNonEmptyString {
    Dict.set(errors, "Error", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}

let exceptionTransactionEntryItemToItemMapper = dict => {
  {
    entry_id: dict->getString("entry_id", "-"),
    entry_type: dict->getString("entry_type", "")->getEntryTypeVariantFromString,
    transaction_id: dict->getString("transaction_id", ""),
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
    amount: dict->getFloat("amount", 0.0),
    currency: dict->getString("currency", ""),
    status: dict->getString("status", "")->getEntryStatusVariantFromString,
    discarded_status: dict->getOptionString("discarded_status"),
    version: dict->getInt("version", 0),
    metadata: dict->getJsonObjectFromDict("metadata"),
    data: dict->getJsonObjectFromDict("data"),
    created_at: dict->getString("created_at", Date.make()->Date.toISOString),
    effective_at: dict->getString("effective_at", ""),
    staging_entry_id: dict->getOptionString("staging_entry_id"),
  }
}

let exceptionTransactionProcessingEntryItemToObjMapper = dict => {
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
  }
}

let hasFormValuesChanged = (currentValues: JSON.t, initialEntryDetails: entryType): bool => {
  let currentData = currentValues->getDictFromJsonObject
  let initialMetadata = initialEntryDetails.metadata->getFilteredMetadataFromEntries

  let isEntryTypeChanged =
    currentData->getString("entry_type", "") != (initialEntryDetails.entry_type :> string)
  let isAmountChanged = currentData->getFloat("amount", 0.0) != initialEntryDetails.amount
  let isEffectiveAtChanged =
    currentData->getString("effective_at", "") != initialEntryDetails.effective_at
  let isMetadataChanged = {
    let currentMetadata = currentData->getJsonObjectFromDict("metadata")
    let currentMetadataJson = currentMetadata
    let initialMetadataJson = initialMetadata->JSON.Encode.object
    currentMetadataJson->JSON.stringify != initialMetadataJson->JSON.stringify
  }

  isEntryTypeChanged || isAmountChanged || isEffectiveAtChanged || isMetadataChanged
}

let validateFields = (data: Dict.t<JSON.t>, rules: array<validationRule>): JSON.t => {
  rules
  ->Array.filterMap(((fieldName, validator)) => {
    switch validator(data) {
    | Some(errorMessage) => Some((fieldName, errorMessage->JSON.Encode.string))
    | None => None
    }
  })
  ->Dict.fromArray
  ->JSON.Encode.object
}

let requiredString = (fieldName: string, errorMsg: string) => {
  (data: Dict.t<JSON.t>) => data->getString(fieldName, "")->isEmptyString ? Some(errorMsg) : None
}

let positiveFloat = (fieldName: string, errorMsg: string) => {
  (data: Dict.t<JSON.t>) => data->getFloat(fieldName, -1.0) <= 0.0 ? Some(errorMsg) : None
}

let validateCreateEntryDetails = (values: JSON.t): JSON.t => {
  let data = values->getDictFromJsonObject

  let validationRules = [
    ("account", requiredString("account", "Cannot be empty!")),
    ("entry_type", requiredString("entry_type", "Cannot be empty!")),
    ("currency", requiredString("currency", "Cannot be empty!")),
    ("effective_at", requiredString("effective_at", "Cannot be empty!")),
    ("amount", positiveFloat("amount", "Should be greater than 0!")),
  ]

  validateFields(data, validationRules)
}

let validateEditEntryDetails = (values: JSON.t, ~initialEntryDetails: entryType): JSON.t => {
  let data = values->getDictFromJsonObject

  let validationRules = [
    ("account", requiredString("account", "Cannot be empty!")),
    ("entry_type", requiredString("entry_type", "Cannot be empty!")),
    ("currency", requiredString("currency", "Cannot be empty!")),
    ("effective_at", requiredString("effective_at", "Cannot be empty!")),
    ("amount", positiveFloat("amount", "Should be greater than 0!")),
  ]

  let fieldErrors = validateFields(data, validationRules)->getDictFromJsonObject
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
    ("effective_at", entryDetails.effective_at->JSON.Encode.string),
    ("metadata", entryDetails.metadata->getFilteredMetadataFromEntries->JSON.Encode.object),
    (
      "staging_entry_id",
      switch entryDetails.staging_entry_id {
      | Some(id) => id->JSON.Encode.string
      | None => JSON.Encode.null
      },
    ),
  ]
  fields->Dict.fromArray->JSON.Encode.object
}

let getConvertedEntriesFromStagingEntry = (
  stagingEntry: processingEntryType,
  entryDetails: entryType,
) => {
  [
    ("account_id", stagingEntry.account.account_id->JSON.Encode.string),
    ("account_name", stagingEntry.account.account_name->JSON.Encode.string),
    ("entry_id", entryDetails.entry_id->JSON.Encode.string),
    ("entry_type", stagingEntry.entry_type->JSON.Encode.string),
    ("currency", stagingEntry.currency->JSON.Encode.string),
    ("amount", stagingEntry.amount->JSON.Encode.float),
    ("effective_at", stagingEntry.effective_at->JSON.Encode.string),
    ("metadata", stagingEntry.metadata),
    ("staging_entry_id", stagingEntry.id->JSON.Encode.string),
    ("status", "pending"->JSON.Encode.string),
    ("data", [("status", "pending"->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let getInitialValuesForNewEntries = () => {
  let todayDate = Js.Date.make()->Js.Date.toISOString

  let fields = [("effective_at", todayDate->JSON.Encode.string)]
  fields->Dict.fromArray->JSON.Encode.object
}

let getInnerVariant = (stage: exceptionResolutionStage): resolvingException =>
  switch stage {
  | ResolvingException(resolvingEx) => resolvingEx
  | ConfirmResolution(resolvingEx) => resolvingEx
  | _ => NoResolutionActionNeeded
  }

let generateResolutionSummary = (initialEntry: entryType, updatedEntry: entryType): array<
  string,
> => {
  let summary = []

  if (initialEntry.entry_type :> string) != (updatedEntry.entry_type :> string) {
    let message = `Direction changed to ${(updatedEntry.entry_type :> string)->capitalizeString} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)->ignore
  }

  if initialEntry.amount != updatedEntry.amount {
    let message = `Amount edited from ${updatedEntry.currency} ${initialEntry.amount->Float.toString} to ${updatedEntry.currency} ${updatedEntry.amount->Float.toString} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)->ignore
  }

  if initialEntry.effective_at != updatedEntry.effective_at {
    let message = `Effective at changed to ${DateTimeUtils.getFormattedDate(
        updatedEntry.effective_at,
        "DD MMMM YYYY, hh:mm A",
      )} in ${updatedEntry.account_name} account.`
    summary->Array.push(message)->ignore
  }

  let initialMetadata = initialEntry.metadata->getFilteredMetadataFromEntries
  let updatedMetadata = updatedEntry.metadata->getFilteredMetadataFromEntries
  let initialMetadataJson = initialMetadata->JSON.Encode.object
  let updatedMetadataJson = updatedMetadata->JSON.Encode.object

  if initialMetadataJson->JSON.stringify != updatedMetadataJson->JSON.stringify {
    let message = `Metadata updated in ${updatedEntry.account_name} account.`
    summary->Array.push(message)->ignore
  }

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
          allSummaryItems->Array.push(item)->ignore
        })
      }
    | None => {
        let message = `New ${(updatedEntry.entry_type :> string)} entry created with ${updatedEntry.currency} ${updatedEntry.amount->Float.toString} in ${updatedEntry.account_name} account.`
        allSummaryItems->Array.push(message)->ignore
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

let constructManualReconciliationBody = (
  ~updatedEntriesList: array<entryType>,
  ~values,
): JSON.t => {
  let valuesDict = values->getDictFromJsonObject
  let reason = valuesDict->getString("reason", "")

  let entriesJson = updatedEntriesList->Array.map(entry => {
    [
      ("account_id", entry.account_id->JSON.Encode.string),
      ("entry_type", (entry.entry_type :> string)->JSON.Encode.string),
      ("amount", entry.amount->JSON.Encode.float),
      ("currency", entry.currency->JSON.Encode.string),
      ("effective_at", entry.effective_at->JSON.Encode.string),
      ("metadata", entry.metadata),
      (
        "staging_entry_id",
        switch entry.staging_entry_id {
        | Some(id) => id->JSON.Encode.string
        | None => JSON.Encode.null
        },
      ),
      ("data", entry.data),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  })

  [("reason", reason->JSON.Encode.string), ("transaction_entries", entriesJson->JSON.Encode.array)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let getResolutionModalConfig = (exceptionStage: exceptionResolutionStage) => {
  switch exceptionStage {
  | ResolvingException(VoidTransaction) => {
      heading: "Ignore Transaction",
      description: "This will ignore the transaction in the system and it won't appear in any future reconciliations.",
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
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(MarkAsReceived) => {
      heading: "Mark as Received",
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(CreateNewEntry) => {
      heading: "Create New Entry",
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | ResolvingException(LinkStagingEntriesToTransaction) => {
      heading: "Match with an existing staging entry",
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
  ~entryDetails: entryType,
  ~formData,
  ~accountData: accountRefType,
  ~markAsReceived=false,
): entryType => {
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
    account_id: accountData.account_id,
    account_name: accountData.account_name,
    transaction_id: entryDetails.transaction_id,
    amount: formData->getFloat("amount", entryDetails.amount),
    currency: formData->getString("currency", ""),
    status: statusString->getEntryStatusVariantFromString,
    discarded_status: entryDetails.discarded_status,
    version: entryDetails.version,
    metadata: formData->getJsonObjectFromDict("metadata"),
    data: Dict.fromArray([("status", statusString->JSON.Encode.string)])->JSON.Encode.object,
    created_at: entryDetails.created_at,
    effective_at: formData->getString("effective_at", entryDetails.effective_at),
    staging_entry_id: entryDetails.staging_entry_id,
  }
}

let getNewEntry = (
  ~formData,
  ~accountData: accountRefType,
  ~updatedEntriesList: array<entryType>,
): entryType => {
  {
    entry_id: "-",
    entry_type: formData->getString("entry_type", "")->getEntryTypeVariantFromString,
    account_id: accountData.account_id,
    account_name: accountData.account_name,
    transaction_id: formData->getString("transaction_id", ""),
    amount: formData->getFloat("amount", 0.0),
    currency: formData->getString("currency", ""),
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
  }
}

let getGroupedEntriesAndAccountMaps = (
  ~accountsData: array<accountType>,
  ~updatedEntriesList: array<entryType>,
): (Dict.t<array<entryType>>, Dict.t<accountInfo>) => {
  let accountInfoDict: Dict.t<accountInfo> = Dict.make()
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
  ~groupedEntries,
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
) => {
  [
    {
      text: "Edit entry",
      icon: "nd-pencil-edit-box",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(EditEntry),
      onClick: () => setExceptionStage(_ => ResolvingException(EditEntry)),
    },
    {
      text: "Mark as received",
      icon: "nd-check-circle-outline",
      iconClass: "text-nd_gray-600",
      condition: showMarkAsReceivedButton,
      onClick: () => setExceptionStage(_ => ResolvingException(MarkAsReceived)),
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
    },
    {
      text: "Replace Entry",
      icon: "nd-swap-arrow-horizontal",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(LinkStagingEntriesToTransaction),
      onClick: () => setExceptionStage(_ => ResolvingException(LinkStagingEntriesToTransaction)),
    },
  ]
}

let getMainResolutionButtons = (~isResolutionAvailable, ~setExceptionStage, ~setActiveModal) => {
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
    },
  ]
}

let getBottomBarConfig = (~exceptionStage, ~selectedRows, ~setActiveModal) => {
  let isReplaceEntryEnabled = {
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
    entryDetails.entry_id != "-"
  }
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
      buttonEnabled: isReplaceEntryEnabled,
      onClick: () => setActiveModal(_ => Some(LinkStagingEntriesModal)),
    })
  | _ => None
  }
}
