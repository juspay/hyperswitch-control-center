type userPermissionType = {
  fetchUserPermissions: unit => promise<UserManagementTypes.permissionJson>,
  userHasAccess: (~permission: UserManagementTypes.permissionType) => CommonAuthTypes.authorization,
}

let useUserPermissionHook = () => {
  open APIUtils
  open LogicUtils
  open PermissionMapper
  open HyperswitchAtom
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (userPermissionMap, setuserPermissionMap) = Recoil.useRecoilState(userPermissionAtomMapType)
  let setuserPermissionJson = Recoil.useSetRecoilState(userPermissionAtom)

  let fetchUserPermissions = async () => {
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
      //   Js.log2(
      //     "permissionsValue",
      //     permissionsValue
      //     ->Array.map(ele => ele->mapStringToPermissionType)
      //     ->HyperSwitchEntryUtils.convertValueToMap,
      //   )
      setuserPermissionMap(_ => Some(
        permissionsValue
        ->Array.map(ele => ele->PermissionMapper.mapStringToPermissionType)
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

  let userHasAccess = (~permission) => {
    switch userPermissionMap {
    | Some(permissionValue) =>
      switch permissionValue->Map.get(permission) {
      | Some(value) => value
      | None => NoAccess
      }
    | None => NoAccess
    }
  }

  {fetchUserPermissions, userHasAccess}
}
