@react.component
let make = () => {
  open LogicUtils
  open ThemeListHelper

  let getURL = APIUtils.useGetURL()
  let getMethod = APIUtils.useGetMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let themeList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.themeListAtom)
  let (currentTheme, setCurrentTheme) = React.useState(_ => None)
  let themeListArray = themeList->getArrayFromJson([])
  let (getList, getNameForId) = OMPSwitchHooks.useOMPData()
  let {orgList, merchantList, profileList} = getList()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {themeId: themeIdFromUserInfo, orgId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getResolvedUserInfo()
  let (showModal, setShowModal) = React.useState(_ => false)

  let fetchCurrentTheme = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Get,
        ~id=Some(themeIdFromUserInfo),
        ~userType=#THEME,
      )
      let res = await getMethod(url)
      setCurrentTheme(_ => Some(res))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setCurrentTheme(_ => None)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    }
  }

  React.useEffect(() => {
    let storeThemeId = HyperSwitchEntryUtils.getThemeIdfromStore()->Option.getOr("")
    if themeIdFromUserInfo->isNonEmptyString && themeIdFromUserInfo == storeThemeId {
      fetchCurrentTheme()->ignore
    }
    None
  }, [themeIdFromUserInfo])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col h-screen gap-8">
      <div className="flex flex-col flex-1 h-full w-full">
        <div className="flex items-center justify-between w-full">
          <div className="flex-1">
            <PageUtils.PageHeading
              title="Theme Configuration" customTitleStyle="text-nd_gray-800"
            />
          </div>
          <RenderIf condition={themeListArray->Array.length > 0}>
            <ACLButton
              text="Create Theme"
              buttonType=Primary
              buttonSize=Small
              authorization={userHasAccess(~groupAccess=ThemeManage)}
              onClick={_ => setShowModal(_ => true)}
            />
          </RenderIf>
        </div>
        <RenderIf condition={themeListArray->isNonEmptyArray}>
          <div className="mt-2">
            <AlertV2Binding
              alertType=Warning
              slot={{slot: <Icon name="nd-info-circle" size=16 className="text-nd_gray-500" />}}
              description="Theme changes take effect after the page is refreshed."
            />
          </div>
        </RenderIf>
        <NoThemesFound themeListArray setShowModal />
        <RenderIf condition={themeListArray->Array.length > 0}>
          <CurrentThemeCard currentTheme getNameForId themeId={themeIdFromUserInfo} orgId />
          <LoadedTable
            title="List of created themes"
            hideTitle=false
            actualData={themeListArray->Array.map(Nullable.make)}
            entity={ThemeListEntity.themeTableEntity(~orgId, ~orgList, ~merchantList, ~profileList)}
            resultsPerPage=20
            showSerialNumber=true
            totalResults={themeListArray->Array.length}
            offset=0
            setOffset={_ => ()}
            currentFetchCount={themeListArray->Array.length}
          />
        </RenderIf>
      </div>
      <ThemeHelper.ThemeLineageModal showModal setShowModal />
    </div>
  </PageLoaderWrapper>
}
