@react.component
let make = (~remainingPath) => {
  let (screenState, _) = React.useState(_ => PageLoaderWrapper.Success)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen">
    <AccessControl authorization={userHasAccess(~groupAccess=ThemeView)}>
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
