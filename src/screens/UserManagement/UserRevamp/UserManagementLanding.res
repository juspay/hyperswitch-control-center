@react.component
let make = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let tabList: array<Tabs.tab> = [
    {
      title: "Users",
      renderContent: () => <ListUsers />,
    },
    {
      title: "Roles",
      renderContent: () => featureFlagDetails.devRolesV2 ? <ListRolesV2 /> : <ListRoles />,
    },
  ]

  <div className="flex flex-col">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title={"Team management"} />
    </div>
    <div className="relative">
      <Tabs tabs=tabList />
    </div>
  </div>
}
