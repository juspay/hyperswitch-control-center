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
