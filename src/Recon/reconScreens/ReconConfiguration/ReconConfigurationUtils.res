open VerticalStepIndicatorTypes
open ReconConfigurationTypes

let sections = [
  {
    id: (#connectOrderData: sections :> string),
    name: "Order Data Connection",
    icon: "nd-inbox",
    subSections: None,
  },
  {
    id: (#connectProcessorData: sections :> string),
    name: "Connect Processors",
    icon: "nd-plugin",
    subSections: None,
  },
  {
    id: (#manualMapping: sections :> string),
    name: "Finish",
    icon: "nd-flag",
    subSections: None,
  },
]

let getSubSectionVariantFromString = (subSection: option<string>): subSections =>
  switch subSection {
  | Some("selectSource") => #selectSource
  | Some("setupAPIConnection") => #setupAPIConnection
  | Some("apiKeysAndLiveEndpoints") => #apiKeysAndLiveEndpoints
  | Some("webHooks") => #webHooks
  | Some("testLivePayment") => #testLivePayment
  | Some("setupCompleted") => #setupCompleted
  | _ => #selectSource
  }

let getSectionVariantFromString = (section: string): sections =>
  switch section {
  | "connectOrderData" => #connectOrderData
  | "connectProcessorData" => #connectProcessorData
  | "manualMapping" => #manualMapping
  | _ => #connectOrderData
  }

// let sectionsArr: array<sections> = [ConnectOrderData, ConnectProcessorData, ManualMapping]

// let subSectionsArr: array<subSections> = [
//   SelectSource,
//   SetupAPIConnection,
//   APIKeysAndLiveEndpoints,
//   WebHooks,
//   TestLivePayment,
//   SetupCompleted,
// ]

// let getSectionName = (section: sections): string =>
//   switch section {
//   | ConnectOrderData => "Order Data Related"
//   | ConnectProcessorData => "Connect Processors"
//   | ManualMapping => "Review Details"
//   }

// let getSectionCount = (section: sections): int =>
//   sectionsArr->Array.findIndex(item => item === section) + 1

// let getSectionFromStep = (step: steps): sections =>
//   switch step {
//   | ConnectOrderData(_) => ConnectOrderData
//   | ConnectProcessorData(_) => ConnectProcessorData
//   | ManualMapping(_) => ManualMapping
//   }

// let getIconName = (step: sections): string =>
//   switch step {
//   | ConnectOrderData => "nd-inbox"
//   | ConnectProcessorData => "nd-plugin"
//   | ManualMapping => "nd-flag"
//   }

// let getSubsectionName = (subSection: subSections): string =>
//   switch subSection {
//   | SelectSource => "Select Order Management"
//   | SetupAPIConnection => "Select Base File"
//   | APIKeysAndLiveEndpoints => "Select a processor"
//   | WebHooks => "Select PSP File"
//   | TestLivePayment => "Review"
//   | SetupCompleted => "Setup Completed"
//   }

// let getSubsectionFromStep = (section: steps): subSections =>
//   switch section {
//   | ConnectOrderData(SelectSource) => SelectSource
//   | ConnectOrderData(SetupAPIConnection) => SetupAPIConnection
//   | ConnectProcessorData(APIKeysAndLiveEndpoints) => APIKeysAndLiveEndpoints
//   | ConnectProcessorData(WebHooks) => WebHooks
//   | ManualMapping(TestLivePayment) => TestLivePayment
//   | ManualMapping(SetupCompleted) => SetupCompleted
//   }

// let getSubSections = (section: sections): array<subSections> =>
//   switch section {
//   | ConnectOrderData => [SelectSource, SetupAPIConnection]
//   | ConnectProcessorData => [APIKeysAndLiveEndpoints, WebHooks]
//   | ManualMapping => [TestLivePayment, SetupCompleted]
//   }

// let getNextStep = (currentStep: steps): steps => {
//   switch currentStep {
//   | ConnectOrderData(SelectSource) => ConnectOrderData(SetupAPIConnection)
//   | ConnectOrderData(SetupAPIConnection) => ConnectProcessorData(APIKeysAndLiveEndpoints)
//   | ConnectProcessorData(APIKeysAndLiveEndpoints) => ConnectProcessorData(WebHooks)
//   | ConnectProcessorData(WebHooks) => ManualMapping(TestLivePayment)
//   | ManualMapping(TestLivePayment) => ManualMapping(SetupCompleted)
//   | ManualMapping(SetupCompleted) => ConnectOrderData(SelectSource)
//   }
// }

// let getPreviousStep = (currentStep: steps): steps =>
//   switch currentStep {
//   | ConnectOrderData(SetupAPIConnection) => ConnectOrderData(SelectSource)
//   | ConnectProcessorData(APIKeysAndLiveEndpoints) => ConnectOrderData(SetupAPIConnection)
//   | ConnectProcessorData(WebHooks) => ConnectProcessorData(APIKeysAndLiveEndpoints)
//   | ManualMapping(TestLivePayment) => ConnectProcessorData(WebHooks)
//   | ManualMapping(SetupCompleted) => ManualMapping(TestLivePayment)
//   | ConnectOrderData(SelectSource) => ConnectOrderData(SelectSource)
//   }

// let getPercentage = (currentStep: steps): int => {
//   let findIndex =
//     subSectionsArr->Array.findIndex(item => item === currentStep->getSubsectionFromStep)
//   let totalSteps = subSectionsArr->Array.length
//   let percentage = findIndex * 100 / totalSteps
//   percentage
// }

// let isFirstStep = (currentStep: steps): bool =>
//   switch currentStep {
//   | ConnectOrderData(SelectSource) => true
//   | _ => false
//   }

// let isLastStep = (currentStep: steps): bool =>
//   switch currentStep {
//   | ManualMapping(SetupCompleted) => true
//   | _ => false
//   }
