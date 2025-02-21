// type sections = ConnectOrderData | ConnectProcessorData | ManualMapping

// type connectOrderDataSubsections = SelectSource | SetupAPIConnection
// type connectProcessorDataSubsections = APIKeysAndLiveEndpoints | WebHooks
// type manualMappingSubsections = TestLivePayment | SetupCompleted

// type steps =
//   | ConnectOrderData(connectOrderDataSubsections)
//   | ConnectProcessorData(connectProcessorDataSubsections)
//   | ManualMapping(manualMappingSubsections)

// type subSections =
//   | SelectSource
//   | SetupAPIConnection
//   | APIKeysAndLiveEndpoints
//   | WebHooks
//   | TestLivePayment
//   | SetupCompleted

// type subSectionsArr = array<subSections>

type sections = [#connectOrderData | #connectProcessorData | #manualMapping]
type connectOrderDataSubSections = [#selectSource | #setupAPIConnection]
type connectProcessorDataSubSections = [#apiKeysAndLiveEndpoints | #webHooks]
type manualMappingSubSections = [#testLivePayment | #setupCompleted]

type subSections = [
  | #selectSource
  | #setupAPIConnection
  | #apiKeysAndLiveEndpoints
  | #webHooks
  | #testLivePayment
  | #setupCompleted
]
