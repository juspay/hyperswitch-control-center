type disputes = {
  dispute_id: string,
  payment_id: string,
  attempt_id: string,
  amount: string,
  currency: string,
  dispute_stage: string,
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
  | DisputeStage
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

type disputeStage = PreDispute | Dispute | PreArbitration | NotFound
type disputeStatusType = Landing | EvidencePresent
