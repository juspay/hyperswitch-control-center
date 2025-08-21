@react.component
let make = () => {
  open APIUtils
  open RolesMatrixTypes
  open RolesMatrixUtils
  open RolesPermissionsMatrix
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenStateRoles, setScreenStateRoles) = React.useState(_ => PageLoaderWrapper.Loading)
  let (rolesData, setRolesData) = React.useState(_ => [])
  let (matrixData, setMatrixData) = React.useState(_ => {
    modules: [],
    roles: [],
    permissions: Dict.make(),
  })
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filteredRoles, setFilteredRoles) = React.useState(_ => [])

  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (
    userModuleEntity: UserManagementTypes.userModuleTypes,
    setUserModuleEntity,
  ) = React.useState(_ => #Merchant)

  let getRolesAvailable = async (userModuleEntity: UserManagementTypes.userModuleTypes) => {
    setScreenStateRoles(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=V1(USER_MANAGEMENT),
        ~methodType=Get,
        ~userRoleTypes=ROLE_LIST,
        ~queryParamerters=Some(
          `groups=true&entity_type=${(userModuleEntity :> string)->String.toLowerCase}`,
        ),
      )
      let res = await fetchDetails(userDataURL)
      let rolesDataRaw =
        res->LogicUtils.getArrayDataFromJson(RolesMatrixUtils.itemToObjMapperForRoles)
      let processedMatrixData = processRolesData(rolesDataRaw)
      setRolesData(_ => rolesDataRaw)
      setMatrixData(_ => processedMatrixData)
      setFilteredRoles(_ => processedMatrixData.roles)
      setUserModuleEntity(_ => userModuleEntity)
      setScreenStateRoles(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateRoles(_ => PageLoaderWrapper.Error(""))
    }
  }

  let filterLogicForRoles = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, rolesList) = ob
    let filteredList = if searchText->isNonEmptyString {
      rolesList->Array.filter((obj: Nullable.t<roleData>) => {
        switch Nullable.toOption(obj) {
        | Some(role) => isContainingStringLowercase(role.roleName, searchText)
        | None => false
        }
      })
    } else {
      rolesList
    }
    setFilteredRoles(_ => filteredList->Array.filterMap(Nullable.toOption))
  }, ~wait=200)

  React.useEffect(() => {
    getRolesAvailable(#Merchant)->ignore
    None
  }, [])

  <div className="relative mt-5 flex flex-col gap-6">
    <PageLoaderWrapper screenState={screenStateRoles}>
      <div className="flex md:flex-row flex-col flex-1 gap-2 items-center justify-between">
        <TableSearchFilter
          data={matrixData.roles->Array.map(role => Nullable.make(role))}
          filterLogic={filterLogicForRoles}
          placeholder="Search by role name"
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full text-sm rounded-lg"
          searchVal=searchText
          setSearchVal=setSearchText
        />
        <div className="flex gap-2 items-center">
          <UserManagementHelper.UserOmpView
            views={UserManagementUtils.getUserManagementViewValues(
              ~checkUserEntity,
              ~showDefault=false,
            )}
            selectedEntity=userModuleEntity
            onChange={getRolesAvailable}
            customLabel="Role Level:"
            showEntityType=true
          />
          <ACLButton
            authorization={userHasAccess(~groupAccess=UsersManage)}
            text={"Create custom roles"}
            buttonType=Primary
            onClick={_ => {
              mixpanelEvent(~eventName="create_custom_role")
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(~url="/users/create-custom-role"),
              )
            }}
            customButtonStyle="w-fit"
            buttonState={checkUserEntity([#Profile]) ? Disabled : Normal}
          />
        </div>
      </div>
      <RolesPermissionsMatrix matrixData rolesData filteredRoles />
    </PageLoaderWrapper>
  </div>
}
