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

type resolutionOptionTypes =
  | IgnoreTransaction
  | FixEntries
  | NoResolutionOptionNeeded

type exceptionResolutionStage =
  | ShowResolutionOptions(resolutionOptionTypes)
  | ResolvingException(resolvingException)
  | ConfirmResolution(resolvingException)
  | ExceptionResolved

type metadataRow = {
  id: string,
  key: string,
  value: string,
}

type modalLayout = CenterModal | SidePanelModal

type resolutionConfig = {
  heading: string,
  description?: string,
  layout: modalLayout,
  closeOnOutsideClick: bool,
}

type accountInfo = {
  account_info_name: string,
  account_info_type: string,
}
