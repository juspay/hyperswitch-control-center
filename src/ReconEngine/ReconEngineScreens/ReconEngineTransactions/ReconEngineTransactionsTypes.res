type amountType = {
  value: float,
  currency: string,
}

type ruleType = {
  rule_id: string,
  rule_name: string,
}

type accountType = {
  account_id: string,
  account_name: string,
}

type transactionEntryType = {
  entry_id: string,
  entry_type: string,
  account: accountType,
}

type transactionPayload = {
  id: string,
  transaction_id: string,
  entries: array<transactionEntryType>,
  profile_id: string,
  credit_amount: amountType,
  debit_amount: amountType,
  rule: ruleType,
  transaction_status: string,
  discarded_status: option<string>,
  version: int,
  created_at: string,
  effective_at: string,
}

type transactionStatus =
  | Posted
  | Mismatched
  | Expected
  | Archived
  | UnknownTransactionStatus

type entryStatus =
  | Posted
  | Mismatched
  | Expected
  | Archived
  | Pending
  | UnknownEntry

type entryPayload = {
  entry_id: string,
  entry_type: string,
  account_name: string,
  transaction_id: string,
  amount: float,
  currency: string,
  status: string,
  discarded_status: option<string>,
  metadata: Js.Json.t,
  created_at: string,
  effective_at: string,
}

type transactionColType =
  | TransactionId
  | Status
  | Variance
  | CreditAccount
  | DebitAccount
  | CreditAmount
  | DebitAmount
  | CreatedAt

type entryColType =
  | EntryId
  | EntryType
  | AccountName
  | TransactionId
  | Amount
  | Currency
  | Status
  | Metadata
  | CreatedAt
  | EffectiveAt

type entriesMetadataKeysToExclude = Amount | Currency
