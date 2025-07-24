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

type processingEntryType = {
  staging_entry_id: string,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  effective_at: string,
}
