type options = {
  name: string,
  key: string,
}

type vaultStatus =
  | Enable
  | Skip

type validationFieldsV2 =
  | WebhookDetails
  | ReturnUrl
  | AuthenticationConnectorDetails
  | AuthenticationConnectors(array<JSON.t>)
  | ThreeDsRequestorUrl
  | ThreeDsRequestorAppUrl
  | MaxAutoRetries
  | AutoRetry
  | VaultProcessorDetails
  | UnknownValidateFields(string)
