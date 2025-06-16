type integration = {
  mutable is_done: bool,
  mutable metadata: JSON.t,
}
type dashboardPageStateTypes = [
  | #DEFAULT
  | #HOME
]

type workflowDrawerStateTypes =
  | Closed
  | Minimised(ExploreWorkflowsTypes.workflowTypes)
  | FullWidth(ExploreWorkflowsTypes.workflowTypes)

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
  workflowDrawerState: workflowDrawerStateTypes,
  setWorkflowDrawerState: (workflowDrawerStateTypes => workflowDrawerStateTypes) => unit,
}

type sidebarContextType = {
  isSidebarExpanded: bool,
  setIsSidebarExpanded: (bool => bool) => unit,
}
