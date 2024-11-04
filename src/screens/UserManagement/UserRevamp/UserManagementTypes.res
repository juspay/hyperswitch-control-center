type userManagementTypes = UsersTab | RolesTab

type internalUserType = InternalViewOnly | InternalAdmin | NonInternal

@unboxed
type groupAccessType =
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
  | AccountView
  | AccountManage
  | UnknownGroupAccess(string)

type resourceAccessType =
  | Payment
  | Refund
  | Dispute
  | Payout
  | Customer
  | Connector
  | Analytics
  | Routing
  | ThreeDsDecisionManager
  | SurchargeDecisionManager
  | Recon
  | Account
  | ApiKey
  | User
  | Mandate
  | WebhookEvent
  | Report
  | UnknownResourceAccess(string)

open CommonAuthTypes
type groupAccessJsonType = {
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
  accountView: authorization,
  accountManage: authorization,
}

type getInfoType = {
  module_: string,
  description: string,
}

type userModuleType = {
  parentGroup: string,
  description: string,
  groups: array<string>,
}

type detailedUserModuleType = {
  parentGroup: string,
  description: string,
  scopes: array<string>,
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
type groupControlType = View | Manage

type allSelectionType = [#All_Merchants | #All_Profiles]

type userActionType = SwitchUser | ManageUser | NoActionAccess

type userStatusTypes = Active | InviteSent | None

type userModuleTypes = [UserInfoTypes.entity | #Default]

type ompViewType = {
  label: string,
  entity: userModuleTypes,
}
