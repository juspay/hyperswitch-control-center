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

type orgObjectType = {
  name: string,
  value: string,
  id: option<string>,
}

type userDetailstype = {
  roleId: string,
  roleName: string,
  org: orgObjectType,
  merchant: orgObjectType,
  profile: orgObjectType,
  status: string,
  entityType: string,
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

type allSelectionType = [#All_Merchants | #All_Profiles]

type userActionType = SwitchUser | ManageUser | NoActionAccess

type userStatusTypes = Active | InviteSent | None

type userModuleTypes = [UserInfoTypes.entity | #Default]

type ompViewType = {
  label: string,
  entity: userModuleTypes,
}
