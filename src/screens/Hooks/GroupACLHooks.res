type userPermissionType = {
  fetchUserGroupACL: unit => promise<UserManagementTypes.permissionJson>,
  userHasAccess: (~groupACL: UserManagementTypes.permissionType) => CommonAuthTypes.authorization,
}

let useUserGroupACLHook = () => {
  open APIUtils
  open LogicUtils
  open GroupACLMapper
  open HyperswitchAtom
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (userGroupACL, setuserGroupACL) = Recoil.useRecoilState(userGroupACLAtom)
  let setuserPermissionJson = Recoil.useSetRecoilState(userPermissionAtom)

  let fetchUserGroupACL = async () => {
    try {
      let url = getURL(
        ~entityName=USERS,
        ~userType=#GET_PERMISSIONS,
        ~methodType=Get,
        ~queryParamerters=Some(`groups=true`),
      )
      let response = await fetchDetails(url)
      let permissionsValue =
        response->getArrayFromJson([])->Array.map(ele => ele->JSON.Decode.string->Option.getOr(""))
      setuserGroupACL(_ => Some(
        permissionsValue
        ->Array.map(ele => ele->mapStringToPermissionType)
        ->convertValueToMap,
      ))
      let permissionJson =
        permissionsValue->Array.map(ele => ele->mapStringToPermissionType)->getPermissionJson
      setuserPermissionJson(_ => permissionJson)
      permissionJson
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let userHasAccess = (~groupACL) => {
    switch userGroupACL {
    | Some(groupPermissions) =>
      switch groupPermissions->Map.get(groupACL) {
      | Some(value) => value
      | None => NoAccess
      }
    | None => NoAccess
    }
  }

  {fetchUserGroupACL, userHasAccess}
}
