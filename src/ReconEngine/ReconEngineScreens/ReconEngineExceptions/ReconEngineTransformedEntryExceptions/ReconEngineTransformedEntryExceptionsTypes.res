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

type modalLayout = CenterModal | SidePanelModal | ExpandedSidePanelModal

type buttonConfig = {
  text: string,
  icon: string,
  iconClass: string,
  condition: bool,
  onClick: unit => unit,
  buttonType: Button.buttonType,
}

type bottomBarConfig = {
  prompt: string,
  buttonText: string,
  buttonEnabled: bool,
  onClick: unit => unit,
}

type resolutionConfig = {
  heading: string,
  description?: string,
  layout: modalLayout,
  closeOnOutsideClick: bool,
}
