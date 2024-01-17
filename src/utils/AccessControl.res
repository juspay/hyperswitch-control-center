open PermissionUtils
let isAccessAllowed = (permission, ~permissionList) =>
  getAccessValue(~permissionValue=permission, ~permissionList) === Access

module UnauthorizedPage = {
  @react.component
  let make = (
    ~message="You don't have access to this module. Contact admin for access",
    ~customReqMsg=`It appears that you do not currently have access to the  module.`,
  ) => {
    React.useEffect0(() => {
      RescriptReactRouter.replace("/unauthorized")
      None
    })
    <NoDataFound message renderType={Locked} />
  }
}

@react.component
let make = (~isEnabled, ~acl=?, ~children) => {
  let permissionList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let isAllowed = isAccessAllowed(
    acl->Option.getWithDefault(UnknownPermission("")),
    ~permissionList,
  )
  isEnabled && isAllowed
    ? children
    : <UnauthorizedPage message="You don't have access to this module." />
}
