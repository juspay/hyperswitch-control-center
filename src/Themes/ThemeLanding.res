@react.component
let make = (~remainingPath) => {
  let fetchThemeListResponse = ThemeHook.useFetchThemeList()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let setUpThemeContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if userHasAccess(~groupAccess=ThemeManage) === Access {
        let _ = await fetchThemeListResponse()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }
  React.useEffect(() => {
    setUpThemeContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    <AccessControl authorization={userHasAccess(~groupAccess=ThemeManage)}>
      <EntityScaffold
        entityName="Themes"
        remainingPath
        renderList={() => <ThemeList />}
        renderNewForm={() => <ThemeCreate />}
        renderShow={(themeId, _) => <ThemeUpdate themeId />}
      />
    </AccessControl>
  </PageLoaderWrapper>
}
