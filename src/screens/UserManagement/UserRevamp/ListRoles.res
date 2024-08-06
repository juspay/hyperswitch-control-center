@react.component
let make = () => {
  open APIUtils
  open RolesEntity
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let (screenStateRoles, setScreenStateRoles) = React.useState(_ => PageLoaderWrapper.Loading)
  let (rolesAvailableData, setRolesAvailableData) = React.useState(_ => [])
  let (rolesOffset, setRolesOffset) = React.useState(_ => 0)

  let getRolesAvailable = async () => {
    setScreenStateRoles(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=USER_MANAGEMENT,
        ~methodType=Get,
        ~userRoleTypes=ROLE_LIST,
        (),
      )
      let res = await fetchDetails(`${userDataURL}?groups=true`)
      let rolesData = res->LogicUtils.getArrayDataFromJson(itemToObjMapperForRoles)
      setRolesAvailableData(_ => rolesData->Array.map(Nullable.make))
      setScreenStateRoles(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateRoles(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    if rolesAvailableData->Array.length == 0 {
      getRolesAvailable()->ignore
    } else {
      setScreenStateRoles(_ => PageLoaderWrapper.Success)
    }

    None
  }, [])

  <div className="relative mt-5 flex flex-col gap-6">
    <PageLoaderWrapper screenState={screenStateRoles}>
      <div className="flex flex-1 justify-end">
        <ACLButton
          access={userPermissionJson.usersManage}
          text={"Create custom roles"}
          buttonType=Primary
          onClick={_ => {
            mixpanelEvent(~eventName="invite_users", ())
            RescriptReactRouter.push(
              GlobalVars.appendDashboardPath(~url="/users/create-custom-role"),
            )
          }}
          customButtonStyle="w-fit !rounded-md"
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
