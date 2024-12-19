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

  <div className="flex flex-col">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title={"Team management"} />
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
