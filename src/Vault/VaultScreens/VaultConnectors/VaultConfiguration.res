@react.component
let make = () => {
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userHasAccess(~groupAccess=ConnectorsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsManage) === Access
      ) {
        let _ = await fetchConnectorListResponse()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setUpConnectoreContainer()->ignore
    setShowSideBar(_ => true)
    None
  }, [])

  let getTabName = index => index == 0 ? "PSP Tokenisation" : "Network Tokenisation"

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
  <PageLoaderWrapper screenState={screenState}>
    <PageUtils.PageHeading
      title="Vaults" subTitle="Ability to store and retrieve sensitive data in an isolated manner"
    />
    <Tabs
      initialIndex={tabIndex >= 0 ? tabIndex : 0}
      tabs
      showBorder=true
      includeMargin=false
      defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body border "
      onTitleClick={indx => {
        setTabIndex(_ => indx)
        setCurrentTabName(_ => getTabName(indx))
      }}
      selectTabBottomBorderColor="bg-primary"
    />
  </PageLoaderWrapper>
}
