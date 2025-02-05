type reconConfigurationSections = [#connectOrderData | #connectProcessorData | #reviewDetails]

type reconConfigurationSubsections = [
  | #selectSource
  | #setupAPIConnection
  | #apiKeysAndLiveEndpoints
  | #webHooks
  | #testLivePayment
  | #setupCompleted
]
