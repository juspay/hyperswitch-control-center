@react.component
let make = () => {
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let (
    userModuleEntity: UserManagementTypes.userModuleTypes,
    setUserModuleEntity,
  ) = React.useState(_ => #Default)

  let tabList: array<Tabs.tab> = [
    {
      title: "Users",
      renderContent: () => <ListUsers userModuleEntity />,
    },
    {
      title: "Roles",
      renderContent: () => <ListRoles userModuleEntity />,
    },
  ]

  <div className="flex flex-col overflow-y-scroll">
    <div className="flex justify-between">
      <PageUtils.PageHeading
        title={"Team management"}
        subTitle="Manage user roles and invite members of your organisation"
      />
      <UserManagementHelper.UserOmpView
        views={UserManagementUtils.getUserManagementViewValues(~checkUserEntity)}
        userModuleEntity
        setUserModuleEntity
      />
    </div>
    <div className="relative">
      <Tabs
        tabs=tabList
        showBorder=true
        includeMargin=false
        lightThemeColor="black"
        defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
        textStyle="text-blue-600"
        selectTabBottomBorderColor="bg-blue-600"
      />
    </div>
  </div>
}
