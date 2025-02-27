open VerticalStepIndicatorTypes
open ReconConfigurationTypes

let sections = [
  {
    id: (#orderDataConnection: sections :> string),
    name: "Order Data Connection",
    icon: "nd-inbox",
    subSections: None,
  },
  {
    id: (#connectProcessors: sections :> string),
    name: "Connect Processors",
    icon: "nd-plugin",
    subSections: None,
  },
  {
    id: (#finish: sections :> string),
    name: "Finish",
    icon: "nd-flag",
    subSections: None,
  },
]

let getSectionVariantFromString = (section: string): sections =>
  switch section {
  | "orderDataConnection" => #orderDataConnection
  | "connectProcessors" => #connectProcessors
  | "finish" => #finish
  | _ => #orderDataConnection
  }
