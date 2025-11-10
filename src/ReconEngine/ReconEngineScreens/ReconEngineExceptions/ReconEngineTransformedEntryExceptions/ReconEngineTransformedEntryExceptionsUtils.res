open ReconEngineTypes
open LogicUtils
open ReconEngineTransformedEntryExceptionsTypes
open ReconEngineExceptionsUtils
open ReconEngineTransactionsUtils

let sortByVersion = (c1: processingEntryType, c2: processingEntryType) => {
  compareLogic(c1.version, c2.version)
}

let getInnerVariant = (stage: exceptionResolutionStage): resolvingException =>
  switch stage {
  | ResolvingTransformedEntry(resolvingEx) => resolvingEx
  | ConfirmTransformedEntryResolution(resolvingEx) => resolvingEx
  | _ => NoTransformedEntryResolutionNeeded
  }

let mapResolutionActionFromString = (str: string): resolvingException => {
  switch str {
  | "void_staging_entry" => VoidTransformedEntry
  | "edit_staging_entry" => EditTransformedEntry
  | _ => NoTransformedEntryResolutionNeeded
  }
}

let getGroupedEntriesAndAccountMaps = (~updatedEntriesList: array<processingEntryType>): Dict.t<
  array<processingEntryType>,
> => {
  let groupDict = Dict.make()
  updatedEntriesList->Array.forEach(entry => {
    let accountId = entry.account.account_id
    let existingEntries = groupDict->Dict.get(accountId)->Option.getOr([])
    groupDict->Dict.set(accountId, existingEntries->Array.concat([entry]))
  })

  groupDict
}

let getMainResolutionButtons = (~isResolutionAvailable, ~setExceptionStage, ~setActiveModal): array<
  buttonConfig,
> => {
  [
    {
      text: "Ignore Entry",
      icon: "nd-delete-dustbin-02",
      iconClass: "text-nd_gray-600",
      condition: isResolutionAvailable(VoidTransformedEntry),
      onClick: () => {
        setExceptionStage(_ => ResolvingTransformedEntry(VoidTransformedEntry))
        setActiveModal(_ => Some(VoidTransformedEntryModal))
      },
      buttonType: Secondary,
    },
    {
      text: "Edit Entry",
      icon: "nd-pencil-edit-box",
      iconClass: "text-white",
      condition: isResolutionAvailable(EditTransformedEntry),
      onClick: () => {
        setExceptionStage(_ => ResolvingTransformedEntry(EditTransformedEntry))
        setActiveModal(_ => Some(EditTransformedEntryModal))
      },
      buttonType: Primary,
    },
  ]
}

let parseResolutionActions = (json: JSON.t): array<resolvingException> => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getStringFromJson("")->mapResolutionActionFromString)
  ->Array.filter(action => action !== NoTransformedEntryResolutionNeeded)
}

let initialDisplayFilters = (~accountOptions) => {
  let entryTypeOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Credit", value: "credit"},
    {label: "Debit", value: "debit"},
  ]

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
          ~label="Account",
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
  ]
}

let getResolutionModalConfig = (exceptionStage: exceptionResolutionStage): resolutionConfig => {
  switch exceptionStage {
  | ResolvingTransformedEntry(VoidTransformedEntry) => {
      heading: "Ignore Entry",
      description: "This action cannot be undone. Are you sure you want to ignore this entry?",
      layout: CenterModal,
      closeOnOutsideClick: true,
    }
  | ResolvingTransformedEntry(EditTransformedEntry) => {
      heading: "Edit Entry",
      layout: SidePanelModal,
      closeOnOutsideClick: false,
    }
  | _ => {
      heading: "",
      layout: CenterModal,
      closeOnOutsideClick: true,
    }
  }
}

