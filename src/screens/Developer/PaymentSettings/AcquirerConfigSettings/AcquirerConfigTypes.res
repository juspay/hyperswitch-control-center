type acquirerConfig = {
  acquirer_assigned_merchant_id: string,
  merchant_name: string,
  merchant_country_code: string,
  network: string,
  acquirer_bin: string,
  acquirer_fraud_rate: float,
}

type colType =
  | AcquirerAssignedMerchantId
  | MerchantName
  | MerchantCountryCode
  | Network
  | AcquirerBin
  | AcquirerFraudRate
