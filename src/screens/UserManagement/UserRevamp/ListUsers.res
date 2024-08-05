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

  let getUserData = async () => {
    setScreenStateUsers(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=USER_MANAGEMENT,
        ~methodType=Get,
        ~userRoleTypes=USER_LIST,
        (),
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
  }, [])

  let filterLogicForUsers = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<userTableTypes>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.email, searchText) ||
          isContainingStringLowercase(obj.name, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setUsersFilterData(_ => filteredList)
  }, ~wait=200)

  let tabList: array<Tabs.tab> = [
    {
      title: "Users",
      renderContent: () =>
        <PageLoaderWrapper screenState={screenStateUsers}>
          <div className="relative mt-5 w-full">
            <div className="absolute right-0 -top-3 z-10">
              <ACLButton
                access={userPermissionJson.usersManage}
                text={"Invite users"}
                buttonType=Primary
                onClick={_ => {
                  mixpanelEvent(~eventName="invite_users", ())
                  RescriptReactRouter.push(
                    GlobalVars.appendDashboardPath(~url="/users-revamp/invite-users"),
                  )
                }}
                customButtonStyle="w-fit !rounded-md"
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
        </PageLoaderWrapper>,
    },
    {
      title: "Roles",
      renderContent: () => <RoleListTableView />,
    },
  ]

  <div className="flex flex-col overflow-y-scroll">
    <PageUtils.PageHeading
      title={"Team management"} subTitle="Manage user roles and invite members of your organisation"
    />
    <div className="relative">
      <Tabs
        tabs=tabList
        disableIndicationArrow=true
        showBorder=false
        includeMargin=false
        lightThemeColor="black"
        defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      />
    </div>
  </div>
}