let validateReasonField = (values: JSON.t) => {
  let data = values->getDictFromJsonObject
  let errors = Dict.make()

  let errorMessage = if data->getString("reason", "")->isEmptyString {
    "Remark cannot be empty!"
  } else {
    ""
  }
  if errorMessage->isNonEmptyString {
    Dict.set(errors, "Error", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}

let getInitialValuesForEditEntries = (entryDetails: processingEntryType) => {
  let account = [
    ("account_id", entryDetails.account.account_id->JSON.Encode.string),
    ("account_name", entryDetails.account.account_name->JSON.Encode.string),
  ]
  let fields = [
    ("account", account->Dict.fromArray->JSON.Encode.object),
    ("entry_type", (entryDetails.entry_type :> string)->JSON.Encode.string),
    ("currency", entryDetails.currency->JSON.Encode.string),
    ("amount", entryDetails.amount->JSON.Encode.float),
    ("order_id", entryDetails.order_id->JSON.Encode.string),
    ("effective_at", entryDetails.effective_at->JSON.Encode.string),
    ("transformation_id", entryDetails.transformation_id->JSON.Encode.string),
    (
      "metadata",
      entryDetails.metadata
      ->getFilteredMetadataFromEntries
      ->JSON.Encode.object,
    ),
  ]
  fields->Dict.fromArray->JSON.Encode.object
}

let hasFormValuesChanged = (
  currentValues: JSON.t,
  initialEntryDetails: processingEntryType,
): bool => {
  let currentData = currentValues->getDictFromJsonObject
  let initialMetadata = initialEntryDetails.metadata->getFilteredMetadataFromEntries

  let accountData = currentData->getDictfromDict("account")
  let isAccountIdChanged =
    accountData->getString("account_id", "") != initialEntryDetails.account.account_id
  let isAccountNameChanged =
    accountData->getString("account_name", "") != initialEntryDetails.account.account_name
  let isEntryTypeChanged =
    currentData->getString("entry_type", "") != (initialEntryDetails.entry_type :> string)
  let isAmountChanged = currentData->getFloat("amount", 0.0) != initialEntryDetails.amount
  let isEffectiveAtChanged =
    currentData->getString("effective_at", "") != initialEntryDetails.effective_at
  let isTransformationConfigChanged =
    currentData->getString("transformation_id", "") != initialEntryDetails.transformation_id
  let isMetadataChanged = {
    let currentMetadata = currentData->getJsonObjectFromDict("metadata")
    let currentMetadataJson = currentMetadata
    let initialMetadataJson = initialMetadata->JSON.Encode.object
    currentMetadataJson->JSON.stringify != initialMetadataJson->JSON.stringify
  }
  let isOrderIdChanged = currentData->getString("order_id", "") != initialEntryDetails.order_id

  isAccountIdChanged ||
  isAccountNameChanged ||
  isEntryTypeChanged ||
  isAmountChanged ||
  isEffectiveAtChanged ||
  isMetadataChanged ||
  isOrderIdChanged ||
  isTransformationConfigChanged
}

let validateEditEntryDetails = (
  values: JSON.t,
  ~initialEntryDetails: processingEntryType,
): JSON.t => {
  let data = values->getDictFromJsonObject

  let accountData = data->getDictfromDict("account")

  let validationRules = [
    (
      "account",
      accountData->getString("account_id", "")->isEmptyString
        ? requiredString("account.account_id", "Account cannot be empty!")
        : _ => None,
    ),
    ("entry_type", requiredString("entry_type", "Cannot be empty!")),
    ("currency", requiredString("currency", "Cannot be empty!")),
    ("order_id", requiredString("order_id", "Cannot be empty!")),
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

let getUpdatedEntry = (~entryDetails: processingEntryType, ~formData): processingEntryType => {
  let accountData = formData->getDictfromDict("account")
  {
    id: entryDetails.id,
    staging_entry_id: entryDetails.staging_entry_id,
    account: {
      account_id: accountData->getString("account_id", ""),
      account_name: accountData->getString("account_name", ""),
    },
    entry_type: formData->getString("entry_type", ""),
    amount: formData->getFloat("amount", 0.0),
    currency: formData->getString("currency", ""),
    status: Pending,
    processing_mode: entryDetails.processing_mode,
    metadata: formData->getJsonObjectFromDict("metadata"),
    transformation_id: formData->getString("transformation_id", ""),
    transformation_history_id: entryDetails.transformation_history_id,
    effective_at: formData->getString("effective_at", ""),
    order_id: formData->getString("order_id", ""),
    discarded_status: entryDetails.discarded_status,
    version: entryDetails.version,
    data: entryDetails.data,
  }
}

let generateResolutionSummary = (
  ~currentEntry: processingEntryType,
  ~updatedEntry: processingEntryType,
): array<string> => {
  let summary = []

  if (currentEntry.entry_type :> string) != (updatedEntry.entry_type :> string) {
    let message = `Direction changed to ${(updatedEntry.entry_type :> string)->capitalizeString}.`
    summary->Array.push(message)
  }

  if currentEntry.account.account_id != updatedEntry.account.account_id {
    let message = `Account changed to ${updatedEntry.account.account_name} account.`
    summary->Array.push(message)
  }

  if currentEntry.currency != updatedEntry.currency {
    let message = `Currency edited from ${currentEntry.currency} to ${updatedEntry.currency}.`
    summary->Array.push(message)
  }

  if currentEntry.amount != updatedEntry.amount {
    let message = `Amount edited from ${updatedEntry.currency} ${currentEntry.amount->Float.toString} to ${updatedEntry.currency} ${updatedEntry.amount->Float.toString}.`
    summary->Array.push(message)
  }

  if currentEntry.order_id != updatedEntry.order_id {
    let message = `Order ID changed to ${updatedEntry.order_id}.`
    summary->Array.push(message)
  }

  if currentEntry.effective_at != updatedEntry.effective_at {
    let message = `Effective at changed to ${DateTimeUtils.getFormattedDate(
        updatedEntry.effective_at,
        "DD MMMM YYYY, hh:mm A",
      )}.`
    summary->Array.push(message)
  }

  if currentEntry.transformation_id != updatedEntry.transformation_id {
    let message = `Transformation Config changed to ${updatedEntry.transformation_id}.`
    summary->Array.push(message)
  }

  let initialMetadata = currentEntry.metadata->getFilteredMetadataFromEntries->JSON.Encode.object
  let updatedMetadata = updatedEntry.metadata->getFilteredMetadataFromEntries->JSON.Encode.object

  if initialMetadata->JSON.stringify != updatedMetadata->JSON.stringify {
    let message = "Metadata fields updated."
    summary->Array.push(message)
  }

  summary
}

let constructManualReconciliationBody = (~updatedEntry: processingEntryType, ~values): JSON.t => {
  let valuesDict = values->getDictFromJsonObject
  let reason = valuesDict->getString("reason", "")

  [
    ("reason", reason->JSON.Encode.string),
    ("account_id", updatedEntry.account.account_id->JSON.Encode.string),
    ("entry_type", (updatedEntry.entry_type :> string)->JSON.Encode.string),
    ("amount", updatedEntry.amount->JSON.Encode.float),
    ("currency", updatedEntry.currency->JSON.Encode.string),
    ("order_id", updatedEntry.order_id->JSON.Encode.string),
    ("effective_at", updatedEntry.effective_at->JSON.Encode.string),
    ("transformation_id", updatedEntry.transformation_id->JSON.Encode.string),
    ("metadata", updatedEntry.metadata),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}
