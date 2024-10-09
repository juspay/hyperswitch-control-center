@react.component
let make = (~userModuleEntity: UserManagementTypes.userModuleTypes) => {
  open APIUtils
  open ListRolesTableEntity
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenStateRoles, setScreenStateRoles) = React.useState(_ => PageLoaderWrapper.Loading)
  let (rolesAvailableData, setRolesAvailableData) = React.useState(_ => [])
  let (rolesOffset, setRolesOffset) = React.useState(_ => 0)
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let getRolesAvailable = async () => {
    setScreenStateRoles(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=USER_MANAGEMENT_V2,
        ~methodType=Get,
        ~userRoleTypes=ROLE_LIST,
        ~queryParamerters=userModuleEntity == #Default
          ? None
          : Some(`entity_type=${(userModuleEntity :> string)->String.toLowerCase}`),
      )
      let res = await fetchDetails(userDataURL)
      let rolesData = res->LogicUtils.getArrayDataFromJson(itemToObjMapperForRoles)
      setRolesAvailableData(_ => rolesData->Array.map(Nullable.make))
      setScreenStateRoles(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateRoles(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    getRolesAvailable()->ignore
    None
  }, [userModuleEntity])

  <div className="relative mt-5 flex flex-col gap-6">
    <PageLoaderWrapper screenState={screenStateRoles}>
      <div className="flex flex-1 justify-end">
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
          customButtonStyle="w-fit !rounded-md"
          buttonState={checkUserEntity([#Profile]) ? Disabled : Normal}
        />
      </div>
      <LoadedTable
        title="Roles"
        hideTitle=true
        actualData=rolesAvailableData
        totalResults={rolesAvailableData->Array.length}
        resultsPerPage=10
        offset=rolesOffset
        setOffset=setRolesOffset
        entity={rolesEntity}
        currrentFetchCount={rolesAvailableData->Array.length}
        collapseTableRow=false
        tableheadingClass="h-12"
        customBorderClass="border !rounded-xl"
        tableHeadingTextClass="!font-normal"
        tableBorderClass="!border-none"
        nonFrozenTableParentClass="!rounded-xl"
        showSerialNumber=false
      />
    </PageLoaderWrapper>
  </div>
}
