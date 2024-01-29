open DisputeTypes
let disputeStageVariantMapper = stage => {
  switch stage {
  | "pre_dispute" => PreDispute
  | "dispute" => Dispute
  | "pre-arbitration" => PreArbitration
  | _ => NotFound
  }
}

let disputeStatusVariantMapper = status => {
  switch status {
  | "dispute_opened" => DisputeOpened
  | "dispute_expired" => DisputeExpired
  | "dispute_accepted" => DisputeAccepted
  | "dispute_cancelled" => DisputeCancelled
  | "dispute_challenged" => DisputeChallenged
  | "dispute_won" => DisputeWon
  | "dispute_lost" => DisputeLost
  | _ => NotFound(status)
  }
}

let showDisputeInfoStatus = [DisputeOpened, DisputeAccepted]

let disputeValueBasedOnStatus = disputeStatus =>
  switch disputeStatus {
  | DisputeOpened => Initiated
  | DisputeAccepted => Accepted
  | DisputeChallenged => Countered
  | _ => Initiated
  }
