@react.component
let make = (~remainingPath) => {
  open APIUtils
  open APIUtilsTypes

  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let setThemeList = HyperswitchAtom.themeListAtom->Recoil.useSetRecoilState

  let fetchThemeList = async (~entityName, ~version, ~userType) => {
    try {
      let url = getURL(
        ~entityName,
        ~methodType=Get,
        ~queryParameters=Some(`entity_type=organization`),
        ~userType,
      )
      let res = await fetchDetails(url, ~version)
      setThemeList(_ => res)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let setUpThemeContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if userHasAccess(~groupAccess=ThemeManage) === Access {
        let _ = await fetchThemeList(
          ~entityName=V1(USERS),
          ~version=UserInfoTypes.V1,
          ~userType=#THEME_LIST,
        )
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Error fetching theme list"))
    }
  }

  React.useEffect(() => {
    setUpThemeContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen">
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
