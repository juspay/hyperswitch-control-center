type resolvingException =
  | VoidTransformedEntry
  | EditTransformedEntry
  | NoTransformedEntryResolutionNeeded

type activeModal =
  | VoidTransformedEntryModal
  | EditTransformedEntryModal

type resolutionOptionTypes =
  | VoidTransformedEntryOption
  | EditTransformedEntryOption
  | NoTransformedEntryResolutionOptionNeeded

type exceptionResolutionStage =
  | ShowTransformedEntryResolutionOptions(resolutionOptionTypes)
  | ResolvingTransformedEntry(resolvingException)
  | ConfirmTransformedEntryResolution(resolvingException)
  | TransformedEntryExceptionResolved

type actionType = BulkTransformedEntryVoid | UnknownBulkTransformedEntryActionType

type iconType = {
  bulkActionIconName: string,
  bulkActionIconClass: string,
}

type modalType = {
  modalHeading: string,
  modalDescription: string,
  modalConfirmButtonText: string,
  modalConfirmButtonType: Button.buttonType,
  modalLoadingText: string,
}

type bulkActionModalConfig = {
  bulkActionIcon?: iconType,
  bulkActionModal: modalType,
}
