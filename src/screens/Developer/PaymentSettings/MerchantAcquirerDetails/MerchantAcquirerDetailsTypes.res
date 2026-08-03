type acquirerBucket = {
  id: string,
  merchant_name: string,
  acquirer_assigned_merchant_id: string,
  is_default: bool,
  networks: array<BusinessProfileInterfaceTypes.acquirerNetworkEntry>,
}

@unboxed
type acquirerField =
  | @as("network") Network
  | @as("acquirer_bin") AcquirerBin
  | @as("acquirer_ica") AcquirerIca
  | @as("acquirer_fraud_rate") AcquirerFraudRate
  | @as("acquirer_country_code") AcquirerCountryCode
  | @as("merchant_name") MerchantName
  | @as("acquirer_assigned_merchant_id") AcquirerAssignedMerchantId
  | @as("update") Update
