@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let (screenState, _) = React.useState(_ => PageLoaderWrapper.Success)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"theme", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ThemeView)}>
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
