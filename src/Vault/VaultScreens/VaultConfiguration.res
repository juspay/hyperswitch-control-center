@react.component
let make = (~remainingPath) => {
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()

  React.useEffect(() => {
    fetchConnectorListResponse()->ignore
    setShowSideBar(_ => true)
    None
  }, [])

  let getTabName = index => index == 0 ? "PSP Tokenisation" : "Netwrok Tokenisation"

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "PSP Tokenisation",
        renderContent: () => {
          <VaultProcessorList />
        },
      },
      {
        title: "Network Tokenisation",
        renderContent: () => <div />,
      },
    ]
  }, [])
  <>
    <PageUtils.PageHeading
      title="Vaults" subTitle="Ability to store and retrieve sensitive data in an isolated manner"
    />
    <EntityScaffold
      entityName="HyperSwitch Priority Logic"
      remainingPath
      renderList={() =>
        <Tabs
          initialIndex={tabIndex >= 0 ? tabIndex : 0}
          tabs
          showBorder=true
          includeMargin=false
          lightThemeColor="blue-500"
          defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body border "
          onTitleClick={indx => {
            setTabIndex(_ => indx)
            setCurrentTabName(_ => getTabName(indx))
          }}
          selectTabBottomBorderColor="bg-blue-600"
        />}
    />
  </>
}
