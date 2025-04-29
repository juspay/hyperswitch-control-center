type integration = {
  mutable is_done: bool,
  mutable metadata: JSON.t,
}
type dashboardPageStateTypes = [
  | #AUTO_CONNECTOR_INTEGRATION
  | #DEFAULT
  | #INTEGRATION_DOC
  | #HOME
]

type integrationDetailsType = {
  pricing_plan: integration,
  connector_integration: integration,
  integration_checklist: integration,
  account_activation: integration,
}

type contextType = {
  showFeedbackModal: bool,
  setShowFeedbackModal: (bool => bool) => unit,
  showProdIntentForm: bool,
  setShowProdIntentForm: (bool => bool) => unit,
  dashboardPageState: dashboardPageStateTypes,
  setDashboardPageState: (dashboardPageStateTypes => dashboardPageStateTypes) => unit,
  integrationDetails: integrationDetailsType,
  setIntegrationDetails: (integrationDetailsType => integrationDetailsType) => unit,
  permissionInfo: array<UserManagementTypes.getInfoType>,
  setPermissionInfo: (
    array<UserManagementTypes.getInfoType> => array<UserManagementTypes.getInfoType>
  ) => unit,
  isProdIntentCompleted: option<bool>,
  setIsProdIntentCompleted: (option<bool> => option<bool>) => unit,
  showSideBar: bool,
  setShowSideBar: (bool => bool) => unit,
}

type sidebarContextType = {
  isSidebarExpanded: bool,
  setIsSidebarExpanded: (bool => bool) => unit,
}

type sdkContextType = {
  showBillingAddress: bool,
  setShowBillingAddress: (bool => bool) => unit,
  isSameAsBilling: bool,
  setIsSameAsBilling: (bool => bool) => unit,
  themeInitialValues: JSON.t,
  setThemeInitialValues: (JSON.t => JSON.t) => unit,
  keyForReRenderingSDK: string,
  setKeyForReRenderingSDK: (string => string) => unit,
  paymentStatus: ReactHyperJs.paymentStatus,
  setPaymentStatus: (ReactHyperJs.paymentStatus => ReactHyperJs.paymentStatus) => unit,
  paymentResult: JSON.t,
  setPaymentResult: (JSON.t => JSON.t) => unit,
  errorMessage: string,
  setErrorMessage: (string => string) => unit,
}
