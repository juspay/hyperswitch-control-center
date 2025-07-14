type transactionPayload = {
  id: string,
  transaction_id: string,
  entry_id: array<string>,
  transaction_status: string,
  discarded_status: string,
  variance: int,
  version: int,
  created_at: string,
}

type entryPayload = {
  entry_id: string,
  entry_type: string,
  transaction_id: string,
  amount: float,
  currency: string,
  status: string,
  discarded_status: string,
  metadata: Js.Json.t,
  created_at: string,
  effective_at: string,
}

type transactionColType =
  | Id
  | TransactionId
  | Status

type entryColType =
  | EntryId
  | EntryType
  | TransactionId
  | Amount
  | Currency
  | Status
  | DiscardedStatus
  | Metadata
  | CreatedAt
  | EffectiveAt
