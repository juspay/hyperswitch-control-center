open ListUserTableEntity

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (usersData, setUsersData) = React.useState(_ => [])
  let (usersFilterData, setUsersFilterData) = React.useState(_ => [])
  let (screenStateUsers, setScreenStateUsers) = React.useState(_ => PageLoaderWrapper.Loading)
  let (userOffset, setUserOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (
    userModuleEntity: UserManagementTypes.userModuleTypes,
    setUserModuleEntity,
  ) = React.useState(_ => #Default)

  let sortByEmail = (
    user1: ListUserTableEntity.userTableTypes,
    user2: ListUserTableEntity.userTableTypes,
  ) => {
    compareLogic(user2.email->String.toLowerCase, user1.email->String.toLowerCase)
  }

  let getUserData = async (userModuleEntity: UserManagementTypes.userModuleTypes) => {
    setScreenStateUsers(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=V1(USER_MANAGEMENT),
        ~methodType=Get,
        ~userRoleTypes=USER_LIST,
        ~queryParameters=userModuleEntity == #Default
          ? None
          : Some(`entity_type=${(userModuleEntity :> string)->String.toLowerCase}`),
      )
      let res = await fetchDetails(userDataURL)
      let userData = res->getArrayDataFromJson(itemToObjMapperForUser)
      userData->Array.sort(sortByEmail)
      setUsersData(_ => userData->Array.map(Nullable.make))
      setUsersFilterData(_ => userData->Array.map(Nullable.make))
      setUserModuleEntity(_ => userModuleEntity)
      setScreenStateUsers(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateUsers(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    getUserData(#Default)->ignore
    None
  }, [])

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
      <div className="flex md:flex-row flex-col gap-2 items-center lg:absolute lg:right-0 lg:z-10">
        <UserManagementHelper.UserOmpView
          views={UserManagementUtils.getUserManagementViewValues(~checkUserEntity)}
          selectedEntity=userModuleEntity
          onChange={getUserData}
        />
        <ACLButton
          authorization={userHasAccess(~groupAccess=UsersManage)}
          text={"Invite users"}
          buttonType=Primary
          buttonSize={Medium}
          onClick={_ => {
            mixpanelEvent(~eventName="invite_users")
            RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/users/invite-users"))
          }}
        />
      </div>
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
        currentFetchCount={usersFilterData->Array.length}
        collapseTableRow=false
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        showSerialNumber=false
        loadedTableParentClass="flex flex-col"
      />
    </div>
  </PageLoaderWrapper>
}
