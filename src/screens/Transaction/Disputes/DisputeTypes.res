type disputes = {
  profile_id: string,
  dispute_id: string,
  payment_id: string,
  attempt_id: string,
  amount: string,
  currency: string,
  dispute_status: string,
  connector: string,
  connector_status: string,
  connector_dispute_id: string,
  connector_reason: string,
  connector_reason_code: string,
  challenge_required_by: string,
  connector_created_at: string,
  connector_updated_at: string,
  created_at: string,
}

type disputesColsType =
  | DisputeId
  | PaymentId
  | AttemptId
  | Amount
  | Currency
  | DisputeStatus
  | Connector
  | ConnectorStatus
  | ConnectorDisputeId
  | ConnectorReason
  | ConnectorReasonCode
  | ChallengeRequiredBy
  | ConnectorCreatedAt
  | ConnectorUpdatedAt
  | CreatedAt

type disputeStatus =
  | DisputeOpened
  | DisputeExpired
  | DisputeAccepted
  | DisputeCancelled
  | DisputeChallenged
  | DisputeWon
  | DisputeLost
  | NotFound(string)

type disputeStatusType = Landing | EvidencePresent
type filterTypes = {
  connector: array<string>,
  currency: array<string>,
  connector_label: array<string>,
  dispute_status: array<string>,
  dispute_stage: array<string>,
}

type filter = [
  | #connector
  | #currency
  | #connector_label
  | #dispute_status
  | #dispute_stage
  | #unknown
]
