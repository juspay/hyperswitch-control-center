type sections = ConnectOrderData | ConnectProcessorData | ManualMapping

type connectOrderDataSubsections = SelectSource | SetupCredentials
type connectProcessorDataSubsections = APIKeysAndLiveEndpoints | WebHooks
type manualMappingSubsections = TestLivePayment | SetupCompleted

type steps =
  | ConnectOrderData(connectOrderDataSubsections)
  | ConnectProcessorData(connectProcessorDataSubsections)
  | ManualMapping(manualMappingSubsections)

type subSections =
  | SelectSource
  | SetupCredentials
  | APIKeysAndLiveEndpoints
  | WebHooks
  | TestLivePayment
  | SetupCompleted
