@react.component
let make = () => {
  let (screenState, _setScreenState) = React.useState(() => PageLoaderWrapper.Success)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    setShowSideBar(_ => true)
    None
  }, [])

  <PageLoaderWrapper screenState={screenState}>
    <HSwitchUtils.AlertBanner
      bannerText="Demo Mode: You're viewing sample analytics to help you understand how the reports will look with real data"
      bannerType={Info}
    />
    <PageUtils.PageHeading title="Intelligent Routing Overview" />
  </PageLoaderWrapper>
}
