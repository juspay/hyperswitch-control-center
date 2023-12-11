type applePayIntegrationType = [#manual | #simplified]

type applePayIntegrationSteps = Landing | Configure | Verify
type simplifiedApplePayIntegartionTypes = EnterUrl | DownloadFile | HostUrl

type verifyApplePay = {
  domain_names: array<string>,
  merchant_connector_account_id: string,
}
