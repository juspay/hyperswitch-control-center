open CommonAuthTypes
open UserManagementTypes

let mapGroupAccessTypeToString = groupAccessType => {
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
  | UnknownGroupAccess(val) => val
  }
}

let mapStringToGroupAccessType = val => {
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
  | val => UnknownGroupAccess(val)
  }
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
}

let hasAnyGroupAccess = (group1, group2) => {
  switch (group1, group2) {
  | (NoAccess, NoAccess) => NoAccess
  | (_, _) => Access
  }
}

let getAccessValue = (~groupAccess: groupAccessType, ~groupACL) =>
  groupACL->Array.find(ele => ele == groupAccess)->Option.isSome ? Access : NoAccess

// TODO: Refactor to not call function for every group
let getGroupAccessJson = groupACL => {
  {
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
    organizationManage: getAccessValue(~groupAccess=OrganizationManage, ~groupACL),
  }
}

let convertValueToMap = arrayValue => {
  open CommonAuthTypes
  let userGroupACLMap: Map.t<
    UserManagementTypes.groupAccessType,
    CommonAuthTypes.authorization,
  > = Map.make()
  arrayValue->Array.forEach(value => userGroupACLMap->Map.set(value, Access))
  userGroupACLMap
}
