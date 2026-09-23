type priority =
  | @as("P0") P0
  | @as("P1") P1
  | @as("P2") P2
  | @as("P3") P3
  | @as("Unknown") PriorityUnknown

external priorityFromString: string => priority = "%identity"
external priorityToString: priority => string = "%identity"

let allPriorities = [P0, P1, P2, P3]

type alert = {
  id: string,
  name: string,
  product: string,
  merchantId: string,
  profileId: string,
  connector: string,
  paymentMethod: string,
  tsAlert: string,
  startTime: string,
  endTime: string,
  priority: priority,
  attribution: string,
}

type alertsDictionary = {
  merchantIds: array<string>,
  profileIds: array<string>,
  connectors: array<string>,
  paymentMethods: array<string>,
}

type colType =
  | AlertDate
  | AlertType
  | AlertProduct
  | AlertDuration
  | AlertPriority
  | AlertMerchantId
  | AlertProfileId
  | AlertConnector
  | AlertStatus
  | AlertAttribution
