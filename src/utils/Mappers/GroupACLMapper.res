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
  | AccountView => "account_view"
  | AccountManage => "account_manage"
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
  | "account_view" => AccountView
  | "account_manage" => AccountManage
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
  | "recon" => Recon
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
  accountView: NoAccess,
  accountManage: NoAccess,
}

let getAccessValue = (~groupAccess: groupAccessType, ~groupACL) =>
  groupACL->Array.find(ele => ele == groupAccess)->Option.isSome ? Access : NoAccess

// TODO: Refactor to not call function for every group
let getGroupAccessJson = groupACL => {
  operationsView: getAccessValue(~groupAccess=OperationsView, ~groupACL),
  operationsManage: getAccessValue(~groupAccess=OperationsManage, ~groupACL),
  connectorsView: getAccessValue(~groupAccess=ConnectorsView, ~groupACL),
  connectorsManage: getAccessValue(~groupAccess=ConnectorsManage, ~groupACL),
  workflowsView: getAccessValue(~groupAccess=WorkflowsView, ~groupACL),
  workflowsManage: getAccessValue(~groupAccess=WorkflowsManage, ~groupACL),
  analyticsView: getAccessValue(~groupAccess=AnalyticsView, ~groupACL),
  usersView: getAccessValue(~groupAccess=UsersView, ~groupACL),
  usersManage: getAccessValue(~groupAccess=UsersManage, ~groupACL),
  merchantDetailsView: getAccessValue(~groupAccess=MerchantDetailsView, ~groupACL),
  merchantDetailsManage: getAccessValue(~groupAccess=MerchantDetailsManage, ~groupACL),
  accountView: getAccessValue(~groupAccess=AccountView, ~groupACL),
  accountManage: getAccessValue(~groupAccess=AccountManage, ~groupACL),
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
