@react.component
let make = (~component: EmbeddableRegistry.embeddableComponent, ~remainingPath) => {
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let {isFullPageModalSupported} = React.useContext(EmbeddedCheckProvider.embeddedContext)
  let (screenState, setScreenState) = React.useState(_ =>
    component.prerequisites->LogicUtils.isEmptyArray
      ? PageLoaderWrapper.Success
      : PageLoaderWrapper.Loading
  )
  let displayOptions = {
    ...component.displayOptions,
    fullPageModals: component.displayOptions.fullPageModals && isFullPageModalSupported,
  }

  let loadPrerequisites = async () => {
    try {
      if component.prerequisites->Array.includes(ConnectorList) {
        let _ = await fetchConnectorListResponse()
      }
      if component.prerequisites->Array.includes(BusinessProfile) {
        let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    loadPrerequisites()->ignore
    None
  }, [])

  let content = component.render(remainingPath)

  <EmbeddableComponentContext.Provider value=displayOptions>
    <PageLoaderWrapper screenState sectionHeight="h-96" showLogoutButton=true>
      {switch component.filterKey {
      | Some(filterKey) => <FilterContext key=filterKey index=filterKey> content </FilterContext>
      | None => content
      }}
    </PageLoaderWrapper>
  </EmbeddableComponentContext.Provider>
}
