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
open CommonAuthTypes
type userGroupACLType = {
  fetchUserGroupACL: unit => promise<UserManagementTypes.groupAccessJsonType>,
  userHasResourceAccess: (
    ~resourceAccess: UserManagementTypes.resourceAccessType,
  ) => CommonAuthTypes.authorization,
  userHasAccess: (
    ~groupAccess: UserManagementTypes.groupAccessType,
  ) => CommonAuthTypes.authorization,
  hasAnyGroupAccess: (
    CommonAuthTypes.authorization,
    CommonAuthTypes.authorization,
  ) => CommonAuthTypes.authorization,
  hasAllGroupsAccess: array<CommonAuthTypes.authorization> => CommonAuthTypes.authorization,
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
      let url = getURL(~entityName=V1(USERS), ~userType=#GET_GROUP_ACL, ~methodType=Get)
      let response = await fetchDetails(url)
      let dict = response->getDictFromJsonObject

      let groupsAccessValue = getStrArrayFromDict(dict, "groups", [])

      let resourcesAccessValue = getStrArrayFromDict(dict, "resources", [])

      let userGroupACLMap =
        groupsAccessValue->Array.map(ele => ele->mapStringToGroupAccessType)->convertValueToMapGroup
      let resourceACLMap =
        resourcesAccessValue
        ->Array.map(ele => ele->mapStringToResourceAccessType)
        ->convertValueToMapResources

      setuserGroupACL(_ => Some({
        groups: userGroupACLMap,
        resources: resourceACLMap,
      }))

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
      switch groupACLValue.groups->Map.get(groupAccess) {
      | Some(value) => value
      | None => NoAccess
      }
    | None => NoAccess
    }
  }
  let userHasResourceAccess = (~resourceAccess) => {
    switch userGroupACL {
    | Some(groupACLValue) =>
      switch groupACLValue.resources->Map.get(resourceAccess) {
      | Some(value) => value
      | None => NoAccess
      }
    | None => NoAccess
    }
  }
  let hasAnyGroupAccess = (group1, group2) =>
    switch (group1, group2) {
    | (NoAccess, NoAccess) => NoAccess
    | (_, _) => Access
    }
  let hasAllGroupsAccess = groups => {
    groups->Array.every(group => group === Access) ? Access : NoAccess
  }

  {
    fetchUserGroupACL,
    userHasResourceAccess,
    userHasAccess,
    hasAnyGroupAccess,
    hasAllGroupsAccess,
  }
}
