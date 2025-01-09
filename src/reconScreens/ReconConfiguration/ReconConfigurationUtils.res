open ReconConfigurationTypes

let sectionsArr: array<sections> = [ConnectOrderData, ConnectProcessorData, ManualMapping]

let subSectionsArr: array<subSections> = [
  SelectSource,
  ConnectionType,
  APIKeysAndLiveEndpoints,
  WebHooks,
  TestLivePayment,
  SetupCompleted,
]

let getSectionName = (section: sections): string =>
  switch section {
  | ConnectOrderData => "Connect Order Data"
  | ConnectProcessorData => "Connect Processor Data"
  | ManualMapping => "Manual Mapping"
  }

let getSectionFromStep = (step: steps): sections =>
  switch step {
  | ConnectOrderData(_) => ConnectOrderData
  | ConnectProcessorData(_) => ConnectProcessorData
  | ManualMapping(_) => ManualMapping
  }

let getSubsectionName = (subSection: subSections): string =>
  switch subSection {
  | SelectSource => "Select Source"
  | ConnectionType => "Setup your Connection Type"
  | APIKeysAndLiveEndpoints => "Replace API keys & Live Endpoints"
  | WebHooks => "Setup Webhook on your end"
  | TestLivePayment => "Test a live Payment"
  | SetupCompleted => "Setup Completed"
  }

let getSubsectionFromStep = (section: steps): subSections =>
  switch section {
  | ConnectOrderData(SelectSource) => SelectSource
  | ConnectOrderData(ConnectionType) => ConnectionType
  | ConnectProcessorData(APIKeysAndLiveEndpoints) => APIKeysAndLiveEndpoints
  | ConnectProcessorData(WebHooks) => WebHooks
  | ManualMapping(TestLivePayment) => TestLivePayment
  | ManualMapping(SetupCompleted) => SetupCompleted
  }

let getSubSections = (section: sections): array<subSections> =>
  switch section {
  | ConnectOrderData => [SelectSource, ConnectionType]
  | ConnectProcessorData => [APIKeysAndLiveEndpoints, WebHooks]
  | ManualMapping => [TestLivePayment, SetupCompleted]
  }

let getNextStep = (currentStep: steps): steps => {
  switch currentStep {
  | ConnectOrderData(SelectSource) => ConnectOrderData(ConnectionType)
  | ConnectOrderData(ConnectionType) => ConnectProcessorData(APIKeysAndLiveEndpoints)
  | ConnectProcessorData(APIKeysAndLiveEndpoints) => ConnectProcessorData(WebHooks)
  | ConnectProcessorData(WebHooks) => ManualMapping(TestLivePayment)
  | ManualMapping(TestLivePayment) => ManualMapping(SetupCompleted)
  | ManualMapping(SetupCompleted) => ManualMapping(SetupCompleted)
  }
}

let getPreviousStep = (currentStep: steps): steps =>
  switch currentStep {
  | ConnectOrderData(ConnectionType) => ConnectOrderData(SelectSource)
  | ConnectProcessorData(APIKeysAndLiveEndpoints) => ConnectOrderData(ConnectionType)
  | ConnectProcessorData(WebHooks) => ConnectProcessorData(APIKeysAndLiveEndpoints)
  | ManualMapping(TestLivePayment) => ConnectProcessorData(WebHooks)
  | ManualMapping(SetupCompleted) => ManualMapping(TestLivePayment)
  | ConnectOrderData(SelectSource) => ConnectOrderData(SelectSource)
  }

let getPercentage = (currentStep: steps): int => {
  let findIndex =
    subSectionsArr->Array.findIndex(item => item === currentStep->getSubsectionFromStep)
  let totalSteps = subSectionsArr->Array.length
  let percentage = findIndex * 100 / totalSteps
  percentage
}
