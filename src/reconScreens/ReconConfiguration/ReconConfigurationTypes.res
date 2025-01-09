type sections = ConnectOrderData | ConnectProcessorData | ManualMapping

type connectOrderDataSubsections = SelectSource | ConnectionType
type connectProcessorDataSubsections = APIKeysAndLiveEndpoints | WebHooks
type manualMappingSubsections = TestLivePayment | SetupCompleted

type steps =
  | ConnectOrderData(connectOrderDataSubsections)
  | ConnectProcessorData(connectProcessorDataSubsections)
  | ManualMapping(manualMappingSubsections)

type subSections =
  | SelectSource
  | ConnectionType
  | APIKeysAndLiveEndpoints
  | WebHooks
  | TestLivePayment
  | SetupCompleted
