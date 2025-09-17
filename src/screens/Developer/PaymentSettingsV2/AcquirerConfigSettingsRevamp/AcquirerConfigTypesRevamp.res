type acquirerConfig = {
  id: string,
  acquirer_assigned_merchant_id: string,
  merchant_name: string,
  network: string,
  acquirer_bin: string,
  acquirer_fraud_rate: float,
}

type colType =
  | AcquirerAssignedMerchantId
  | MerchantName
  | Network
  | AcquirerBin
  | AcquirerFraudRate
  | Update
