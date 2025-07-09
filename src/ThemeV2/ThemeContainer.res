@react.component
let make = () => {
  //   open HyperswitchAtom
  open HSwitchUtils
  let fetchThemeListResponse = ThemeHookV2.useFetchThemeList()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let url = RescriptReactRouter.useUrl()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let setUpThemeContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if userHasAccess(~groupAccess=ThemeManage) === Access {
        let res = await fetchThemeListResponse()
        Js.log2("Theme List Response: ", res)
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
    {switch url.path->urlPath {
    | list{"themev2", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ThemeManage)}>
        <EntityScaffold
          entityName="Themes"
          remainingPath
          renderList={() => <ThemeList />}
          renderNewForm={() => <ThemeCreate />}
          renderShow={(themeId, _) => <ThemeUpdate themeId />}
        />
      </AccessControl>
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
