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

type validationRule = (string, Dict.t<JSON.t> => option<string>)

type tableSection = {
  titleElement: React.element,
  rows: array<array<Table.cell>>,
  rowData: array<RescriptCore.JSON.t>,
}
