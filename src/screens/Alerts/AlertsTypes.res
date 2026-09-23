@unboxed
type priority =
  | @as("P0") P0
  | @as("P1") P1
  | @as("P2") P2
  | @as("P3") P3
  | UnknownPriority(string)

let allPriorities = [P0, P1, P2, P3]

@unboxed
type alertState =
  | @as("firing") Firing
  | @as("recovered") Recovered

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
