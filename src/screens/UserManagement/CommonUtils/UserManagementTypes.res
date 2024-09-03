type userManagementTypes = UsersTab | RolesTab

type permissionType =
  | OperationsView
  | OperationsManage
  | ConnectorsView
  | ConnectorsManage
  | WorkflowsView
  | WorkflowsManage
  | AnalyticsView
  | UsersView
  | UsersManage
  | MerchantDetailsView
  | MerchantDetailsManage
  | OrganizationManage
  | UnknownPermission(string)

open CommonAuthTypes
type permissionJson = {
  operationsView: authorization,
  operationsManage: authorization,
  connectorsView: authorization,
  connectorsManage: authorization,
  workflowsView: authorization,
  workflowsManage: authorization,
  analyticsView: authorization,
  usersView: authorization,
  usersManage: authorization,
  merchantDetailsView: authorization,
  merchantDetailsManage: authorization,
  organizationManage: authorization,
}

type getInfoType = {
  module_: string,
  description: string,
  mutable isPermissionAllowed: bool,
}

type userModuleType = {
  parentGroup: string,
  description: string,
  groups: array<string>,
}

@unboxed
type parentGroupType =
  | Operations
  | Connectors
  | Workflows
  | Analytics
  | Users
  | Merchant
  | Organization
  | UnknownPermission(string)

@unboxed
type groupPermissionType = View | Manage
