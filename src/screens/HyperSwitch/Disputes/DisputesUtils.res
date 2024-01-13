type disputeStage = PreDispute | Dispute | PreArbitration | Unknown

let disputeStageVariantMapper = stage => {
  switch stage {
  | "pre_dispute" => PreDispute
  | "dispute" => Dispute
  | "pre-arbitration" => PreArbitration
  | _ => Unknown
  }
}

type disputeStatus =
  | DisputeOpened
  | DisputeExpired
  | DisputeAccepted
  | DisputeCancelled
  | DisputeChallenged
  | DisputeWon
  | DisputeLost
  | Unknown

let disputeStatusVariantMapper = status => {
  switch status {
  | "dispute_opened" => DisputeOpened
  | "dispute_expired" => DisputeExpired
  | "dispute_accepted" => DisputeAccepted
  | "dispute_cancelled" => DisputeCancelled
  | "dispute_challenged" => DisputeChallenged
  | "dispute_won" => DisputeWon
  | "dispute_lost" => DisputeLost
  | _ => Unknown
  }
}
