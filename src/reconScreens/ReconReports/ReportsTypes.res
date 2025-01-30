type reportPayload = {
  gateway: string,
  merchant_id: string,
  payment_entity_txn_id: string,
  recon_id: string,
  recon_status: string,
  recon_sub_status: string,
  reconciled_at: string,
  settlement_amount: float,
  settlement_id: string,
  txn_amount: float,
  txn_currency: string,
  txn_type: string,
}

type startAndEndTime = {
  startTime: JSON.t,
  endTime: JSON.t,
}

type timeRange = {timeRange: startAndEndTime}
