type configurationTypes = Manual | Automatic | NotSelected

type setupAccountStatus =
  | Redirecting_to_paypal
  | Manual_setup_flow
  | Account_not_found
  | Payments_not_receivable
  | Ppcp_custom_denied
  | More_permissions_needed
  | Email_not_verified
  | Connector_integrated

type choiceDetailsType = {
  displayText: string,
  choiceDescription: string,
  variantType: configurationTypes,
}
type errorPageInfoType = {
  headerText: string,
  subText: string,
  buttonText?: string,
  refreshStatusText?: string,
}
