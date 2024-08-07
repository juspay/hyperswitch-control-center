@react.component
let make = () => {
  let tabList: array<Tabs.tab> = [
    {
      title: "Users",
      renderContent: () => <ListUsers />,
    },
    {
      title: "Roles",
      renderContent: () => <ListRoles />,
    },
  ]

  <div className="flex flex-col overflow-y-scroll">
    <PageUtils.PageHeading
      title={"Team management"} subTitle="Manage user roles and invite members of your organisation"
    />
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
