open CommonAuthTypes
open UserManagementTypes

let mapGroupAccessTypeToString = groupAccessType =>
  switch groupAccessType {
  | OperationsView => "operations_view"
  | OperationsManage => "operations_manage"
  | ConnectorsView => "connectors_view"
  | ConnectorsManage => "connectors_manage"
  | WorkflowsView => "workflows_view"
  | WorkflowsManage => "workflows_manage"
  | AnalyticsView => "analytics_view"
  | UsersView => "users_view"
  | UsersManage => "users_manage"
  | MerchantDetailsView => "merchant_details_view"
  | MerchantDetailsManage => "merchant_details_manage"
  | OrganizationManage => "organization_manage"
  | AccountView => "account_view"
  | AccountManage => "account_manage"
  | ThemeView => "theme_view"
  | ThemeManage => "theme_manage"
  | UnknownGroupAccess(val) => val
  }

let mapStringToGroupAccessType = val =>
  switch val {
  | "operations_view" => OperationsView
  | "operations_manage" => OperationsManage
  | "connectors_view" => ConnectorsView
  | "connectors_manage" => ConnectorsManage
  | "workflows_view" => WorkflowsView
  | "workflows_manage" => WorkflowsManage
  | "analytics_view" => AnalyticsView
  | "users_view" => UsersView
  | "users_manage" => UsersManage
  | "merchant_details_view" => MerchantDetailsView
  | "merchant_details_manage" => MerchantDetailsManage
  | "organization_manage" => OrganizationManage
  | "account_view" => AccountView
  | "account_manage" => AccountManage
  | "theme_view" => ThemeView
  | "theme_manage" => ThemeManage
  | val => UnknownGroupAccess(val)
  }

let mapStringToResourceAccessType = val =>
  switch val {
  | "payment" => Payment
  | "refund" => Refund
  | "api_key" => ApiKey
  | "account" => Account
  | "connector" => Connector
  | "routing" => Routing
  | "dispute" => Dispute
  | "mandate" => Mandate
  | "customer" => Customer
  | "analytics" => Analytics
  | "three_ds_decision_manager" => ThreeDsDecisionManager
  | "surcharge_decision_manager" => SurchargeDecisionManager
  | "user" => User
  | "webhook_event" => WebhookEvent
  | "payout" => Payout
  | "report" => Report
  | "recon_token" => ReconToken
  | "recon_files" => ReconFiles
  | "recon_and_settlement_analytics" => ReconAndSettlementAnalytics
  | "recon_upload" => ReconUpload
  | "recon_reports" => ReconReports
  | "run_recon" => RunRecon
  | "recon_config" => ReconConfig
  | "theme" => Theme
  | _ => UnknownResourceAccess(val)
  }

let defaultValueForGroupAccessJson = {
  operationsView: NoAccess,
  operationsManage: NoAccess,
  connectorsView: NoAccess,
  connectorsManage: NoAccess,
  workflowsView: NoAccess,
  workflowsManage: NoAccess,
  analyticsView: NoAccess,
  usersView: NoAccess,
  usersManage: NoAccess,
  merchantDetailsView: NoAccess,
  merchantDetailsManage: NoAccess,
  organizationManage: NoAccess,
  accountView: NoAccess,
  accountManage: NoAccess,
  themeView: NoAccess,
  themeManage: NoAccess,
}

let convertValueToMapGroup = arrayValue => {
  let userGroupACLMap: Map.t<groupAccessType, authorization> = Map.make()
  arrayValue->Array.forEach(value => userGroupACLMap->Map.set(value, Access))
  userGroupACLMap
}

let convertValueToMapResources = arrayValue => {
  let resourceACLMap: Map.t<resourceAccessType, authorization> = Map.make()
  arrayValue->Array.forEach(value => resourceACLMap->Map.set(value, Access))
  resourceACLMap
}

let getGroupAccessJson = groupACL => {
  let accessMap = convertValueToMapGroup(groupACL)
  let getAccess = key => accessMap->Map.get(key)->Option.isSome ? Access : NoAccess
  {
    operationsView: getAccess(OperationsView),
    operationsManage: getAccess(OperationsManage),
    connectorsView: getAccess(ConnectorsView),
    connectorsManage: getAccess(ConnectorsManage),
    workflowsView: getAccess(WorkflowsView),
    workflowsManage: getAccess(WorkflowsManage),
    analyticsView: getAccess(AnalyticsView),
    usersView: getAccess(UsersView),
    usersManage: getAccess(UsersManage),
    merchantDetailsView: getAccess(MerchantDetailsView),
    merchantDetailsManage: getAccess(MerchantDetailsManage),
    organizationManage: getAccess(OrganizationManage),
    accountView: getAccess(AccountView),
    accountManage: getAccess(AccountManage),
    themeView: getAccess(ThemeView),
    themeManage: getAccess(ThemeManage),
  }
}
