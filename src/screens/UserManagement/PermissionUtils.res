open AuthTypes
open UserManagementTypes

let mapPermissionTypeToString = permissionType => {
  switch permissionType {
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
  | UnknownPermission(val) => val
  }
}

let mapStringToPermissionType = val => {
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
  | val => UnknownPermission(val)
  }
}

let getAccessValue = (~permissionValue: permissionType, ~permissionList) => {
  let isPermissionFound = permissionList->Array.find(ele => {
    ele == permissionValue
  })

  isPermissionFound->Option.isSome ? Access : NoAccess
}

let defaultValueForPermission = {
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

// TODO: Refactor to not call function for every permission
let getPermissionJson = permissionList => {
  {
    operationsView: getAccessValue(~permissionValue=OperationsView, ~permissionList),
    operationsManage: getAccessValue(~permissionValue=OperationsManage, ~permissionList),
    connectorsView: getAccessValue(~permissionValue=ConnectorsView, ~permissionList),
    connectorsManage: getAccessValue(~permissionValue=ConnectorsManage, ~permissionList),
    workflowsView: getAccessValue(~permissionValue=WorkflowsView, ~permissionList),
    workflowsManage: getAccessValue(~permissionValue=WorkflowsManage, ~permissionList),
    analyticsView: getAccessValue(~permissionValue=AnalyticsView, ~permissionList),
    usersView: getAccessValue(~permissionValue=UsersView, ~permissionList),
    usersManage: getAccessValue(~permissionValue=UsersManage, ~permissionList),
    merchantDetailsView: getAccessValue(~permissionValue=MerchantDetailsView, ~permissionList),
    merchantDetailsManage: getAccessValue(~permissionValue=MerchantDetailsManage, ~permissionList),
    organizationManage: getAccessValue(~permissionValue=OrganizationManage, ~permissionList),
  }
}

let linkForGetShowLinkViaAccess = (~permission, ~url) => {
  permission === Access ? url : ``
}

let cursorStyles = permission => permission === Access ? "cursor-pointer" : "cursor-not-allowed"
