type networkConfig = BusinessProfileInterfaceTypes.acquirerNetworkEntry

type acquirerBucket = {
  id: string,
  merchant_name: string,
  acquirer_assigned_merchant_id: string,
  is_default: bool,
  networks: array<networkConfig>,
}

type colType =
  | Network
  | AcquirerBin
  | AcquirerIca
  | AcquirerFraudRate
  | AcquirerCountryCode
  | Update
