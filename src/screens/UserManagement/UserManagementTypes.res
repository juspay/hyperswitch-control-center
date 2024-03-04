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

open AuthTypes
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

// TODO : Remove this type definition as no longer used
type permissions = {
  description: string,
  enum_name: string,
  mutable isPermissionAllowed: bool,
}

type getInfoType = {
  module_: string,
  description: string,
  // TODO : Remove this type definition as no longer used
  mutable permissions: array<permissions>,
  mutable isPermissionAllowed: bool,
}
