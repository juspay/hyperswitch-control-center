@unboxed
type priority =
  | @as("P0") P0
  | @as("P1") P1
  | @as("P2") P2
  | @as("P3") P3
  | UnknownPriority(string)

let allPriorities = [P0, P1, P2, P3]

type resolutionStatus =
  | @as("Unknown") ResolutionUnknown
  | @as("Raised request :: Merchant") RaisedRequestMerchant
  | @as("Raised request :: Connector") RaisedRequestConnector
  | @as("Raised request :: Network") RaisedRequestNetwork
  | @as("Raised request :: Internal Team") RaisedRequestInternalTeam
  | @as("Not Required to be Resolved") NotRequiredToBeResolved

let allResolutionStatuses = [
  ResolutionUnknown,
  RaisedRequestMerchant,
  RaisedRequestConnector,
  RaisedRequestNetwork,
  RaisedRequestInternalTeam,
  NotRequiredToBeResolved,
]

type internalClassification =
  | @as("Unknown") InternalClassUnknown
  | @as("External :: Connector Issue") ExternalConnectorIssue
  | @as("External :: Merchant Issue") ExternalMerchantIssue
  | @as("External :: Network") ExternalNetwork
  | @as("External :: Others") ExternalOthers
  | @as("Internal :: SDK Issue") InternalSdkIssue
  | @as("Internal :: Bug") InternalBug
  | @as("Internal :: Release") InternalRelease
  | @as("Internal :: Pipeline Broke") InternalPipelineBroke
  | @as("Internal :: Others") InternalOthers

let allInternalClassifications = [
  InternalClassUnknown,
  ExternalConnectorIssue,
  ExternalMerchantIssue,
  ExternalNetwork,
  ExternalOthers,
  InternalSdkIssue,
  InternalBug,
  InternalRelease,
  InternalPipelineBroke,
  InternalOthers,
]

type actionableStatus =
  | @as("Actionable") Actionable
  | @as("Non-Actionable") NonActionable
  | @as("Unknown") ActionableUnknown

let allActionableStatuses = [Actionable, NonActionable, ActionableUnknown]

type yesNoUnknown =
  | @as("Unknown") YnUnknown
  | @as("Yes") Yn_Yes
  | @as("No") Yn_No

let allYesNoUnknown = [YnUnknown, Yn_Yes, Yn_No]

type metadataPlaceholder = | @as("Unknown") UnknownPlaceholder

type blacklistStatus =
  | @as("Blacklisted") Blacklisted
  | @as("Not Blacklisted") NotBlacklisted

type metadataKey =
  | @as("is_blacklisted") IsBlacklistedKey
  | @as("blacklist") BlacklistKey

type dimensionKey =
  | @as("merchant_id") MerchantIdKey
  | @as("profile_id") ProfileIdKey
  | @as("connector") ConnectorKey
  | @as("payment_method") PaymentMethodKey

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
  successRate: float,
  thresholdSr: float,
  failed: float,
  total: float,
  isBlacklisted: bool,
  isSnoozed: bool,
  dimensions: JSON.t,
  metadata: JSON.t,
  snooze: JSON.t,
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
  | AlertBlacklisted
  | AlertSnoozeStatus
  | AlertDuration
  | AlertPriority
  | AlertMerchantId
  | AlertProfileId
  | AlertConnector
  | AlertStatus
  | AlertAttribution
