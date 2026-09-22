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
  priority: string,
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
