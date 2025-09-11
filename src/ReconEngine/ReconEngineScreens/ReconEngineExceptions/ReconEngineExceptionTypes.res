type processedEntryType = {
  entry_id: string,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  expected: string,
  effective_at: string,
  created_at: string,
}

type accountType = {
  account_id: string,
  account_name: string,
}

type processingEntryType = {
  staging_entry_id: string,
  account: accountType,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  processing_mode: string,
  metadata: Js.Json.t,
  transformation_id: string,
  transformation_history_id: string,
  effective_at: string,
}
