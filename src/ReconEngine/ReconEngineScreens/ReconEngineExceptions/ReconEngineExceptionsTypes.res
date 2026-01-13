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

type metadataRow = {
  id: string,
  key: string,
  value: string,
}

type validationRule = (string, Dict.t<JSON.t> => option<string>)
