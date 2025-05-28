type acquirerConfig = {
  merchant_acquirer_id: string,
  acquirer_assigned_merchant_id: string,
  merchant_name: string,
  mcc: string,
  merchant_country_code: string,
  network: string,
  acquirer_bin: string,
  acquirer_fraud_rate: float,
}

type colType =
  | MerchantAcquirerId
  | AcquirerAssignedMerchantId
  | MerchantName
  | MCC
  | MerchantCountryCode
  | Network
  | AcquirerBin
  | AcquirerFraudRate
