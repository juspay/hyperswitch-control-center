/*
 Grants create access for an org/merchant/profile when the user's role is scoped to one of
 the allowed parent entities and holds the `account_manage` permission group, mirroring the
 backend permission check. This keeps custom roles with the required permission groups on
 par with the built-in admin roles.
*/
let useOMPCreateAccessHook: array<
  UserInfoTypes.entity,
> => CommonAuthTypes.authorization = allowedEntities => {
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  checkUserEntity(allowedEntities)
    ? userHasAccess(~groupAccess=UserManagementTypes.AccountManage)
    : NoAccess
}
