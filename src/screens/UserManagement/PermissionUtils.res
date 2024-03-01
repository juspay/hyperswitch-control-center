open AuthTypes
open UserManagementTypes

let mapPermissionTypeToString = permissionType => {
  switch permissionType {
  | OperationsView => "OperationsView"
  | OperationsManage => "OperationsManage"
  | ConnectorsView => "ConnectorsView"
  | ConnectorsManage => "ConnectorsManage"
  | WorkflowsView => "WorkflowsView"
  | WorkflowsManage => "WorkflowsManage"
  | AnalyticsView => "AnalyticsView"
  | UsersView => "UsersView"
  | UsersManage => "UsersManage"
  | MerchantDetailsView => "MerchantDetailsView"
  | MerchantDetailsManage => "MerchantDetailsManage"
  | OrganizationManage => "OrganizationManage"
  | UnknownPermission(val) => val
  }
}

let mapStringToPermissionType = val => {
  switch val {
  | "OperationsView" => OperationsView
  | "OperationsManage" => OperationsManage
  | "ConnectorsView" => ConnectorsView
  | "ConnectorsManage" => ConnectorsManage
  | "WorkflowsView" => WorkflowsView
  | "WorkflowsManage" => WorkflowsManage
  | "AnalyticsView" => AnalyticsView
  | "UsersView" => UsersView
  | "UsersManage" => UsersManage
  | "MerchantDetailsView" => MerchantDetailsView
  | "MerchantDetailsManage" => MerchantDetailsManage
  | "OrganizationManage" => OrganizationManage
  | val => UnknownPermission(val)
  }
}

let getAccessValue = (~permissionValue: permissionType, ~permissionList) => {
  let isPermissionFound = permissionList->Array.find(ele => {
    ele === permissionValue
  })

  isPermissionFound->Option.isSome ? Access : Access
}

let defaultValueForPermission = {
  operationsView: Access,
  operationsManage: Access,
  connectorsView: Access,
  connectorsManage: Access,
  workflowsView: Access,
  workflowsManage: Access,
  analyticsView: Access,
  usersView: Access,
  usersManage: Access,
  merchantDetailsView: Access,
  merchantDetailsManage: Access,
  organizationManage: Access,
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
