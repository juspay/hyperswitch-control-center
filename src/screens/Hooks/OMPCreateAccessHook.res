let useOMPCreateAccessHook: array<string> => CommonAuthTypes.authorization = allowedRoles => {
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)

  allowedRoles->Array.includes(roleId) ? Access : NoAccess
}
