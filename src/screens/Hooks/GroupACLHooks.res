/**
 * @module GroupACLHook
 *
 * @description This exposes a hook to call the list of user group access
 *               and to check if the user has access to that group
 *
 *  @functions
 *  - fetchUserGroupACL : fetches the list of user group level access
 *  - userHasAccess: checks if the user has access to that group or not
 *         @params
 *         - groupAccess : group to check if the user has access or not
 *
 *
 */
type userGroupACLType = {
  fetchUserGroupACL: unit => promise<UserManagementTypes.groupAccessJsonType>,
  userHasAccess: (
    ~groupAccess: UserManagementTypes.groupAccessType,
  ) => CommonAuthTypes.authorization,
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
        ~userType=#GET_GROUP_ACL,
        ~methodType=Get,
        ~queryParamerters=Some(`groups=true`),
      )
      let response = await fetchDetails(url)
      let groupsAccessValue =
        response->getArrayFromJson([])->Array.map(ele => ele->JSON.Decode.string->Option.getOr(""))
      setuserGroupACL(_ => Some(
        groupsAccessValue
        ->Array.map(ele => ele->mapStringToGroupAccessType)
        ->convertValueToMap,
      ))
      let permissionJson =
        groupsAccessValue->Array.map(ele => ele->mapStringToGroupAccessType)->getGroupAccessJson
      setuserPermissionJson(_ => permissionJson)
      permissionJson
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let userHasAccess = (~groupAccess) => {
    switch userGroupACL {
    | Some(groupACLValue) =>
      switch groupACLValue->Map.get(groupAccess) {
      | Some(value) => value
      | None => NoAccess
      }
    | None => NoAccess
    }
  }

  {fetchUserGroupACL, userHasAccess}
}
