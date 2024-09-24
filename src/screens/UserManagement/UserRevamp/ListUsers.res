open ListUserTableEntity

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let (usersData, setUsersData) = React.useState(_ => [])
  let (usersFilterData, setUsersFilterData) = React.useState(_ => [])
  let (screenStateUsers, setScreenStateUsers) = React.useState(_ => PageLoaderWrapper.Loading)
  let (userOffset, setUserOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let (
    userModuleEntity: UserManagementTypes.userModuleTypes,
    setUserModuleEntity,
  ) = React.useState(_ => #Default)

  let getUserData = async () => {
    setScreenStateUsers(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=USER_MANAGEMENT_V2,
        ~methodType=Get,
        ~userRoleTypes=USER_LIST,
        ~queryParamerters=userModuleEntity == #Default
          ? None
          : Some(`entity_type=${(userModuleEntity :> string)->String.toLowerCase}`),
      )
      let res = await fetchDetails(userDataURL)
      let userData = res->getArrayDataFromJson(itemToObjMapperForUser)
      setUsersData(_ => userData->Array.map(Nullable.make))
      setUsersFilterData(_ => userData->Array.map(Nullable.make))
      setScreenStateUsers(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateUsers(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    getUserData()->ignore
    None
  }, [userModuleEntity])

  let filterLogicForUsers = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<userTableTypes>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) => isContainingStringLowercase(obj.email, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setUsersFilterData(_ => filteredList)
  }, ~wait=200)

  <PageLoaderWrapper screenState={screenStateUsers}>
    <div className="relative mt-5 w-full flex flex-col gap-12">
      <div className="absolute right-0 z-10">
        <ACLButton
          access={userPermissionJson.usersManage}
          text={"Invite users"}
          buttonType=Primary
          onClick={_ => {
            mixpanelEvent(~eventName="invite_users")
            RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/users/invite-users"))
          }}
          customButtonStyle="w-fit !rounded-md"
        />
      </div>
      <UserManagementHelper.UserOmpView
        views={UserManagementUtils.getUserManagementViewValues(~checkUserEntity)}
        userModuleEntity
        setUserModuleEntity
      />
      <LoadedTable
        title="Users"
        hideTitle=true
        actualData=usersFilterData
        totalResults={usersFilterData->Array.length}
        filters={<TableSearchFilter
          data={usersData}
          filterLogic=filterLogicForUsers
          placeholder="Search by name or email.."
          customSearchBarWrapperWidth="w-full lg:w-1/3"
          customInputBoxWidth="w-full"
          searchVal=searchText
          setSearchVal=setSearchText
        />}
        resultsPerPage=10
        offset=userOffset
        setOffset=setUserOffset
        entity={ListUserTableEntity.userEntity}
        currrentFetchCount={usersFilterData->Array.length}
        collapseTableRow=false
        tableheadingClass="h-12"
        customBorderClass="border !rounded-xl"
        tableHeadingTextClass="!font-normal"
        tableBorderClass="!border-none"
        nonFrozenTableParentClass="!rounded-xl"
        showSerialNumber=false
        loadedTableParentClass="flex flex-col gap-4"
      />
    </div>
  </PageLoaderWrapper>
}
