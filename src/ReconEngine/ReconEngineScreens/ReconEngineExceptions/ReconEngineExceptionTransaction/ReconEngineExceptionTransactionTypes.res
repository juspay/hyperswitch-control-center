open ReconEngineTypes

type resolvingException =
  | ForceReconcile
  | VoidTransaction
  | EditEntry
  | MarkAsReceived
  | CreateNewEntry
  | LinkStagingEntriesToTransaction
  | NoResolutionActionNeeded

type activeModal =
  | IgnoreTransactionModal
  | ForceReconcileModal
  | EditEntryModal
  | CreateEntryModal
  | MarkAsReceivedModal
  | LinkStagingEntriesModal

type resolutionOptionTypes =
  | IgnoreTransaction
  | FixEntries
  | NoResolutionOptionNeeded

type exceptionResolutionStage =
  | ShowResolutionOptions(resolutionOptionTypes)
  | ResolvingException(resolvingException)
  | ConfirmResolution(resolvingException)
  | ExceptionResolved

type accountInfo = {
  account_info_name: string,
  account_info_type: accountTypeVariant,
}

type tableSection = {
  titleElement?: React.element,
  rows: array<array<Table.cell>>,
  rowData: array<RescriptCore.JSON.t>,
}

// Extended entry type for exception resolution with UI-specific fields
type exceptionResolutionEntryType = {
  ...entryType,
  entry_key: string,
}
