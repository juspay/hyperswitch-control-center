open PermissionUtils
let isAccessAllowed = (permission, ~permissionList) =>
  getAccessValue(~permissionValue=permission, ~permissionList) === Access

@react.component
let make = (~isEnabled=true, ~permissions=?, ~children) => {
  let permissionList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let isAllowed = isAccessAllowed(
    permissions->Option.getWithDefault(UnknownPermission("")),
    ~permissionList,
  )
  isEnabled && isAllowed ? children : <UnauthorizedPage />
}
