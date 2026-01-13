type adminType = [#tenant_admin | #org_admin | #merchant_admin | #non_admin]

let roleIdVariantMapper: string => adminType = roleId => {
  switch roleId {
  | "tenant_admin" => #tenant_admin
  | "org_admin" => #org_admin
  | "merchant_admin" => #merchant_admin
  | _ => #non_admin
  }
}

let useOMPCreateAccessHook: array<adminType> => CommonAuthTypes.authorization = allowedRoles => {
  let {roleId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  let roleIdTypedValue = roleId->roleIdVariantMapper

  allowedRoles->Array.includes(roleIdTypedValue) ? Access : NoAccess
}
