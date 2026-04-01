@react.component
let make = (~remainingPath) => {
  open APIUtils
  open APIUtilsTypes

  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let setThemeList = HyperswitchAtom.themeListAtom->Recoil.useSetRecoilState

  let fetchThemeList = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if userHasAccess(~groupAccess=ThemeManage) === Access {
        let url = getURL(
          ~entityName=V1(USERS),
          ~methodType=Get,
          ~queryParameters=Some(`entity_type=organization`),
          ~userType=#THEME_LIST,
        )
        let res = await fetchDetails(url, ~version=V1)
        setThemeList(_ => res)
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Error fetching theme list"))
    }
  }

  React.useEffect(() => {
    fetchThemeList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen">
    <EntityScaffold
      entityName="Themes"
      remainingPath
      renderList={() =>
        <AccessControl authorization={userHasAccess(~groupAccess=ThemeView)}>
          <ThemeList />
        </AccessControl>}
      renderNewForm={() =>
        <AccessControl authorization={userHasAccess(~groupAccess=ThemeManage)}>
          <ThemeCreate />
        </AccessControl>}
      renderShow={(themeId, remainingPath) => {
        switch remainingPath {
        | Some(val) => {
            let parts = val->String.replace("key=", "")->String.trim->String.split("+")
            let (extractedProfileId, extractedMerchantId, extractedOrgId) = switch parts {
            | [p, m, o] => (p, m, o)
            | _ => ("all_profiles", "all_merchants", "all_orgs")
            }
            let profileId = if extractedProfileId == "all_profiles" {
              None
            } else {
              Some(extractedProfileId)
            }
            let merchantId = if extractedMerchantId == "all_merchants" {
              None
            } else {
              Some(extractedMerchantId)
            }
            let orgId = if extractedOrgId == "all_orgs" {
              None
            } else {
              Some(extractedOrgId)
            }

            <AccessControl authorization={userHasAccess(~groupAccess=ThemeManage)}>
              <ThemeUpdate themeId orgId merchantId profileId />
            </AccessControl>
          }
        | None =>
          <AccessControl authorization={userHasAccess(~groupAccess=ThemeManage)}>
            <ThemeUpdate themeId orgId=None merchantId=None profileId=None />
          </AccessControl>
        }
      }}
    />
  </PageLoaderWrapper>
}
