open VerticalStepIndicatorTypes
open ReconConfigurationTypes

let getVariantFromSectionString = (str: string): reconConfigurationSections => {
  switch str {
  | "connectOrderData" => #connectOrderData
  | "connectProcessorData" => #connectProcessorData
  | "reviewDetails" => #reviewDetails
  | _ => #connectOrderData
  }
}

let getVariantFromSubsectionString = (str: option<string>): reconConfigurationSubsections => {
  switch str {
  | Some("selectSource") => #selectSource
  | Some("setupAPIConnection") => #setupAPIConnection
  | Some("apiKeysAndLiveEndpoints") => #apiKeysAndLiveEndpoints
  | Some("webHooks") => #webHooks
  | Some("testLivePayment") => #testLivePayment
  | Some("setupCompleted") => #setupCompleted
  | _ => #selectSource
  }
}

let sections = [
  {
    id: (#connectOrderData: reconConfigurationSections :> string),
    name: "Order Data Related",
    icon: "nd-inbox",
    subSections: Some([
      {
        id: (#selectSource: reconConfigurationSubsections :> string),
        name: "Select Order Management",
      },
      {
        id: (#setupAPIConnection: reconConfigurationSubsections :> string),
        name: "Select Base File",
      },
    ]),
  },
  {
    id: (#connectProcessorData: reconConfigurationSections :> string),
    name: "Connect Processors",
    icon: "nd-plugin",
    subSections: Some([
      {
        id: (#apiKeysAndLiveEndpoints: reconConfigurationSubsections :> string),
        name: "Select a processor",
      },
      {id: (#webHooks: reconConfigurationSubsections :> string), name: "Select PSP File"},
    ]),
  },
  {
    id: (#reviewDetails: reconConfigurationSections :> string),
    name: "Review Details",
    icon: "nd-flag",
    subSections: Some([
      {id: (#testLivePayment: reconConfigurationSubsections :> string), name: "Review"},
      {id: (#setupCompleted: reconConfigurationSubsections :> string), name: "Setup Completed"},
    ]),
  },
]
