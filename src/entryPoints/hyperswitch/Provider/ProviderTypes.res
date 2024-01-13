type integration = {
  mutable is_done: bool,
  mutable metadata: Js.Json.t,
}
type dashboardPageStateTypes = [
  | #POST_LOGIN_QUES_NOT_DONE
  | #AUTO_CONNECTOR_INTEGRATION
  | #DEFAULT
  | #INTEGRATION_DOC
  | #AGREEMENT_SIGNATURE
  | #PROD_ONBOARDING
  | #HOME
  | #WOOCOMMERCE_FLOW
  | #STRIPE_PLUS_PAYPAL
  | #QUICK_START
]

type permissions = {
  description: string,
  enum_name: string,
  mutable isPermissionAllowed: bool,
}

type getInfoType = {
  module_: string,
  description: string,
  mutable permissions: array<permissions>,
}

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
  permissionInfo: array<getInfoType>,
  setPermissionInfo: (array<getInfoType> => array<getInfoType>) => unit,
  isProdIntentCompleted: bool,
  setIsProdIntentCompleted: (bool => bool) => unit,
  quickStartPageState: QuickStartTypes.quickStartType,
  setQuickStartPageState: (
    QuickStartTypes.quickStartType => QuickStartTypes.quickStartType
  ) => unit,
}

type sidebarContextType = {
  isSidebarExpanded: bool,
  setIsSidebarExpanded: (bool => bool) => unit,
  getFromSidebarDetails: Js.Dict.key => bool,
  setIsSidebarDetails: (Js.Dict.key, Js.Json.t) => unit,
}
