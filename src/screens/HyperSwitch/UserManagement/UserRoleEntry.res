type roles = Users | Roles
open UserRoleEntity

@react.component
let make = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (usersData, setUsersData) = React.useState(_ => [])
  let (usersFilterData, setUsersFilterData) = React.useState(_ => [])
  let (screenStateUsers, setScreenStateUsers) = React.useState(_ => PageLoaderWrapper.Loading)
  let (userOffset, setUserOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")

  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)

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
      let userData = res->LogicUtils.getArrayDataFromJson(itemToObjMapperForUser)
      setUsersData(_ => userData->Array.map(Js.Nullable.return))
      setUsersFilterData(_ => userData->Array.map(Js.Nullable.return))
      setScreenStateUsers(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateUsers(_ => PageLoaderWrapper.Error(""))
    }
  }

  let getPermissionInfo = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#PERMISSION_INFO, ~methodType=Get, ())
      let res = await fetchDetails(url)
      setPermissionInfo(_ =>
        res->LogicUtils.getArrayDataFromJson(ProviderHelper.itemToObjMapperForGetInfo)
      )
    } catch {
    | _ => ()
    }
  }

  React.useEffect0(() => {
    if permissionInfo->Array.length === 0 {
      getPermissionInfo()->ignore
    }

    if usersData->Array.length === 0 {
      getUserData()->ignore
    }
    None
  })

  let filterLogicForUsers = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->String.length > 0 {
      arr->Array.filter((obj: Js.Nullable.t<userTableTypes>) => {
        switch Js.Nullable.toOption(obj) {
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
          <div className="mt-5">
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
              entity={userEntity}
              currrentFetchCount={usersFilterData->Array.length}
              showSerialNumber=true
              collapseTableRow=false
              rowHeightClass="h-20"
              tableheadingClass="h-16"
            />
          </div>
        </PageLoaderWrapper>,
    },
    {
      title: "Roles",
      renderContent: () =>
        <DefaultLandingPage
          title="Coming Soon" height="60vh" overriddingStylesTitle="text-3xl font-semibold"
        />,
    },
  ]

  <div className="flex flex-col overflow-y-scroll">
    {<>
      <PageUtils.PageHeading
        title={"Team management"}
        subTitle="Manage user roles and invite members of your organisation"
      />
      <div className="relative">
        <div className="absolute right-0 top-5">
          <Button
            text={"Invite users"}
            buttonType=Primary
            onClick={_ => {
              mixpanelEvent(~eventName="invite_users", ())
              RescriptReactRouter.push("/users/invite-users")
            }}
            customButtonStyle="w-48"
          />
        </div>
        <Tabs
          tabs=tabList
          disableIndicationArrow=true
          showBorder=false
          includeMargin=false
          lightThemeColor="black"
          defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
        />
      </div>
    </>}
  </div>
}
