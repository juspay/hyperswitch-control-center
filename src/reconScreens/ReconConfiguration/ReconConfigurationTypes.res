type sections = ConnectOrderData | ConnectProcessorData | ManualMapping

type connectOrderDataSubsections = SelectSource | SetupAPIConnection
type connectProcessorDataSubsections = APIKeysAndLiveEndpoints | WebHooks
type manualMappingSubsections = TestLivePayment | SetupCompleted

type steps =
  | ConnectOrderData(connectOrderDataSubsections)
  | ConnectProcessorData(connectProcessorDataSubsections)
  | ManualMapping(manualMappingSubsections)

type subSections =
  | SelectSource
  | SetupAPIConnection
  | APIKeysAndLiveEndpoints
  | WebHooks
  | TestLivePayment
  | SetupCompleted

type subSectionsArr = array<subSections>
